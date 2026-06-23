import SwiftUI

struct HistoryView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddLogSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header con botón de prueba
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Historial")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    
                    // Botón para agregar registro de prueba
                    /* Button(action: {
                        self.showingAddLogSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }*/
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)
                .padding(.bottom, 4)
                
                if self.dataManager.logs.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "clock")
                            .font(.system(size: 36))
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("Sin registros")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("Registra tu primera toma")
                            .font(.system(size: 9))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(self.groupLogsByDate(), id: \.0) { date, logs in
                            Section(header:
                                Text(self.formatDate(date))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.gray)
                            ) {
                                ForEach(logs) { log in
                                    HistoryItem(log: log,
                                              medicationName: self.medicationName(for: log.medicationId))
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .sheet(isPresented: $showingAddLogSheet) {
            AddLogView(dataManager: self.dataManager)
        }
    }
    
    func medicationName(for id: UUID) -> String {
        return self.dataManager.medications.first(where: { $0.id == id })?.name ?? "Desconocido"
    }
    
    func groupLogsByDate() -> [(Date, [MedicationLog])] {
        let grouped = Dictionary(grouping: self.dataManager.logs) { log in
            Calendar.current.startOfDay(for: log.date)
        }
        return grouped.sorted { $0.key > $1.key }
            .map { ($0.key, $0.value) }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Vista para Agregar Log Manual (SIN DatePicker)
struct AddLogView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedMedicationId: UUID?
    @State private var selectedStatus: MedicationLog.StatusType = .taken
    @State private var selectedHour = 8
    @State private var selectedMinute = 0
    @State private var selectedDay = 0
    @State private var selectedMonth = 0
    @State private var selectedYear = 0
    
    // Arrays para los pickers
    let hours = Array(0..<24)
    let minutes = Array(0..<60)
    let days = Array(1...31)
    let months = Array(1...12)
    let years = Array(2020...2030)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("toRegistrar Toma")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 8)
                
                // Seleccionar medicamento
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medicamento")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                    
                    if dataManager.medications.isEmpty {
                        Text("No hay medicamentos registrados")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        Picker("Seleccionar", selection: self.$selectedMedicationId) {
                            Text("Seleccionar...").tag(nil as UUID?)
                            ForEach(self.dataManager.medications) { med in
                                Text(med.name).tag(med.id as UUID?)
                            }
                        }
                        .frame(height: 80)
                        .labelsHidden()
                    }
                }
                
                // Estado
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado")
                        .font(.system(size: 4))
                        .foregroundColor(.gray)
                    
                    Picker("Estado", selection: self.$selectedStatus) {
                        Text("Tomado").tag(MedicationLog.StatusType.taken)
                        Text("Pospuesto").tag(MedicationLog.StatusType.snoozed)
                        Text("Omitido").tag(MedicationLog.StatusType.missed)
                    }
                    .frame(height: 60)
                    .labelsHidden()
                }
                
                // Fecha y Hora (reemplazo de DatePicker)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fecha y Hora")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                    
                    // Fila de fecha
                    HStack(spacing: 4) {
                        // Día
                        VStack {
                            Text("Día")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                            Picker("", selection: self.$selectedDay) {
                                ForEach(0..<self.days.count, id: \.self) { index in
                                    Text("\(self.days[index])").tag(index)
                                }
                            }
                            .frame(width: 40)
                            .labelsHidden()
                        }
                        
                        // Mes
                        VStack {
                            Text("Mes")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                            Picker("", selection: self.$selectedMonth) {
                                ForEach(0..<self.months.count, id: \.self) { index in
                                    Text("\(self.months[index])").tag(index)
                                }
                            }
                            .frame(width: 40)
                            .labelsHidden()
                        }
                        
                        // Año
                        VStack {
                            Text("Año")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                            Picker("", selection: self.$selectedYear) {
                                ForEach(0..<self.years.count, id: \.self) { index in
                                    Text("\(self.years[index])").tag(index)
                                }
                            }
                            .frame(width: 50)
                            .labelsHidden()
                        }
                        
                        Spacer()
                        
                        // Hora
                        VStack {
                            Text("Hora")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                            Picker("", selection: self.$selectedHour) {
                                ForEach(0..<self.hours.count, id: \.self) { index in
                                    Text("\(self.hours[index])").tag(index)
                                }
                            }
                            .frame(width: 40)
                            .labelsHidden()
                        }
                        
                        Text(":")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.top, 8)
                        
                        // Minuto
                        VStack {
                            Text("Min")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                            Picker("", selection: self.$selectedMinute) {
                                ForEach(0..<self.minutes.count, id: \.self) { index in
                                    Text(String(format: "%02d", self.minutes[index])).tag(index)
                                }
                            }
                            .frame(width: 40)
                            .labelsHidden()
                        }
                    }
                    .frame(height: 80)
                }
                
                // Botones
                VStack(spacing: 6) {
                    Button(action: {
                        self.saveLog()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                            Text("Guardar")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(self.selectedMedicationId == nil ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(self.selectedMedicationId == nil || dataManager.medications.isEmpty)
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancelar")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 8)
        }
    }
    
    func saveLog() {
        guard let medId = selectedMedicationId else { return }
        
        // Crear fecha con los valores seleccionados
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = years[selectedYear]
        components.month = months[selectedMonth]
        components.day = days[selectedDay]
        components.hour = hours[selectedHour]
        components.minute = minutes[selectedMinute]
        
        let selectedDate = calendar.date(from: components) ?? Date()
        
        let log = MedicationLog(
            medicationId: medId,
            scheduledTime: selectedDate,
            status: selectedStatus,
            date: selectedDate
        )
        
        dataManager.logs.append(log)
        dataManager.saveData()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - HistoryItem
struct HistoryItem: View {
    let log: MedicationLog
    let medicationName: String
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(self.colorForStatus(log.status).opacity(0.15))
                    .frame(width: 26, height: 26)
                Image(systemName: self.iconForStatus(log.status))
                    .foregroundColor(self.colorForStatus(log.status))
                    .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(medicationName)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(self.formatTime(log.scheduledTime))
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(log.status.rawValue)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(self.colorForStatus(log.status))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(self.colorForStatus(log.status).opacity(0.12))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func iconForStatus(_ status: MedicationLog.StatusType) -> String {
        switch status {
        case .taken: return "checkmark.circle.fill"
        case .snoozed: return "clock.fill"
        case .missed: return "xmark.circle.fill"
        }
    }
    
    func colorForStatus(_ status: MedicationLog.StatusType) -> Color {
        switch status {
        case .taken: return .green
        case .snoozed: return .orange
        case .missed: return .red
        }
    }
}
