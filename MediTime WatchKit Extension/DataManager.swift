import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var logs: [MedicationLog] = []
    
    init() {
        print("🟢 DataManager: Inicializando...")
        loadData()
        if medications.isEmpty {
            print("📝 DataManager: No hay datos, agregando ejemplos...")
            addSampleData()
        } else {
            print("✅ DataManager: \(medications.count) medicamentos cargados")
        }
    }
    
    // MARK: - Guardar y Cargar
    func saveData() {
        print("💾 DataManager: Guardando datos...")
        do {
            let medData = try JSONEncoder().encode(medications)
            UserDefaults.standard.set(medData, forKey: "medications")
            print("✅ DataManager: \(medications.count) medicamentos guardados")
        } catch {
            print("❌ DataManager: Error guardando medicamentos: \(error)")
        }
        
        do {
            let logData = try JSONEncoder().encode(logs)
            UserDefaults.standard.set(logData, forKey: "logs")
            print("✅ DataManager: \(logs.count) logs guardados")
        } catch {
            print("❌ DataManager: Error guardando logs: \(error)")
        }
    }
    
    func loadData() {
        print("📂 DataManager: Cargando datos...")
        
        if let data = UserDefaults.standard.data(forKey: "medications") {
            do {
                let decoded = try JSONDecoder().decode([Medication].self, from: data)
                medications = decoded
                print("✅ DataManager: \(medications.count) medicamentos cargados")
            } catch {
                print("❌ DataManager: Error cargando medicamentos: \(error)")
            }
        } else {
            print("⚠️ DataManager: No se encontraron medicamentos guardados")
        }
        
        if let data = UserDefaults.standard.data(forKey: "logs") {
            do {
                let decoded = try JSONDecoder().decode([MedicationLog].self, from: data)
                logs = decoded
                print("✅ DataManager: \(logs.count) logs cargados")
            } catch {
                print("❌ DataManager: Error cargando logs: \(error)")
            }
        } else {
            print("⚠️ DataManager: No se encontraron logs guardados")
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
            times: [morning, evening],
            selectedDays: [true, true, true, true, true, true, true]
        )
        
        let med2 = Medication(
            name: "Ibuprofeno",
            dosage: "400",
            unit: "mg",
            times: [morning],
            selectedDays: [true, true, true, true, true, false, false]
        )
        
        medications = [med1, med2]
        saveData()
        
        // Agregar logs de ejemplo
        addSampleLogs()
        
        print("✅ DataManager: Datos de ejemplo creados: \(medications.count) medicamentos")
    }
    
    // MARK: - Agregar logs de ejemplo
    func addSampleLogs() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) ?? today
        
        // Fechas para simular tomas
        let morningToday = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today) ?? today
        let eveningToday = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) ?? today
        let morningYesterday = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: yesterday) ?? yesterday
        let eveningYesterday = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: yesterday) ?? yesterday
        let morningTwoDaysAgo = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: twoDaysAgo) ?? twoDaysAgo
        
        // Obtener IDs de los medicamentos
        guard let paracetamolId = medications.first(where: { $0.name == "Paracetamol" })?.id,
              let ibuprofenoId = medications.first(where: { $0.name == "Ibuprofeno" })?.id else {
            return
        }
        
        // Logs de ejemplo
        let sampleLogs: [MedicationLog] = [
            // Hoy - Tomados
            MedicationLog(medicationId: paracetamolId, scheduledTime: morningToday, status: .taken),
            MedicationLog(medicationId: ibuprofenoId, scheduledTime: morningToday, status: .taken),
            MedicationLog(medicationId: paracetamolId, scheduledTime: eveningToday, status: .taken),
            
            // Ayer - Mezcla de estados
            MedicationLog(medicationId: paracetamolId, scheduledTime: morningYesterday, status: .taken),
            MedicationLog(medicationId: ibuprofenoId, scheduledTime: morningYesterday, status: .snoozed),
            MedicationLog(medicationId: paracetamolId, scheduledTime: eveningYesterday, status: .missed),
            
            // Anteayer - Tomados
            MedicationLog(medicationId: paracetamolId, scheduledTime: morningTwoDaysAgo, status: .taken),
            MedicationLog(medicationId: ibuprofenoId, scheduledTime: morningTwoDaysAgo, status: .taken),
        ]
        
        logs = sampleLogs
        saveData()
        print("✅ DataManager: \(logs.count) logs de ejemplo creados")
    }
    
    // MARK: - CRUD
    func addMedication(_ medication: Medication) {
        print("➕ DataManager: Agregando medicamento: \(medication.name)")
        medications.append(medication)
        saveData()
        NotificationManager.shared.scheduleReminder(for: medication)
    }
    
    func updateMedication(_ medication: Medication) {
        print("✏️ DataManager: Actualizando medicamento: \(medication.name)")
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
            saveData()
            NotificationManager.shared.scheduleReminder(for: medication)
            print("✅ DataManager: Medicamento actualizado correctamente")
        } else {
            print("❌ DataManager: No se encontró el medicamento con ID: \(medication.id)")
        }
    }
    
    func deleteMedication(_ medication: Medication) {
        print("🗑️ DataManager: Eliminando medicamento: \(medication.name)")
        medications.removeAll { $0.id == medication.id }
        saveData()
        NotificationManager.shared.cancelNotifications(for: medication)
    }
}
