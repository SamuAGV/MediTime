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
        ScrollView {
            VStack(spacing: 16) {
                Text(medication == nil ? "➕ Nuevo Medicamento" : "✏️ Editar Medicamento")
                    .font(.headline)
                    .padding(.top)
                
                VStack(spacing: 12) {
                    // Nombre
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nombre")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Ej: Paracetamol", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    // Dosis
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dosis")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            TextField("Cantidad", text: $dosage)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            
                            Picker("Unidad", selection: $unit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .frame(width: 70)
                            .labelsHidden()
                        }
                    }
                    
                    // Días de la semana
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Días de toma")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { index in
                                Button(action: {
                                    self.selectedDays[index].toggle()
                                }) {
                                    Text(self.daysOfWeek[index])
                                        .font(.system(size: 12, weight: self.selectedDays[index] ? .bold : .regular))
                                        .frame(width: 28, height: 28)
                                        .background(self.selectedDays[index] ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(self.selectedDays[index] ? .white : .gray)
                                        .cornerRadius(14)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Horarios
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Horarios")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ForEach(0..<times.count, id: \.self) { index in
                            HStack {
                                Text("Hora \(index + 1):")
                                    .font(.caption)
                                Spacer()
                                Text(self.formatTime(self.times[index]))
                                    .font(.body)
                                    .foregroundColor(.blue)
                                
                                Button(action: {
                                    self.selectedTimeIndex = index
                                    self.showingTimePicker = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                }
                                
                                Button(action: {
                                    self.times.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Button(action: {
                            let newTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                            self.times.append(newTime)
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Agregar hora")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Botón Guardar
                    Button(action: {
                        self.saveMedication()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Guardar")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(self.name.isEmpty || self.dosage.isEmpty || self.times.isEmpty ?
                                    Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(self.name.isEmpty || self.dosage.isEmpty || self.times.isEmpty)
                    .padding(.top, 8)
                    
                    // Botón Cancelar
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancelar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(times: self.$times, index: self.selectedTimeIndex)
        }
    }
    
    func saveMedication() {
        let newMedication = Medication(
            id: medication?.id ?? UUID(),
            name: name,
            dosage: dosage,
            unit: unit,
            times: times,
            selectedDays: selectedDays,
            isActive: true
        )
        
        if medication != nil {
            dataManager.updateMedication(newMedication)
        } else {
            dataManager.addMedication(newMedication)
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

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
        VStack(spacing: 16) {
            Text("Seleccionar Hora")
                .font(.headline)
            
            HStack {
                Picker("Hora", selection: $selectedHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text("\(hour)h").tag(hour)
                    }
                }
                .frame(width: 70)
                .labelsHidden()
                
                Text(":")
                    .font(.title)
                
                Picker("Minuto", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text("\(minute)min").tag(minute)
                    }
                }
                .frame(width: 70)
                .labelsHidden()
            }
            
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
            .foregroundColor(.blue)
            
            Button("Cancelar") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
    }
}
