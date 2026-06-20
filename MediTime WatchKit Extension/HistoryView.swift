import SwiftUI

struct HistoryView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Espacio superior
                Spacer()
                    .frame(height: 6)
                
                // Header
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Historial")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                
                if self.dataManager.logs.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "clock")
                            .font(.system(size: 36))
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("Sin registros")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("Toma tu primer medicamento")
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray.opacity(0.7))
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
