import SwiftUI

// MARK: - Pantalla Principal
struct ContentView: View {
    @ObservedObject var dataManager = DataManager()
    @State private var currentScreen = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // ⚠️ ESPACIO SUPERIOR - Para que la hora no tape el contenido
                Spacer()
                    .frame(height: 8) // Espacio fijo arriba
                
                // Contenido principal
                ZStack {
                    if self.currentScreen == 0 {
                        DashboardView(dataManager: self.dataManager)
                    } else if self.currentScreen == 1 {
                        MedicationListView(dataManager: self.dataManager)
                    } else if self.currentScreen == 2 {
                        HistoryView(dataManager: self.dataManager)
                    } else {
                        StatisticsView(dataManager: self.dataManager)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Barra de navegación en la parte inferior
                HStack(spacing: 0) {
                    NavButton(
                        icon: self.currentScreen == 0 ? "house.fill" : "house",
                        label: "Inicio",
                        isActive: self.currentScreen == 0,
                        action: { self.currentScreen = 0 }
                    )
                    
                    NavButton(
                        icon: self.currentScreen == 1 ? "pills.fill" : "pills",
                        label: "Medicamentos",
                        isActive: self.currentScreen == 1,
                        action: { self.currentScreen = 1 }
                    )
                    
                    NavButton(
                        icon: self.currentScreen == 2 ? "clock.fill" : "clock",
                        label: "Historial",
                        isActive: self.currentScreen == 2,
                        action: { self.currentScreen = 2 }
                    )
                    
                    NavButton(
                        icon: self.currentScreen == 3 ? "chart.pie.fill" : "chart.pie",
                        label: "Stats",
                        isActive: self.currentScreen == 3,
                        action: { self.currentScreen = 3 }
                    )
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
                .background(
                    Color.black.opacity(0.06)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Color.gray.opacity(0.2)),
                            alignment: .top
                        )
                )
                .frame(height: 40)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Botón de Navegación
struct NavButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isActive ? .bold : .regular))
                    .foregroundColor(isActive ? .blue : .gray)
                Text(label)
                    .font(.system(size: 8, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .blue : Color.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - DashboardView
struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    
    var nextMedication: Medication? {
        return dataManager.medications.first { $0.isActive }
    }
    
    var pendingCount: Int {
        return dataManager.medications.filter { $0.isActive }.count
    }
    
    var takenCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dataManager.logs.filter { log in
            Calendar.current.isDate(log.date, inSameDayAs: today) &&
            log.status == .taken
        }.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 12) {
                    // ⚠️ ESPACIO SUPERIOR ADICIONAL EN DASHBOARD
                    Spacer()
                        .frame(height: 4)
                    
                    // Header - Título
                    HStack {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [.red, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 30, height: 30)
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                        }
                        Text("MediTime")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    
                    // Próximo medicamento
                    if self.nextMedication != nil {
                        NextMedicationCardWithData(medication: self.nextMedication!)
                    } else {
                        NextMedicationCardEmpty()
                    }
                    
                    // Estadísticas
                    HStack(spacing: 10) {
                        StatCard(title: "Pendientes", value: "\(self.pendingCount)", icon: "clock.badge.exclamationmark", color: .orange)
                        StatCard(title: "Tomados", value: "\(self.takenCount)", icon: "checkmark.circle.fill", color: .green)
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer(minLength: 10)
                }
                .padding(.bottom, 6)
                .frame(minHeight: geometry.size.height - 60)
            }
        }
    }
}

// MARK: - Tarjeta de Medicamento
struct NextMedicationCardWithData: View {
    let medication: Medication
    
    var firstTimeText: String {
        if let firstTime = medication.times.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: firstTime)
        }
        return ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 11))
                Text("Próximo")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
            }
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "pill.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(medication.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Text("\(medication.dosage) \(medication.unit)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(firstTimeText)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 8)
    }
}

struct NextMedicationCardEmpty: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 32))
            Text("¡Todo tomado!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.green)
            Text("Sin medicamentos")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}
