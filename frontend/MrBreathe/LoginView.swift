//
//  LoginView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager

    @State private var username: String = ""
    @State private var password: String = ""

    @State private var showSignUp: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Text("Mr. Breathe")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.blue)

                VStack(spacing: 12) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 28)

                HStack(spacing: 18) {
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Log In") {
                        let ok = session.login(username: username, password: password)
                        if !ok {
                            errorMessage = "Please enter a username and password."
                            showError = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 6)

                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .alert("Login failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}
