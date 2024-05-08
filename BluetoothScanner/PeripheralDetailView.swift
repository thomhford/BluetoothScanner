//
//  PeripheralDetailView.swift
//  Bluetooth-Scanner
//
//  Created by Thomas Ford on 5/3/24.
//

import SwiftUI

struct PeripheralDetailView: View {
    var peripheral: DiscoveredPeripheral
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(peripheral.advertisedData)
                .font(.body)
                .padding(.bottom, 10)
            
            Spacer()
        }
        .padding()
        .navigationBarTitle(peripheral.peripheral.name ?? "Unknown Device", displayMode: .inline)
    }
}
