import SwiftUI

// MARK: - Pantalla Principal con Navegación por Swipe
struct ContentView: View {
    @ObservedObject var dataManager = DataManager()
    @State private var currentScreen = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    // Nombres de las pantallas para la navegación
    let screens = [
        "Inicio",
        "Medicamentos",
        "Historial",
        "Estadísticas"
    ]
    
    // Iconos para cada pantalla
    let icons = [
        "heart.fill",
        "pills.fill",
        "clock.arrow.circlepath",
        "chart.pie.fill"
    ]
    
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
                            .fill(self.currentScreen == index ? Color.blue : Color.gray.opacity(0.3)) // ✅ CORREGIDO
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 2)
                
                // Contenido con gestos de deslizamiento
                ZStack {
                    // Contenido según la pantalla actual
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
                    
                    // Indicadores de deslizamiento en los bordes
                    HStack {
                        // Flecha izquierda (si no estamos en la primera pantalla)
                        if self.currentScreen > 0 {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.blue.opacity(0.5)) // ✅ CORREGIDO
                                .padding(.leading, 4)
                        }
                        
                        Spacer()
                        
                        // Flecha derecha (si no estamos en la última pantalla)
                        if self.currentScreen < 3 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.blue.opacity(0.5)) // ✅ CORREGIDO
                                .padding(.trailing, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false) // No interferir con los gestos
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Solo permitir swipe horizontal
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            // Si el movimiento es más horizontal que vertical
                            if abs(horizontalAmount) > abs(verticalAmount) {
                                self.dragOffset = horizontalAmount
                                self.isDragging = true
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 40 // Umbral mínimo para detectar swipe
                            let horizontalAmount = value.translation.width
                            
                            withAnimation(.spring()) {
                                // Swipe hacia la izquierda (siguiente pantalla)
                                if horizontalAmount < -threshold && self.currentScreen < 3 {
                                    self.currentScreen += 1
                                }
                                // Swipe hacia la derecha (pantalla anterior)
                                else if horizontalAmount > threshold && self.currentScreen > 0 {
                                    self.currentScreen -= 1
                                }
                                
                                // Resetear offset
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
                    Spacer()
                        .frame(height: 12)
                    
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
                    
                    Spacer(minLength: 12)
                }
                .padding(.bottom, 6)
                .frame(minHeight: geometry.size.height - 60)
            }
        }
    }
}

// MARK: - Tarjetas
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
