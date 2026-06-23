import SwiftUI

// Enum para controlar qué sheet mostrar
enum SheetType: Identifiable {
    case add
    case options(Medication)
    
    var id: Int {
        switch self {
        case .add: return 0
        case .options: return 1
        }
    }
}

struct MedicationListView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedMedication: Medication?
    @State private var showingTakenAlert = false
    @State private var takenMessage = ""
    @State private var takenTitle = ""
    
    // UN SOLO STATE para controlar el sheet
    @State private var activeSheet: SheetType?
    
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
                        print("🟢 Botón Agregar presionado")
                        self.activeSheet = .add
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
                                    print("🟡 Medicamento seleccionado: \(medication.name)")
                                    self.activeSheet = .options(medication)
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
        // ⚠️ SHEET - Usando una función separada para evitar switch en ViewBuilder
        .sheet(item: $activeSheet) { sheet in
            self.sheetContent(for: sheet)
        }
        .alert(isPresented: $showingTakenAlert) {
            Alert(
                title: Text(self.takenTitle),
                message: Text(self.takenMessage),
                dismissButton: .default(Text("OK")) {
                    self.activeSheet = nil
                }
            )
        }
    }
    
    // ⚠️ FUNCIÓN SEPARADA - Evita el switch en el ViewBuilder
    func sheetContent(for sheet: SheetType) -> some View {
        if sheet.id == 0 {
            // Caso .add
            return AnyView(AddEditMedicationView(dataManager: self.dataManager, medication: nil))
        } else {
            // Caso .options
            if case .options(let medication) = sheet {
                return AnyView(
                    OptionsSheetView(
                        medication: medication,
                        onTake: {
                            self.registerLog(medication, status: .taken, message: "Has registrado la toma de \(medication.name)")
                            self.activeSheet = nil
                        },
                        onSnooze: {
                            self.registerLog(medication, status: .snoozed, message: "Has pospuesto \(medication.name) (10 min)")
                            self.activeSheet = nil
                        },
                        onMiss: {
                            self.registerLog(medication, status: .missed, message: "Has omitido \(medication.name)")
                            self.activeSheet = nil
                        },
                        onEdit: {
                            self.activeSheet = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.selectedMedication = medication
                                self.activeSheet = .add
                            }
                        },
                        onDelete: {
                            print("🗑️ Eliminando: \(medication.name)")
                            self.dataManager.deleteMedication(medication)
                            self.activeSheet = nil
                        },
                        onCancel: {
                            self.activeSheet = nil
                        }
                    )
                )
            } else {
                return AnyView(EmptyView())
            }
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
    }
}

// MARK: - Sheet Personalizado con 3 Opciones de Estado
struct OptionsSheetView: View {
    let medication: Medication
    let onTake: () -> Void
    let onSnooze: () -> Void
    let onMiss: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text(medication.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("Registra tu estado")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 20)
                
                // Tomar ahora (Verde)
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
                
                // Pospuesto (Naranja)
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
                
                // Omitido (Rojo)
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
                
                // Editar (Azul)
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
                
                // Eliminar (Rojo oscuro)
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
                
                // Cancelar
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
