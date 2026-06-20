import SwiftUI

// MARK: - Pantalla Principal con Navegación por Swipe
struct ContentView: View {
    @ObservedObject var dataManager = DataManager()
    @State private var currentScreen = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Espacio superior
                Spacer()
                    .frame(height: 8)
                
                // Indicador de pantalla actual (dots)
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(self.currentScreen == index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 2)
                
                // Contenido con gestos de deslizamiento
                ZStack {
                    Group {
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
                    .offset(x: self.dragOffset)
                    .animation(.interactiveSpring(), value: self.dragOffset)
                    
                    // Indicadores de deslizamiento
                    HStack {
                        if self.currentScreen > 0 {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.blue.opacity(0.5))
                                .padding(.leading, 4)
                        }
                        
                        Spacer()
                        
                        if self.currentScreen < 3 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.blue.opacity(0.5))
                                .padding(.trailing, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            if abs(horizontalAmount) > abs(verticalAmount) {
                                self.dragOffset = horizontalAmount
                                self.isDragging = true
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 40
                            let horizontalAmount = value.translation.width
                            
                            withAnimation(.spring()) {
                                if horizontalAmount < -threshold && self.currentScreen < 3 {
                                    self.currentScreen += 1
                                } else if horizontalAmount > threshold && self.currentScreen > 0 {
                                    self.currentScreen -= 1
                                }
                                self.dragOffset = 0
                                self.isDragging = false
                            }
                        }
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - 🏠 DASHBOARD REDISEÑADO
struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    
    // Datos calculados
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
    
    var totalMedications: Int {
        return dataManager.medications.count
    }
    
    var adherenceRate: Int {
        let total = dataManager.logs.count
        let taken = dataManager.logs.filter { $0.status == .taken }.count
        guard total > 0 else { return 0 }
        return Int((Double(taken) / Double(total)) * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // HEADER CON SALUDO
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color.white)
                            .font(.system(size: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("MediTime")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Tu salud al día")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(formattedDate())
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 12)
                
                // TARJETA DE PROGRESO (Anillo de adherencia)
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 56, height: 56)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(adherenceRate) / 100)
                            .stroke(
                                adherenceRate >= 80 ? Color.green :
                                adherenceRate >= 50 ? Color.orange : Color.red,
                                lineWidth: 8
                            )
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.8), value: adherenceRate)
                        
                        Text("\(adherenceRate)%")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(
                                adherenceRate >= 80 ? Color.green :
                                adherenceRate >= 50 ? Color.orange : Color.red
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Adherencia")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Text(adherenceRate >= 80 ? "🌟 ¡Excelente!" :
                             adherenceRate >= 50 ? "💪 Vas bien" :
                             "⚠️ Necesitas mejorar")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(
                                adherenceRate >= 80 ? Color.green :
                                adherenceRate >= 50 ? Color.orange : Color.red
                            )
                        
                        Text("\(dataManager.logs.filter { $0.status == .taken }.count) de \(dataManager.logs.count) tomados")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal, 10)
                
                // PRÓXIMO MEDICAMENTO
                ZStack {
                    if nextMedication != nil {
                        NextMedicationCardGradient(medication: nextMedication!)
                            .opacity(1)
                    }
                    
                    if nextMedication == nil {
                        EmptyStateCard()
                            .opacity(nextMedication == nil ? 1 : 0)
                    }
                }
                
                // ESTADÍSTICAS RÁPIDAS (Grid)
                HStack(spacing: 10) {
                    StatCard(
                        title: "Medicamentos",
                        value: "\(totalMedications)",
                        icon: "pills.fill",
                        color: .blue,
                        subtitle: "activos"
                    )
                    
                    StatCard(
                        title: "Tomados hoy",
                        value: "\(takenCount)",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        subtitle: "de \(pendingCount + takenCount)"
                    )
                }
                .padding(.horizontal, 10)
                
                // TARJETA DE CONSEJO
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    
                    Text(tipOfTheDay())
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Funciones auxiliares
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: Date())
    }
    
    func nextMedicationTimeFormatted(_ medication: Medication) -> String {
        guard let firstTime = medication.times.first else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: firstTime)
    }
    
    func tipOfTheDay() -> String {
        let tips = [
            "💡 Toma tus medicamentos a la misma hora todos los días",
            "💡 Usa un pastillero para organizar tus dosis semanales",
            "💡 Mantén un registro de tus horarios para no olvidarlos",
            "💡 Consulta a tu médico si tienes dudas sobre las dosis",
            "💡 Programa alarmas adicionales si lo necesitas",
            "💡 Lleva siempre tus medicamentos cuando viajes"
        ]
        let day = Calendar.current.component(.day, from: Date())
        return tips[day % tips.count]
    }
}

// MARK: - Tarjeta de Próximo Medicamento con Gradiente
struct NextMedicationCardGradient: View {
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(Color.white)
                    .font(.system(size: 10))
                
                Text("PRÓXIMO")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Color.white)
                    .tracking(1)
                
                Spacer()
                
                Text("hoy")
                    .font(.system(size: 8))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "pill.fill")
                        .foregroundColor(Color.white)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(medication.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.white)
                    Text("\(medication.dosage) \(medication.unit)")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(firstTimeText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)
                    Text("hora")
                        .font(.system(size: 7))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(14)
        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 10)
    }
}

// MARK: - Estado Vacío
struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.green)
                .font(.system(size: 32))
            Text("¡Todo listo!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.green)
            Text("No hay medicamentos pendientes")
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 10)
    }
}

// MARK: - Tarjeta de Estadística
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 12))
                }
                
                Text(title)
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 7))
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .frame(maxWidth: .infinity)
    }
}
