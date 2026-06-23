#  MediTime - Aplicación de Recordatorios para Apple Watch

---

##  Descripción General

MediTime es una aplicación nativa para **Apple Watch** desarrollada con **SwiftUI** que ayuda a las personas a recordar la toma de sus medicamentos mediante recordatorios programados y un sistema de registro de cumplimiento.

---

## Características Principales

- **Panel de Control** con resumen diario de medicamentos
- **Gestión completa de medicamentos** (Crear, Leer, Actualizar, Eliminar)
- **Selección de días de toma** (Lunes a Domingo)
- **Múltiples horarios** por medicamento
- **Registro de cumplimiento** (Tomado, Pospuesto, Omitido)
- **Historial** de tomas agrupado por fecha
- **Estadísticas** con anillo de adherencia visual
- **Navegación por deslizamiento** (Swipe)
- **Notificaciones** programadas
- **Almacenamiento local** (UserDefaults)
- **Optimizado para Apple Watch**

---

##  Pantallas de la Aplicación

| Pantalla | Descripción |
|----------|-------------|
| **Panel de Control** | Resumen diario: próximo medicamento, adherencia, estadísticas rápidas |
| **Medicamentos** | Lista de medicamentos con opciones: Tomar, Pospuesto, Omitir, Editar, Eliminar |
| **Agregar/Editar** | Formulario para crear o modificar medicamentos |
| **Historial** | Registro de cumplimiento agrupado por fecha |
| **Estadísticas** | Porcentaje de adherencia, conteo de tomados, pospuestos y omitidos |

---

##  Requisitos del Sistema

- **macOS** 10.15.4 o superior
- **Xcode** 11.7 o superior
- **watchOS** 6.0 o superior
- **Apple Watch** Serie 3 o superior (para pruebas en dispositivo físico)

---

## Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/MediTime.git
cd MediTime
```

### 2. Abrir el proyecto en Xcode

```bash
open MediTime.xcodeproj
```

### 3. Configurar la firma de código

**Importante:** Para el simulador no es necesario firmar la aplicación.

1. Selecciona el objetivo "MediTime WatchKit App"
2. Ve a la sección "Signing & Capabilities"
3. **Desmarca** la opción "Automatically manage signing"
4. **Equipo:** Ninguno
5. **Identificador del paquete:** `com.tunombre.meditime`
6. **Perfil de aprovisionamiento:** Ninguno
7. **Certificado de firma:** No firmar código

8. Repite el proceso para el objetivo "MediTime WatchKit Extension"
9. **Identificador del paquete:** `com.tunombre.meditime.extension`

### 4. Seleccionar el simulador

En la barra superior de Xcode, selecciona:
```
Apple Watch Series 5 - 44mm (watchOS 6.1.1)
```

### 5. Ejecutar la aplicación

```bash
⌘ + R  (Cmd + R)
```

---

##  Estructura del Proyecto

```
MediTime/
├── MediTime WatchKit App/
│   ├── Assets.xcassets/            # Recursos gráficos
│   ├── Base.lproj/
│   │   └── Interface.storyboard    # Interfaz base
│   └── Info.plist                   # Configuración de la aplicación
│
├── MediTime WatchKit Extension/     # Código principal
│   ├── AddEditMedicationView.swift  # Formulario de medicamentos
│   ├── ComplicationController.swift # Complicaciones para esfera
│   ├── ContentView.swift            # Vista principal y navegación
│   ├── DataManager.swift            # Gestión de datos y persistencia
│   ├── ExtensionDelegate.swift      # Ciclo de vida de la extensión
│   ├── HistoryView.swift            # Historial de tomas
│   ├── HostingController.swift      # Controlador principal
│   ├── MedicationListView.swift     # Lista de medicamentos
│   ├── Models.swift                 # Modelos de datos
│   ├── NotificationController.swift # Controlador de notificaciones
│   ├── NotificationManager.swift    # Gestión de notificaciones
│   ├── NotificationView.swift       # Vista de notificaciones
│   ├── ReminderView.swift           # Vista de recordatorio
│   ├── StatisticsView.swift         # Estadísticas y gráficos
│   ├── Assets.xcassets/             # Recursos de la extensión
│   ├── Info.plist                   # Configuración de la extensión
│   └── PushNotificationPayload.apns # Ejemplo de notificación
│
├── MediTime.xcodeproj/              # Archivos del proyecto Xcode
│   ├── project.pbxproj
│   └── project.xcworkspace/
│
└── README.md                        # Este archivo
```

---

##  Guía de Uso

### Navegación por Deslizamiento

| Gesto | Acción |
|-------|--------|
| **Deslizar hacia la izquierda** | Avanzar a la siguiente pantalla |
| **Deslizar hacia la derecha** | Volver a la pantalla anterior |

### Pantalla de Medicamentos

Al tocar un medicamento, se abre un panel con las siguientes opciones:

| Opción | Acción |
|--------|--------|
| **Tomar ahora** | Registra la toma en el historial |
| **Pospuesto (10 min)** | Registra como pospuesto |
| **Omitir** | Registra como omitido |
| **Editar** | Abre el formulario de edición |
| **Eliminar** | Elimina el medicamento |

### Agregar un Medicamento

1. Navega a la pantalla **"Medicamentos"**
2. Toca el botón verde **"Agregar"**
3. Completa los campos del formulario:
   - **Nombre**: Ejemplo: Paracetamol
   - **Dosis**: Ejemplo: 500
   - **Unidad**: mg, g, ml, UI, gotas
   - **Días**: Selecciona los días de la semana
   - **Horarios**: Agrega una o más horas de toma
4. Toca **"Guardar"**

---

## ️ Tecnologías Utilizadas

- **SwiftUI** - Framework de interfaz de usuario
- **Combine** - Gestión de datos reactiva
- **UserDefaults** - Almacenamiento local persistente
- **UserNotifications** - Notificaciones programadas
- **ClockKit** - Complicaciones para la esfera del reloj

---

##  Próximas Mejoras

- [ ] Sincronización con iCloud
- [ ] Complicaciones en la esfera del reloj
- [ ] Soporte para Siri Shortcuts
- [ ] Exportar historial a PDF
- [ ] Notificaciones personalizables
- [ ] Modo oscuro
- [ ] Soporte para múltiples idiomas

---

##  Contribución

Si deseas contribuir al proyecto:

1. Haz un **Fork** del repositorio
2. Crea una rama para tu funcionalidad (`git checkout -b feature/NuevaFuncionalidad`)
3. Realiza tus cambios y haz **Commit** (`git commit -m 'Agrega nueva funcionalidad'`)
4. Sube tus cambios (`git push origin feature/NuevaFuncionalidad`)
5. Abre un **Pull Request**

---

##  Licencia

Este proyecto está bajo la Licencia MIT.

---

## ‍ Autor

**Samuel Garduño**

**Ana Colin**

**Brenda Gutierrez**
---

##  Contacto

Si tienes preguntas o sugerencias, no dudes en abrir un issue en el repositorio.

---

**MediTime - Tu salud al día** 
