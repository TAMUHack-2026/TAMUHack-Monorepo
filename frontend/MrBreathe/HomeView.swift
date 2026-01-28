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
                    // Background
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()

                    // Main content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            header

                            actionButtons

                            recordingsCard
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarHidden(showRecordingOverlay)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                session.logout()
                            } label: {
                                Text("Log out")
                            }
                            .disabled(isRecordingInProgress)
                        }
                    }

                    // Recording overlay (same logic, nicer layout)
                    if showRecordingOverlay {
                        ZStack {
                            Color.blue.ignoresSafeArea()

                            VStack(spacing: 14) {
                                Text("Recording now")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)

                                CountdownNumber(countdown: countdown)

                                Text("Please breathe steadily for the full duration.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .offset(y: overlayOffset)
                        .onAppear {
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

    // MARK: - UI Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mr. Breathe")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            Text("Record a session or pair your device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                // same logic
                startRecordingAnimation(screenHeight: UIScreen.main.bounds.height)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Record")
                            .font(.headline)
                        Text("Start a 5-second recording")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
            )
            .shadow(radius: 10, y: 6)
            .disabled(isRecordingInProgress)
            .opacity(isRecordingInProgress ? 0.7 : 1.0)

            Button {
                // TODO later
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pair")
                            .font(.headline)
                        Text("Connect your spirometer")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .disabled(isRecordingInProgress)
            .opacity(isRecordingInProgress ? 0.7 : 1.0)
        }
    }

    private var recordingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Recordings")
                    .font(.headline)

                Spacer()

                Text("\(records.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Keep the List table, just styled inside a card
            Group {
                if records.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text("No recordings yet")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                } else {
                    List {
                        ForEach(records) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.timestamp.formatted(date: .abbreviated, time: .standard))
                                        .font(.subheadline)

                                    Text("Result")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(entry.data) // "N/A"
                                    .foregroundStyle(.secondary)
                            }
                            .listRowBackground(Color(.systemBackground))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 10, y: 6)
    }

    // MARK: - Logic (unchanged)

    private func startRecordingAnimation(screenHeight: CGFloat) {
        guard !isRecordingInProgress else { return }

        isRecordingInProgress = true
        countdown = 5
        showRecordingOverlay = true

        Task {
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

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    overlayOffset = screenHeight
                }
            }

            try? await Task.sleep(nanoseconds: 650_000_000)

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
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            } else {
                Text("\(countdown)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
    }
}
