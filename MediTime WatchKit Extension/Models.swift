import Foundation

// MARK: - Modelo de Medicamento
struct Medication: Identifiable, Codable {
    let id: UUID
    var name: String
    var dosage: String
    var unit: String
    var times: [Date]
    var selectedDays: [Bool]?
    var isActive: Bool
    
    init(id: UUID = UUID(), name: String, dosage: String, unit: String, times: [Date], selectedDays: [Bool]? = nil, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.times = times
        self.selectedDays = selectedDays ?? [true, true, true, true, true, true, true]
        self.isActive = isActive
    }
}

// MARK: - Modelo de Registro (Historial)
struct MedicationLog: Identifiable, Codable {
    let id: UUID
    let medicationId: UUID
    let scheduledTime: Date
    var takenTime: Date?
    var status: StatusType
    let date: Date
    
    enum StatusType: String, Codable {
        case taken = "Tomado"
        case snoozed = "Pospuesto"
        case missed = "Omitido"
    }
    
    init(id: UUID = UUID(), medicationId: UUID, scheduledTime: Date, status: StatusType, date: Date = Date()) {
        self.id = id
        self.medicationId = medicationId
        self.scheduledTime = scheduledTime
        self.status = status
        self.date = date
    }
}
