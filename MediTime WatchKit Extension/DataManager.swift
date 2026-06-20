import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var logs: [MedicationLog] = []
    
    init() {
        loadData()
        if medications.isEmpty {
            addSampleData()
        }
    }
    
    // MARK: - Guardar y Cargar
    func saveData() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "medications")
        }
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: "logs")
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "medications"),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: "logs"),
           let decoded = try? JSONDecoder().decode([MedicationLog].self, from: data) {
            logs = decoded
        }
    }
    
    // MARK: - Datos de ejemplo
    func addSampleData() {
        let calendar = Calendar.current
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        
        let med1 = Medication(
            name: "Paracetamol",
            dosage: "500",
            unit: "mg",
            times: [morning, evening]
        )
        
        let med2 = Medication(
            name: "Ibuprofeno",
            dosage: "400",
            unit: "mg",
            times: [morning]
        )
        
        medications = [med1, med2]
        saveData()
        
        // Programar notificaciones
        for med in medications {
            NotificationManager.shared.scheduleReminder(for: med)
        }
    }
    
    // MARK: - CRUD
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        saveData()
        NotificationManager.shared.scheduleReminder(for: medication)
    }
    
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
            saveData()
            NotificationManager.shared.scheduleReminder(for: medication)
        }
    }
    
    func deleteMedication(_ medication: Medication) {
        medications.removeAll { $0.id == medication.id }
        saveData()
        NotificationManager.shared.cancelNotifications(for: medication)
    }
}
