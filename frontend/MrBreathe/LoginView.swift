//
//  LoginView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    private let api = UserManagementAPI()

    @State private var email: String = ""
    @State private var password: String = ""   // NOTE: backend YAML doesn’t expose login auth yet
    @State private var showSignUp: Bool = false

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Text("Mr. Breathe")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.blue)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    Text("Note: password verification will be enabled once the backend exposes a login endpoint.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 28)

                HStack(spacing: 18) {
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .buttonStyle(.bordered)

                    Button(isLoading ? "Logging in…" : "Log In") {
                        login()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
                .padding(.top, 6)

                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(session)
        }
        .alert("Login failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func login() {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.isEmpty else {
            errorMessage = "Please enter your email."
            showError = true
            return
        }

        isLoading = true

        Task {
            do {
                // “Login” for now = fetch profile. (Backend YAML has no /login yet.)
                let prof = try await api.getProfile(email: e)
                await MainActor.run {
                    session.email = e
                    session.profile = prof
                    session.isLoggedIn = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

