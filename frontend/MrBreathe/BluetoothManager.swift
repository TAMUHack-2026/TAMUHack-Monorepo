//
//  BluetoothManager.swift
//  MrBreathe
//
//  Created by K Panchal on 1/25/26.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Bluetooth handlers
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    // UUIDs for bluetooth device
    let serviceUUID = CBUUID(string: "FFE0")
    let characteristicUUID = CBUUID(string: "FFE1")
    
    // Retry variables
    private var retryCount = 0
    private let maxRetries = 5
    
    // Buffer handles raw byte data
    private var floatBuffer = Data()
    private let floatSize = 4
    
    // Array handles actual processed floats
    @Published private(set) var bluetoothData: [Float] = []
    @Published private var receivingData = false
    
    // Published external data for UI purposes
    @Published var message: String = "Initialized"
    @Published var isConnected: Bool = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Class methods
    func isReceivingData() -> Bool {
        return self.receivingData
    }
    // Toggle receiving data on or off
    func toggleReception() {
        self.receivingData.toggle()
    }
    // Clear bluetooth data
    func clearBluetoothData() {
        self.bluetoothData.removeAll(keepingCapacity: false)
    }
    
    // BLUETOOTH METHODS DO NOT TOUCH
    
    /*
     * Fires when app turns on and on Bluetooth state changes
     * Checks for on status and scans for peripheral devices with the service UUID
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    /*
     * Called for every Bluetooth device discovered during the scanning process
     * Repeatedly search for a device with a "?" in its name, connect to it when found, and then stop firing
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name?.contains("?") ?? false) {
            self.connectedPeripheral = peripheral
            self.centralManager.connect(peripheral, options: nil)
            DispatchQueue.main.async {
                self.message = "Connecting..."
            }
            self.centralManager.stopScan()
        }
    }
    
    /*
     * Called when a connection is initiated
     * Sets observed variable states
     * Sets peripheral to notify this class of updates and finds its available services
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.message = "Connected!"
        }
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    /*
     * Called when the central device wants to find available services
     * Retrieves list of services from the device and finds its characteristics, subscribing to the ones with the specified UUID
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    /*
     * Called when finding the characteristics of a peripheral service
     * Enbables notifications for each valid service
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    /*
     * Fires when a characteristic's value changes
     * Converts the value to a string and sets the message property to it
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        // Only add data if it's being received
        if self.receivingData {
            self.floatBuffer.append(data)
            self.message = "Receiving Data..."
        }
        
        while self.floatBuffer.count >= self.floatSize {
            let floatData = self.floatBuffer.prefix(self.floatSize)
            let floatValue = floatData.withUnsafeBytes {
                buffer in buffer.load(as: Float.self)
            }
            
            // Add parsed float data
            self.bluetoothData.append(floatValue)
            
            // Remove parsed float from buffer
            self.floatBuffer.removeFirst(self.floatSize)
        }
        
        self.message = "Connected!"
        // Clear buffer on overflow
        if self.floatBuffer.count > 100 {
            print("Buffer overflow")
            self.floatBuffer.removeAll(keepingCapacity: false)
        }
        
        // Clear buffer when data isn't being received anymore
        if !self.receivingData {
            self.floatBuffer.removeAll(keepingCapacity: false)
        }
    }
    
    /*
     * Helper function to retry a bluetooth connection
     * First tries retrying without a rescan
     * Then rescans all connections and then retries
     */
    func retryConnection() {
        // Retry first without rescan
        if self.retryCount < self.maxRetries {
            self.retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + pow(2.0, Double(self.retryCount) - 1.0)) {
                if let peripheral = self.connectedPeripheral {
                    self.centralManager.connect(peripheral, options: nil)
                }
            }
        } else { // Retry with rescan
            self.retryCount = 0;
            DispatchQueue.main.async {
                self.isConnected = false
                self.message = "Rescanning..."
            }
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    /*
     * Runs when a connection is lost
     * Sets the state to disconnected
     * Retries connections without rescanning before retrying connections with rescanning
     * Only attempts retries if the connection was done erroneously
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.message = "Disconnected"
        }
        // Skip retry if the disconnect was done intentionally
        if error == nil {
            return
        }
        
        if self.retryCount < self.maxRetries {
            self.retryConnection()
        }
    }
    
    /*
     * Runs when a connection fails or is dropped after being discovered
     * Retries connections without rescanning before retrying connections with rescanning
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.retryConnection()
    }
    
//    /*
//     * Restores existing connections and states
//     */
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
//            for peripheral in peripherals {
//                self.connectedPeripheral = peripheral
//                peripheral.delegate = self
//                
//                if peripheral.state == .connected {
//                    DispatchQueue.main.async {
//                        self.isConnected = true
//                        self.message = "Connection restored"
//                    }
//                }
//                peripheral.discoverServices([serviceUUID])
//            }
//        }
//    }
}
