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
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var retryCount = 0
    private let maxRetries = 5
    private var floatBuffer = Data()
    private let floatSize = 4
    
    let serviceUUID = CBUUID(string: "FFE0")
    let characteristicUUID = CBUUID(string: "FFE1")
    
    
    @Published var message: String = "default"
    @Published var isConnected: Bool = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
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
                self.message = "Found device, connecting..."
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
            self.message = "Connected"
        }
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    /*
     * Runs when a connection fails or is dropped after being discovered
     * Retries connections without rescanning before retrying connections with rescanning
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if self.retryCount < self.maxRetries {
            self.retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + pow(2.0, Double(self.retryCount) - 1.0)) {
                if let peripheral = self.connectedPeripheral {
                    self.centralManager.connect(peripheral, options: nil)
                }
            }
        } else {
            self.retryCount = 0;
            DispatchQueue.main.async {
                self.isConnected = false
                self.message = "Failed to connect. Rescanning for peripherals."
            }
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
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
        self.floatBuffer.append(data)
        while (self.floatBuffer.count >= self.floatSize) {
            let floatData = self.floatBuffer.prefix(self.floatSize)
            let floatValue = floatData.withUnsafeBytes {
                buffer in buffer.load(as: Float.self)
            }
            
            DispatchQueue.main.async {
                self.message = String(format: "%.2f", floatValue)
            }
            self.floatBuffer.removeFirst(self.floatSize)
        }
        
        if self.floatBuffer.count > 100 {
            print("Buffer overflow")
            self.floatBuffer.removeAll(keepingCapacity: false)
        }
    }
    
    /*
     * Runs when a connection is lost
     * Sets the state to disconnected
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.message = "Disconnected"
        }
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
