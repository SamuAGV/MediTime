import SwiftUI

struct StatisticsView: View {
    @ObservedObject var dataManager: DataManager
    
    var totalMedications: Int {
        return self.dataManager.medications.filter { $0.isActive }.count
    }
    
    var totalTaken: Int {
        return self.dataManager.logs.filter { $0.status == .taken }.count
    }
    
    var totalMissed: Int {
        return self.dataManager.logs.filter { $0.status == .missed }.count
    }
    
    var totalSnoozed: Int {
        return self.dataManager.logs.filter { $0.status == .snoozed }.count
    }
    
    var adherenceRate: Int {
        let total = self.totalTaken + self.totalMissed + self.totalSnoozed
        guard total > 0 else { return 0 }
        return Int((Double(self.totalTaken) / Double(total)) * 100)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 14) {
                    // Espacio superior
                    Spacer()
                        .frame(height: 14)
                    
                    // Título
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        Text("Estadísticas")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    
                    // Tarjeta de adherencia
                    VStack(spacing: 8) {
                        Text("Adherencia")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(self.adherenceRate) / 100)
                                .stroke(
                                    self.adherenceRate >= 80 ? Color.green :
                                    self.adherenceRate >= 50 ? Color.orange : Color.red,
                                    lineWidth: 12
                                )
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(self.adherenceRate)%")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(
                                    self.adherenceRate >= 80 ? Color.green :
                                    self.adherenceRate >= 50 ? Color.orange : Color.red
                                )
                        }
                        
                        Text("\(self.totalTaken) de \(self.totalTaken + self.totalMissed + self.totalSnoozed) tomados")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4)
                    .padding(.horizontal, 8)
                    
                    // Estadísticas detalladas
                    HStack(spacing: 12) {
                        MiniStatCard(title: "Tomados",
                                    value: "\(self.totalTaken)",
                                    icon: "checkmark.circle.fill",
                                    color: .green)
                        
                        MiniStatCard(title: "Pospuestos",
                                    value: "\(self.totalSnoozed)",
                                    icon: "clock.fill",
                                    color: .orange)
                        
                        MiniStatCard(title: "Omitidos",
                                    value: "\(self.totalMissed)",
                                    icon: "xmark.circle.fill",
                                    color: .red)
                    }
                    .padding(.horizontal, 8)
                    
                    // Total de medicamentos
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Medicamentos activos")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text("\(self.totalMedications)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Image(systemName: "pills.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.blue.opacity(0.3))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4)
                    .padding(.horizontal, 8)
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 8)
                .frame(minHeight: geometry.size.height - 50)
            }
        }
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 16, weight: .bold))
            Text(title)
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
