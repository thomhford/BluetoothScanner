//
//  BluetoothScannerClass.swift
//  Bluetooth-Scanner
//
//  Created by Thomas Ford on 5/3/24.
//

import SwiftUI
import CoreBluetooth

struct DiscoveredPeripheral {
    var peripheral: CBPeripheral
    var advertisedData: String
    var rssi: NSNumber
}

class BluetoothScanner: NSObject, ObservableObject {
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = []
    @Published var isScanning = false
    private var discoveredPeripheralSet: Set<CBPeripheral> = []
    private var timer: Timer?
    private var centralManager: CBCentralManager!
    var sortedPeripherals: [DiscoveredPeripheral] {
        discoveredPeripherals.sorted {
            switch ($0.peripheral.name, $1.peripheral.name) {
            case (let name1?, let name2?): return name1 < name2
            case (nil, _): return false
            case (_, nil): return true
            }
        }
    }

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        if !isScanning {
            isScanning = true
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                self?.rescan()
            }
        }
    }

    func stopScan() {
        isScanning = false
        timer?.invalidate()
        centralManager.stopScan()
    }

    private func rescan() {
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: nil)
    }
}

extension BluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            stopScan()
        } else {
            startScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let advertisedData = formatAdvertisedData(advertisementData)
        updatePeripheral(peripheral, with: advertisedData, rssi: RSSI)
    }

    private func formatAdvertisedData(_ data: [String: Any]) -> String {
        let sortedData = data.map { "\($0): \($1)" }.sorted(by: { $0 < $1 }).joined(separator: "\n")
        let timestampValue = data["kCBAdvDataTimestamp"] as! Double
        let dateString = DateFormatter().formatTimestamp(timestampValue)
        return "Timestamp: \(dateString)\n" + sortedData
    }

    private func updatePeripheral(_ peripheral: CBPeripheral, with data: String, rssi: NSNumber) {
        if discoveredPeripheralSet.insert(peripheral).inserted {
            discoveredPeripherals.append(DiscoveredPeripheral(peripheral: peripheral, advertisedData: data, rssi: rssi))
        } else if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
            discoveredPeripherals[index].advertisedData = data
        }
        objectWillChange.send()
    }
}

extension DateFormatter {
    func formatTimestamp(_ timestamp: Double) -> String {
        self.dateFormat = "HH:mm:ss"
        return self.string(from: Date(timeIntervalSince1970: timestamp))
    }
}
