import SwiftUI
import CoreBluetooth

// Bluetooth Manager Delegate
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredDevices: [String] = []
    private var centralManager: CBCentralManager!

    // Define the specific service UUID to filter devices
    let targetUUID = CBUUID(string: "B0FB") // Replace with your desired UUID
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("Central Manager initialized")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Check Bluetooth state
        if central.state == .poweredOn {
            // Start scanning for devices with the specific service UUID
            centralManager.scanForPeripherals(withServices: [targetUUID], options: nil)
            print("Scanning for peripherals with target UUID...")
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the peripheral's advertised services include the target UUID
        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID], serviceUUIDs.contains(targetUUID) {
            if let name = peripheral.name, !discoveredDevices.contains(name) {
                discoveredDevices.append(name)
                print("Discovered: \(name) with UUID \(targetUUID)")
            }
        }
    }
}

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    Text("TPMS App")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                        .bold()

                    Image("Image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(45.0)
                        .padding(.all, 25.0)

                    // Button with capsule style
                    NavigationLink(destination: ConnectionView(bluetoothManager: bluetoothManager)) {
                        Text("Start Pairing")
                            .font(.title)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.horizontal, 30) // Horizontal padding within capsule
                            .padding(.vertical, 10)  // Vertical padding within capsule
                    }
                    .background(
                        Capsule()
                            .fill(Color(red: 234/255, green: 201/255, blue: 67/255, opacity: 1.0))
                    )
                    .buttonStyle(PlainButtonStyle()) // Ensures no additional button styles are applied
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.black)
            }
            .navigationBarHidden(true)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ConnectionView: View {
    @ObservedObject var bluetoothManager: BluetoothManager

    var body: some View {
        VStack {
            Text("Available Devices")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .padding()

            // Displaying the list of discovered devices
            List(bluetoothManager.discoveredDevices, id: \.self) { device in
                Text(device)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            .listStyle(PlainListStyle()) // Use plain list style for aesthetic preference

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

