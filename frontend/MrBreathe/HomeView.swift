//
//  HomeView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

struct HomeView: View {
    // Table data
    @State private var records: [RecordEntry] = []

    // Overlay animation state
    @State private var showRecordingOverlay: Bool = false
    @State private var overlayOffset: CGFloat = -2000 // will be set properly on appear
    @State private var isRecordingInProgress: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Main content
                    VStack(spacing: 12) {
                        Spacer()

                        Button("Record") {
                            startRecordingAnimation(screenHeight: geo.size.height)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isRecordingInProgress)

                        Button("Pair") {
                            // TODO: Bluetooth later
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRecordingInProgress)

                        // iOS List "table"
                        List {
                            if records.isEmpty {
                                Text("No recordings yet")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(records) { entry in
                                    HStack {
                                        Text(entry.timestamp.formatted(date: .abbreviated, time: .standard))
                                            .font(.subheadline)

                                        Spacer()

                                        Text(entry.data) // "N/A" for now
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Home")

                    // Recording overlay
                    if showRecordingOverlay {
                        ZStack {
                            Color.blue
                                .ignoresSafeArea()

                            Text("Recording now")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .offset(y: overlayOffset)
                        .onAppear {
                            // Start above the screen, then slide down to cover it
                            overlayOffset = -geo.size.height
                            withAnimation(.easeInOut(duration: 0.6)) {
                                overlayOffset = 0
                            }
                        }
                    }
                }
            }
        }
    }

    private func startRecordingAnimation(screenHeight: CGFloat) {
        guard !isRecordingInProgress else { return }
        isRecordingInProgress = true
        showRecordingOverlay = true

        Task {
            // Stay visible for 5 seconds
            try? await Task.sleep(nanoseconds: 5_000_000_000)

            // Slide the blue screen down and off the bottom
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    overlayOffset = screenHeight
                }
            }

            // Wait for the slide-out animation to finish
            try? await Task.sleep(nanoseconds: 650_000_000)

            // Hide overlay + add table row
            await MainActor.run {
                showRecordingOverlay = false
                isRecordingInProgress = false

                records.insert(
                    RecordEntry(timestamp: Date(), data: "N/A"),
                    at: 0
                )
            }
        }
    }
}
