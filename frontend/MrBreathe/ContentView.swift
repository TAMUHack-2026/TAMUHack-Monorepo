//
//  ContentView.swift
//  MrBreathe
//
//  Created by K Panchal on 1/25/26.
//

import SwiftUI

// Main page content
struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isRecording: Bool = false
    
    func onRecord() {
        isRecording = true
    }
    
    var body: some View {
        // Bluetooth Connection Status
        VStack {
            Text("Bluetooth Connection Status: \(bluetoothManager.message)")
                .outlined(size: .small)
            
            Button(action: onRecord) {
                Text("Record")
            }
            .highlighted(size: .small)
            .sheet(isPresented: $isRecording) {
                RecordingModal()
            }
        }
        .padding()
    }
}

// Recording modal popup
struct RecordingModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var isRecording: Bool = false
    @State private var countdownTime: UInt8 = 5
    @State private var countdownTimer: Timer?

    // Reset timer state helper function
    func resetTimerState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdownTime = 5
        }
    }
    // Handle starting the recording timer
    func handleRecording() {
        if (!isRecording) {
            isRecording.toggle()
            countdownTime = 5
            
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdownTime > 0 {
                    countdownTime -= 1
                } else {
                    timer.invalidate()
                    isRecording.toggle()
                    // Reset state after 1 second
                    resetTimerState()
                }
            }
        } else {
            // Reset state after stopping
            countdownTimer?.invalidate()
            countdownTimer = nil
            isRecording.toggle()
            // Reset timer after 1 second
            resetTimerState()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("\(countdownTime)")
                    .font(.system(size: 100).bold())
                    .padding(10)
                    .foregroundStyle(Color.white)
                Button(action: handleRecording) {
                    Text(isRecording ? "Stop" : "Record")
                }
                .highlightedInverted(size: .small)
            }
            .frame(maxWidth: 350)
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
        .background(Color.blue)

    }
}

#Preview {
    ContentView()
}
