import SwiftUI
import CoreMotion
import CoreLocation
import AVFoundation

@main
struct SensorTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var sensorResults: [SensorResult] = []
    @State private var isTesting: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                List(sensorResults) { result in
                    SensorRow(result: result)
                }
                .listStyle(InsetGroupedListStyle())
                .padding()

                Button("Run Sensor Tests") {
                    runSensorTests()
                }
                .buttonStyle(GradientButtonStyle())
                .padding()
                .disabled(isTesting)
                .overlay(
                    isTesting ? ProgressView("Testing...") : nil
                )
            }
            .navigationTitle("Sensor Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    #if os(iOS)
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                    }
                    #endif
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use StackNavigationViewStyle for iPad
    }

    private func runSensorTests() {
        isTesting = true

        DispatchQueue.global(qos: .userInitiated).async {
            sensorResults = [
                SensorResult(id: UUID(), name: "Accelerometer", isWorking: testAccelerometer()),
                SensorResult(id: UUID(), name: "Gyroscope", isWorking: testGyroscope()),
                SensorResult(id: UUID(), name: "Magnetometer", isWorking: testMagnetometer()),
                SensorResult(id: UUID(), name: "Location Services", isWorking: testLocationServices()),
                SensorResult(id: UUID(), name: "Camera", isWorking: testCamera())
            ]

            DispatchQueue.main.async {
                isTesting = false
            }
        }
    }

    private func testAccelerometer() -> Bool {
        return CMMotionManager().isAccelerometerAvailable
    }

    private func testGyroscope() -> Bool {
        return CMMotionManager().isGyroAvailable
    }

    private func testMagnetometer() -> Bool {
        return CMMotionManager().isMagnetometerAvailable
    }

    private func testLocationServices() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    private func testCamera() -> Bool {
        return AVCaptureDevice.default(for: .video) != nil
    }
}

struct SensorRow: View {
    let result: SensorResult

    var body: some View {
        HStack {
            Text(result.name)
                .font(.headline)
                .foregroundColor(result.isWorking ? .green : .red)
            Spacer()
            Image(systemName: result.isWorking ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(result.isWorking ? .green : .red)
        }
        .padding(.vertical, 8)
    }
}

struct SensorResult: Identifiable {
    let id: UUID
    let name: String
    let isWorking: Bool
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10.0)
    }
}

#if os(iOS)
struct SettingsView: View {
    var body: some View {
        Text("Settings go here")
            .navigationTitle("Settings")
    }
}
#endif
