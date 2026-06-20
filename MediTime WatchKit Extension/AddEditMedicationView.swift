import SwiftUI

struct AddEditMedicationView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    var medication: Medication?
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var unit = "mg"
    @State private var times: [Date] = []
    @State private var showingTimePicker = false
    @State private var selectedTimeIndex = 0
    @State private var selectedDays: [Bool] = [true, true, true, true, true, true, true]
    
    let daysOfWeek = ["L", "M", "M", "J", "V", "S", "D"]
    let units = ["mg", "g", "ml", "UI", "gotas"]
    
    init(dataManager: DataManager, medication: Medication?) {
        self.dataManager = dataManager
        self.medication = medication
        
        if let med = medication {
            _name = State(initialValue: med.name)
            _dosage = State(initialValue: med.dosage)
            _unit = State(initialValue: med.unit)
            _times = State(initialValue: med.times)
            if let days = med.selectedDays {
                _selectedDays = State(initialValue: days)
            }
        } else {
            let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            _times = State(initialValue: [defaultTime])
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 10) {
                    // Título
                    Text(self.medication == nil ? "➕ Nuevo" : "✏️ Editar")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.top, 6)
                    
                    // Campos del formulario
                    VStack(spacing: 8) {
                        // Nombre
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nombre")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            TextField("Ej: Paracetamol", text: self.$name)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(6)
                                .background(Color.gray.opacity(0.12))
                                .cornerRadius(6)
                                .font(.system(size: 13))
                        }
                        
                        // Dosis
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dosis")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            HStack(spacing: 6) {
                                TextField("Cantidad", text: self.$dosage)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(6)
                                    .background(Color.gray.opacity(0.12))
                                    .cornerRadius(6)
                                    .font(.system(size: 13))
                                    .frame(width: 70)
                                
                                Picker("Unidad", selection: self.$unit) {
                                    ForEach(self.units, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .frame(width: 50)
                                .labelsHidden()
                                .font(.system(size: 11))
                            }
                        }
                        
                        // Días de la semana
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Días")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<7, id: \.self) { index in
                                    Button(action: {
                                        self.selectedDays[index].toggle()
                                    }) {
                                        Text(self.daysOfWeek[index])
                                            .font(.system(size: 10, weight: self.selectedDays[index] ? .bold : .regular))
                                            .frame(width: 24, height: 24)
                                            .background(self.selectedDays[index] ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(self.selectedDays[index] ? .white : .gray)
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Horarios
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Horarios")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            
                            ForEach(0..<self.times.count, id: \.self) { index in
                                HStack {
                                    Text("Hora \(index + 1):")
                                        .font(.system(size: 10))
                                    Spacer()
                                    Text(self.formatTime(self.times[index]))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.blue)
                                    
                                    Button(action: {
                                        self.selectedTimeIndex = index
                                        self.showingTimePicker = true
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Button(action: {
                                        self.times.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            
                            Button(action: {
                                let newTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                                self.times.append(newTime)
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Agregar hora")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.blue)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Botones
                    VStack(spacing: 6) {
                        Button(action: {
                            self.saveMedication()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Guardar")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(self.name.isEmpty || self.dosage.isEmpty || self.times.isEmpty ?
                                        Color.gray.opacity(0.3) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(self.name.isEmpty || self.dosage.isEmpty || self.times.isEmpty)
                        
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
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, 4)
            }
        }
        .sheet(isPresented: self.$showingTimePicker) {
            TimePickerView(times: self.$times, index: self.selectedTimeIndex)
        }
    }
    
    func saveMedication() {
        let newMedication = Medication(
            id: self.medication?.id ?? UUID(),
            name: self.name,
            dosage: self.dosage,
            unit: self.unit,
            times: self.times,
            selectedDays: self.selectedDays,
            isActive: true
        )
        
        if self.medication != nil {
            self.dataManager.updateMedication(newMedication)
        } else {
            self.dataManager.addMedication(newMedication)
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Time Picker optimizado para Watch
struct TimePickerView: View {
    @Binding var times: [Date]
    let index: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHour = 8
    @State private var selectedMinute = 0
    
    init(times: Binding<[Date]>, index: Int) {
        self._times = times
        self.index = index
        
        let time = times.wrappedValue[index]
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        _selectedHour = State(initialValue: components.hour ?? 8)
        _selectedMinute = State(initialValue: components.minute ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Seleccionar Hora")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 8)
            
            HStack {
                Picker("Hora", selection: self.$selectedHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                .frame(width: 50)
                .labelsHidden()
                .font(.system(size: 14))
                
                Text(":")
                    .font(.system(size: 18, weight: .bold))
                
                Picker("Minuto", selection: self.$selectedMinute) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .frame(width: 50)
                .labelsHidden()
                .font(.system(size: 14))
            }
            
            HStack(spacing: 16) {
                Button("Cancelar") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 11))
                .foregroundColor(.gray)
                
                Button("Aceptar") {
                    let calendar = Calendar.current
                    var components = DateComponents()
                    components.hour = self.selectedHour
                    components.minute = self.selectedMinute
                    
                    if let newTime = calendar.date(from: components) {
                        self.times[self.index] = newTime
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.blue)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
    }
}
