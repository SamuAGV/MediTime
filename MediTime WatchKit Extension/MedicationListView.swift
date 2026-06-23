import SwiftUI

struct MedicationListView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddSheet = false
    @State private var selectedMedication: Medication?
    @State private var showingTakenAlert = false
    @State private var takenMessage = ""
    @State private var takenTitle = ""
    
    // Sheet personalizado
    @State private var showingOptionsSheet = false
    @State private var selectedMedicationForAction: Medication?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 12)
                
                // HEADER
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                        Text("Medicamentos")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    
                    Button(action: {
                        self.selectedMedication = nil
                        self.showingAddSheet = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            Text("Agregar")
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 4)
                
                // Lista de medicamentos
                Group {
                    if self.dataManager.medications.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "pills")
                                .font(.system(size: 36))
                                .foregroundColor(Color.gray.opacity(0.5))
                            Text("Sin medicamentos")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("Toca el botón verde para agregar")
                                .font(.system(size: 9))
                                .foregroundColor(Color.gray.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(self.dataManager.medications) { medication in
                                Button(action: {
                                    self.selectedMedicationForAction = medication
                                    self.showingOptionsSheet = true
                                }) {
                                    MedicationRow(medication: medication)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowBackground(Color.clear)
                            }
                        }
                        .background(Color.black.opacity(0.3))
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
        // ⚠️ SHEET PERSONALIZADO CON SCROLL
        .sheet(isPresented: $showingOptionsSheet) {
            OptionsSheetView(
                medication: self.selectedMedicationForAction,
                onTake: {
                    if let med = self.selectedMedicationForAction {
                        self.registerLog(med, status: .taken, message: "Has registrado la toma de \(med.name)")
                    }
                    self.showingOptionsSheet = false
                },
                onSnooze: {
                    if let med = self.selectedMedicationForAction {
                        self.registerLog(med, status: .snoozed, message: "Has pospuesto \(med.name) (10 min)")
                    }
                    self.showingOptionsSheet = false
                },
                onMiss: {
                    if let med = self.selectedMedicationForAction {
                        self.registerLog(med, status: .missed, message: "Has omitido \(med.name)")
                    }
                    self.showingOptionsSheet = false
                },
                onEdit: {
                    self.selectedMedication = self.selectedMedicationForAction
                    self.selectedMedicationForAction = nil
                    self.showingOptionsSheet = false
                    self.showingAddSheet = true
                },
                onDelete: {
                    if let med = self.selectedMedicationForAction {
                        print("Eliminando: \(med.name)")
                        self.dataManager.deleteMedication(med)
                        self.selectedMedicationForAction = nil
                    }
                    self.showingOptionsSheet = false
                },
                onCancel: {
                    self.selectedMedicationForAction = nil
                    self.showingOptionsSheet = false
                }
            )
        }
        .alert(isPresented: $showingTakenAlert) {
            Alert(
                title: Text(self.takenTitle),
                message: Text(self.takenMessage),
                dismissButton: .default(Text("OK")) {
                    self.selectedMedicationForAction = nil
                }
            )
        }
    }
    
    // MARK: - Registrar Log
    func registerLog(_ medication: Medication, status: MedicationLog.StatusType, message: String) {
        let log = MedicationLog(
            medicationId: medication.id,
            scheduledTime: Date(),
            status: status
        )
        self.dataManager.logs.append(log)
        self.dataManager.saveData()
        
        self.takenTitle = status == .taken ? "Registrado" :
                          status == .snoozed ? "Pospuesto" : "Omitido"
        self.takenMessage = message
        self.showingTakenAlert = true
        self.selectedMedicationForAction = nil
    }
}

// MARK: - Sheet Personalizado CON SCROLL
struct OptionsSheetView: View {
    let medication: Medication?
    let onTake: () -> Void
    let onSnooze: () -> Void
    let onMiss: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        // ⚠️ AGREGAR SCROLLVIEW PARA DESPLAZAR
        ScrollView {
            VStack(spacing: 14) {
                // Título
                Text(medication?.name ?? "Medicamento")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("Registra tu estado")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 20)
                
                // ⚠️ 3 OPCIONES DE ESTADO
                
                // 1. Tomar ahora (Verde)
                Button(action: onTake) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 18))
                        Text("Tomar ahora")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 2. Pospuesto (Naranja)
                Button(action: onSnooze) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))
                        Text("Pospuesto (10 min)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 3. Omitido (Rojo)
                Button(action: onMiss) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 18))
                        Text("Omitir")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 20)
                
                // 4. Editar (Azul)
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        Text("Editar")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 5. Eliminar (Rojo oscuro)
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                        Text("Eliminar")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 6. Cancelar
                Button(action: onCancel) {
                    Text("Cancelar")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.black.opacity(0.95))
    }
}

// MARK: - Fila de Medicamento
struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(medication.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("\(medication.dosage) \(medication.unit)")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray.opacity(0.8))
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(medication.times, id: \.self) { time in
                    Text(self.formatTime(time))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.blue.opacity(0.9))
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
