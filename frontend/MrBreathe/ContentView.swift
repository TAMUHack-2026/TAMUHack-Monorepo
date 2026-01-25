//
//  ContentView.swift
//  MrBreathe
//
//  Created by K Panchal on 1/25/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    var body: some View {
        VStack {
            Text(bluetoothManager.message)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
