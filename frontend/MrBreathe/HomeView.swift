import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    private let api = UserManagementAPI()

    // Table data
    @State private var records: [RecordEntry] = []

    // Overlay animation state
    @State private var showRecordingOverlay: Bool = false
    @State private var overlayOffset: CGFloat = -2000
    @State private var isRecordingInProgress: Bool = false

    // Countdown
    @State private var countdown: Int = 5

    // Errors
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            header

                            actionButtons(screenHeight: geo.size.height)

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
                            Button("Log out") { session.logout() }
                                .disabled(isRecordingInProgress)
                        }
                    }

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
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mr. Breathe")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            if let prof = session.profile {
                Text("Hi, \(prof.first_name). Record a session or pair your device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Record a session or pair your device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }

    private func actionButtons(screenHeight: CGFloat) -> some View {
        VStack(spacing: 12) {
            Button {
                startRecordingAnimation(screenHeight: screenHeight)
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
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue))
            .shadow(radius: 10, y: 6)
            .disabled(isRecordingInProgress)
            .opacity(isRecordingInProgress ? 0.7 : 1.0)

            Button {
                // TODO: Bluetooth later
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
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 1))
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
                            Text(entry.data)
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
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .shadow(radius: 10, y: 6)
    }

    // MARK: - Recording Logic + Backend Predict

    private func startRecordingAnimation(screenHeight: CGFloat) {
        guard !isRecordingInProgress else { return }
        guard let email = session.email else {
            errorMessage = "No logged-in user email found."
            showError = true
            return
        }

        isRecordingInProgress = true
        countdown = 5
        showRecordingOverlay = true

        Task {
            // Countdown 5 → 0
            for t in stride(from: 5, through: 0, by: -1) {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) { countdown = t }
                }
                if t > 0 {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }

            // Slide overlay off-screen
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    overlayOffset = screenHeight
                }
            }
            try? await Task.sleep(nanoseconds: 650_000_000)

            // Hide overlay and add a row immediately
            let timestamp = Date()
            let newEntry = RecordEntry(timestamp: timestamp, data: "Analyzing…")

            await MainActor.run {
                showRecordingOverlay = false
                records.insert(newEntry, at: 0)
            }

            // Call backend gateway -> model
            // Mock breath data for now (must be non-empty per schema)
            let mockBreathData: [Double] = [1.0, 2.0, 3.0]

            do {
                let diagnosis = try await api.predict(email: email, breathData: mockBreathData)
                await MainActor.run {
                    // Update the newest record (index 0)
                    if !records.isEmpty {
                        records[0].data = diagnosis.isEmpty ? "N/A" : diagnosis
                    }
                    isRecordingInProgress = false
                }
            } catch {
                await MainActor.run {
                    if !records.isEmpty { records[0].data = "Error" }
                    errorMessage = error.localizedDescription
                    showError = true
                    isRecordingInProgress = false
                }
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
