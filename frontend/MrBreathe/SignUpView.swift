//
//  SignUpView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var heightIn: String = ""
    @State private var weightLbs: String = ""
    @State private var age: String = ""
    @State private var sex: SexOption = .select
    @State private var genderIdentity: String = ""

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

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

                            TextField("Gender Identity", text: $genderIdentity)
                                .textFieldStyle(.roundedBorder)
                        }

                        Button("Create Account") {
                            if validate() {
                                // TODO: replace with real signup API call
                                dismiss()
                            } else {
                                showError = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 22)

                    Spacer()
                    Spacer()
                }
                .padding(.top, 10)
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
                }
            }
            .alert("Fix these fields", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func validate() -> Bool {
        func trimmed(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }

        let fn = trimmed(firstName)
        let ln = trimmed(lastName)

        guard !fn.isEmpty else { errorMessage = "First name is required."; return false }
        guard !ln.isEmpty else { errorMessage = "Last name is required."; return false }

        guard let h = Double(trimmed(heightIn)), h > 0 else { errorMessage = "Height must be a positive number."; return false }
        guard let w = Double(trimmed(weightLbs)), w > 0 else { errorMessage = "Weight must be a positive number."; return false }
        guard let a = Int(trimmed(age)), (0...150).contains(a) else { errorMessage = "Age must be between 0 and 150."; return false }

        guard sex != .select else { errorMessage = "Please select sex (male or female)."; return false }

        // (Optional) You can enforce max digits/precision later if you want exact formatting.
        _ = h; _ = w; _ = a
        return true
    }
}
