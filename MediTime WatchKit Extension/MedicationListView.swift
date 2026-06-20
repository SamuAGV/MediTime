import SwiftUI

struct MedicationListView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddSheet = false
    @State private var selectedMedication: Medication?
    @State private var showingDeleteAlert = false
    @State private var medicationToDelete: Medication?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // ⚠️ ESPACIO SUPERIOR EN MEDICAMENTOS
                Spacer()
                    .frame(height: 6)
                
                // Header
                HStack {
                    Image(systemName: "pills.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Medicamentos")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Button(action: {
                        self.selectedMedication = nil
                        self.showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
                
                Group {
                    if self.dataManager.medications.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "pills")
                                .font(.system(size: 36))
                                .foregroundColor(Color.gray.opacity(0.5))
                            Text("Sin medicamentos")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(self.dataManager.medications) { medication in
                                MedicationCard(medication: medication,
                                             onEdit: {
                                                self.selectedMedication = medication
                                                self.showingAddSheet = true
                                             },
                                             onDelete: {
                                                self.medicationToDelete = medication
                                                self.showingDeleteAlert = true
                                             })
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditMedicationView(dataManager: self.dataManager,
                                medication: self.selectedMedication)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Eliminar"),
                message: Text("¿Eliminar \(self.medicationToDelete?.name ?? "")?"),
                primaryButton: .destructive(Text("Eliminar")) {
                    if let med = self.medicationToDelete {
                        self.dataManager.deleteMedication(med)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct MedicationCard: View {
    let medication: Medication
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "pill.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(medication.name)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    Text("\(medication.dosage) \(medication.unit)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    ForEach(medication.times, id: \.self) { time in
                        Text(self.formatTime(time))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 10))
                        Text("Editar")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                        Text("Eliminar")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
