import UserNotifications
import WatchKit

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        self.requestAuthorization()
    }
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Permiso de notificaciones concedido")
            } else {
                print("❌ Permiso de notificaciones denegado")
            }
        }
    }
    
    func scheduleReminder(for medication: Medication) {
        let center = UNUserNotificationCenter.current()
        
        // Eliminar notificaciones previas de este medicamento
        center.removePendingNotificationRequests(withIdentifiers: [medication.id.uuidString])
        
        for time in medication.times {
            let content = UNMutableNotificationContent()
            content.title = "💊 ¡Hora de tomar \(medication.name)!"
            content.body = "Dosis: \(medication.dosage) \(medication.unit)"
            content.sound = .default
            content.categoryIdentifier = "MEDICATION_REMINDER"
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "\(medication.id.uuidString)-\(components.hour!)-\(components.minute!)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Error programando notificación: \(error)")
                } else {
                    print("✅ Notificación programada para \(medication.name) a las \(components.hour!):\(components.minute!)")
                }
            }
        }
    }
    
    func cancelNotifications(for medication: Medication) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [medication.id.uuidString])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
