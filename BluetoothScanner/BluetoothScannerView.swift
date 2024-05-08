//
//  ContentView.swift
//  Bluetooth-Scanner
//
//  Created by Thomas Ford on 5/3/24.
//

import SwiftUI
import CoreBluetooth

struct BluetoothScannerView: View {
    @ObservedObject private var bluetoothScanner = BluetoothScanner()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText)
                
                DiscoveredPeripheralsList(bluetoothScanner: bluetoothScanner, searchText: $searchText)
                
                ScanButton(bluetoothScanner: bluetoothScanner)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

struct DiscoveredPeripheralsList: View {
    @ObservedObject var bluetoothScanner: BluetoothScanner
    @Binding var searchText: String

    var filteredPeripherals: [DiscoveredPeripheral] {
        if searchText.isEmpty {
            return bluetoothScanner.sortedPeripherals
        } else {
            return bluetoothScanner.sortedPeripherals.filter {
                $0.peripheral.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    var body: some View {
        List(filteredPeripherals, id: \.peripheral.identifier) { discoveredPeripheral in
            NavigationLink(destination: PeripheralDetailView(peripheral: discoveredPeripheral)) {
                Text(discoveredPeripheral.peripheral.name ?? "Unknown Device")
            }
        }
    }
}

struct ScanButton: View {
    @ObservedObject var bluetoothScanner: BluetoothScanner
    
    var body: some View {
        Button(action: {
            if bluetoothScanner.isScanning {
                bluetoothScanner.stopScan()
            } else {
                bluetoothScanner.startScan()
            }
        }) {
            Text(bluetoothScanner.isScanning ? "Stop Scanning" : "Scan for Devices")
        }
    }
}

#Preview {
    BluetoothScannerView()
}
