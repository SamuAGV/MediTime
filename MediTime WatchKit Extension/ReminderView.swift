import SwiftUI

struct ReminderView: View {
    let medication: Medication
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dataManager: DataManager
    
    @State private var isTaken = false
    @State private var isSnoozed = false
    
    var formattedTime: String {
        if let firstTime = medication.times.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: firstTime)
        }
        return ""
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .padding(.top, 20)
            
            Text("¡Hora de tomar!")
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.blue)
                Text("\(medication.dosage) \(medication.unit)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                Text("\(formattedTime) hrs")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            VStack(spacing: 10) {
                Button(action: {
                    self.isTaken = true
                    self.registrarTomado()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Tomado")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    self.isSnoozed = true
                    self.registrarPospuesto()
                }) {
                    HStack {
                        Image(systemName: "clock.fill")
                        Text("Posponer 10 min")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    self.registrarOmitido()
                }) {
                    Text("Omitir")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.black.opacity(0.02))
    }
    
    func registrarTomado() {
        let log = MedicationLog(
            medicationId: medication.id,
            scheduledTime: Date(),
            status: .taken
        )
        dataManager.logs.append(log)
        dataManager.saveData()
        presentationMode.wrappedValue.dismiss()
    }
    
    func registrarPospuesto() {
        let log = MedicationLog(
            medicationId: medication.id,
            scheduledTime: Date(),
            status: .snoozed
        )
        dataManager.logs.append(log)
        dataManager.saveData()
        presentationMode.wrappedValue.dismiss()
    }
    
    func registrarOmitido() {
        let log = MedicationLog(
            medicationId: medication.id,
            scheduledTime: Date(),
            status: .missed
        )
        dataManager.logs.append(log)
        dataManager.saveData()
        presentationMode.wrappedValue.dismiss()
    }
}
