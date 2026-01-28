//
//  HomeView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager

    // Table data
    @State private var records: [RecordEntry] = []

    // Overlay animation state
    @State private var showRecordingOverlay: Bool = false
    @State private var overlayOffset: CGFloat = -2000
    @State private var isRecordingInProgress: Bool = false

    // Countdown
    @State private var countdown: Int = 5

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
                            // TODO: Bluetooth pairing later
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
                    .navigationBarHidden(showRecordingOverlay) // ✅ hides the "Home" title during recording
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Log out") {
                                session.logout()
                            }
                            .disabled(isRecordingInProgress)
                        }
                    }

                    // Recording overlay
                    if showRecordingOverlay {
                        ZStack {
                            Color.blue
                                .ignoresSafeArea()

                            VStack(spacing: 12) {
                                Text("Recording now")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)

                                CountdownNumber(countdown: countdown)
                            }
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
        countdown = 5
        showRecordingOverlay = true

        Task {
            // Count down 5 → 0 (updates once per second)
            for t in stride(from: 5, through: 0, by: -1) {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        countdown = t
                    }
                }
                if t > 0 {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }

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

private struct CountdownNumber: View {
    let countdown: Int

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Text("\(countdown)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            } else {
                Text("\(countdown)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
    }
}
