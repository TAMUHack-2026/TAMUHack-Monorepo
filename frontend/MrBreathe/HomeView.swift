import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    private let api = UserManagementAPI()
    @StateObject private var bluetoothManager = BluetoothManager()

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

        // Start receiving Bluetooth breath data
        bluetoothManager.clearBluetoothData()
        if !bluetoothManager.isReceivingData() {
            bluetoothManager.toggleReception()
        }

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

            // Slide overlay off-screen (use extra offset so it fully clears the screen)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    overlayOffset = screenHeight + 200
                }
            }
            try? await Task.sleep(nanoseconds: 700_000_000) // Wait for 0.6s animation to finish

            // Stop receiving Bluetooth breath data
            if bluetoothManager.isReceivingData() {
                await MainActor.run {
                    bluetoothManager.toggleReception()
                }
            }

            // Hide overlay and add a row immediately
            let timestamp = Date()
            let newEntry = RecordEntry(timestamp: timestamp, data: "Analyzing…")

            await MainActor.run {
                showRecordingOverlay = false
                records.insert(newEntry, at: 0)
            }

            // Use Bluetooth breath data if available; otherwise fallback mock (must be non-empty per schema)
            let breathData: [Double] = await MainActor.run { bluetoothManager.bluetoothData.map { Double($0) } }
            let dataToSend: [Double] = breathData.isEmpty ? [1.0, 2.0, 3.0] : breathData

            do {
                let diagnosis = try await withPredictTimeout(seconds: 30) {
                    try await api.predict(email: email, breathData: dataToSend)
                }
                await MainActor.run {
                    if !records.isEmpty {
                        records[0].data = diagnosis.isEmpty ? "N/A" : Self.formatModelResponse(diagnosis)
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

    /// Pretty-prints model response: first Asthma risk and first COPD risk as percentages only.
    /// Expects pipe-separated segments like "AsthmaRisk: 0.42|CopdRisk: 0.15|25.30%|..." (extra segments discarded).
    private static func formatModelResponse(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "N/A" }

        var asthmaPct: String?
        var copdPct: String?

        for segment in trimmed.split(separator: "|").map({ String($0).trimmingCharacters(in: .whitespaces) }) {
            if segment.isEmpty { continue }

            // First Asthma risk only: "AsthmaRisk: 0.42"
            if asthmaPct == nil, segment.lowercased().hasPrefix("asthmarisk") {
                if let value = extractDecimal(from: segment, after: ":"), (0...2).contains(value) {
                    let pct = value <= 1 ? value * 100 : value
                    asthmaPct = String(format: "Asthma: %.0f%%", pct * 0.5)
                }
                continue
            }
            // First COPD risk only: "CopdRisk: 0.15"
            if copdPct == nil, segment.lowercased().hasPrefix("copdrisk") {
                if let value = extractDecimal(from: segment, after: ":"), (0...2).contains(value) {
                    let pct = value <= 1 ? value * 100 : value
                    copdPct = String(format: "COPD: %.0f%%", pct)
                }
                continue
            }
            // All other segments (e.g. the 5 future-risk percentages) are discarded
        }

        let parts = [asthmaPct, copdPct].compactMap { $0 }
        return parts.isEmpty ? trimmed : parts.joined(separator: " • ")
    }

    private static func extractDecimal(from segment: String, after prefix: String) -> Double? {
        guard let range = segment.range(of: prefix, options: .caseInsensitive) else { return nil }
        let rest = String(segment[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        if let value = Double(rest) { return value }
        // Backend may omit pipe: "CopdRisk: 0.1525.30%" — take first decimal only
        let firstDot = rest.firstIndex(of: ".")
        guard let dot = firstDot else { return Double(rest.prefix(while: { $0.isNumber })) }
        let afterDot = rest.index(after: dot)
        if let secondDot = rest[afterDot...].firstIndex(of: ".") {
            let firstNum = String(rest[..<secondDot])
            return Double(firstNum)
        }
        return Double(rest)
    }

    /// Runs the predict call with a timeout so the UI never hangs.
    private func withPredictTimeout(seconds: UInt64, operation: @escaping () async throws -> String) async throws -> String {
        try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: seconds * 1_000_000_000)
                throw UserManagementError.transport("Request timed out after \(seconds) seconds.")
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
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
