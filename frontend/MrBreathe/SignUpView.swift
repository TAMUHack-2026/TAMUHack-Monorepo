//
//  SignUpView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    private let api = UserManagementAPI()

    @State private var email: String = ""
    @State private var password: String = ""

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var heightIn: String = ""
    @State private var weightLbs: String = ""
    @State private var age: String = ""
    @State private var sex: SexOption = .select
    @State private var genderIdentity: String = ""

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    enum SexOption: String, CaseIterable, Identifiable {
        case select = "Select"
        case male = "male"
        case female = "female"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 16) {
                    Spacer()

                    Text("Create Account")
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

                        TextField("First Name", text: $firstName)
                            .textFieldStyle(.roundedBorder)

                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(.roundedBorder)

                        HStack(spacing: 10) {
                            TextField("Height (in)", text: $heightIn)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            TextField("Weight (lbs)", text: $weightLbs)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            TextField("Age", text: $age)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack(spacing: 10) {
                            Picker("", selection: $sex) {
                                ForEach(SexOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )

                            TextField("Gender Identity (optional)", text: $genderIdentity)
                                .textFieldStyle(.roundedBorder)
                        }

                        Button(isLoading ? "Creating…" : "Create Account") {
                            createAccount()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 22)

                    Spacer()
                    Spacer()
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Couldn’t create account", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func createAccount() {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let fn = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let ln = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !e.isEmpty else { fail("Email is required."); return }
        guard !p.isEmpty else { fail("Password is required."); return }
        guard !fn.isEmpty else { fail("First name is required."); return }
        guard !ln.isEmpty else { fail("Last name is required."); return }

        guard let h = Double(heightIn), h > 0 else { fail("Height must be a positive number."); return }
        guard let w = Double(weightLbs), w > 0 else { fail("Weight must be a positive number."); return }
        guard let a = Int(age), (0...150).contains(a) else { fail("Age must be between 0 and 150."); return }
        guard sex != .select else { fail("Please select sex (male or female)."); return }

        let gi = genderIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
        let req = UserCreateRequest(
            email: e,
            password: p,
            first_name: fn,
            last_name: ln,
            age: a,
            sex: sex.rawValue,
            gender_identity: gi.isEmpty ? nil : gi,
            height_in: h,
            weight_lbs: w
        )

        isLoading = true

        Task {
            do {
                try await api.createUser(req)

                // Auto-login: fetch profile & set session
                let prof = try await api.getProfile(email: e)

                await MainActor.run {
                    session.email = e
                    session.profile = prof
                    session.isLoggedIn = true
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    fail(error.localizedDescription)
                }
            }
        }
    }

    private func fail(_ msg: String) {
        errorMessage = msg
        showError = true
    }
}
