//
//  LoginView.swift
//  MrBreathe
//
//  Created by K Panchal on 1/25/26.
//

import SwiftUI
import Combine

class AccountData: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var age: UInt8?
    @Published var height: Double?
    @Published var weight: Double?
    @Published var sex: String?
    let sexes: [String] = ["male", "female"]
    @Published var genderIdentity: String = ""
}

struct TitleFontStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.bold(true)
            .font(.largeTitle)
            .foregroundStyle(Color(.systemBlue))
    }
}

struct AccountButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundColor(Color(.white))
            .padding(6)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
    }
}

struct LoginTextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
    }
}

struct CreateAccountTextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
    }
}

extension View {
    func titleFont() -> some View {
        self.modifier(TitleFontStyle())
    }
    func accountButton() -> some View {
        self.modifier(AccountButtonStyle())
    }
    
    func loginTextInput() -> some View {
        self.modifier(LoginTextInputStyle())
    }
    
    func createAccountTextInput() -> some View {
        self.modifier(CreateAccountTextInputStyle())
    }
}

struct LoginView: View {
    @StateObject private var accountData = AccountData()
    @State private var showModal: Bool = false
    
    func onSignUp() {
        showModal = true
    }
    
    func onLogin() {
        
    }
    
    var body: some View {
        Text("Mr. Breathe")
            .titleFont()
        VStack {
            VStack {
                TextField("Username", text: $accountData.email)
                    .textContentType(.emailAddress)
                    .loginTextInput()
                SecureField("Password", text: $accountData.password)
                    .textContentType(.password)
                    .loginTextInput()
            }
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            
            HStack {
                Button(action: onSignUp) {
                    Text("Sign Up")
                        .foregroundStyle(Color(.white))
                        .padding(6)
                }
                .accountButton()
                .sheet(isPresented: $showModal) {
                    CreateAccountModal(accountData: accountData)
                }
                
                Button(action: onLogin) {
                    Text("Log In")
                        .foregroundStyle(Color(.white))
                        .padding(6)
                }
                .accountButton()
            }
        }
        .frame(width: 300)

    }
}

struct CreateAccountModal: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var accountData: AccountData
    
    var body: some View {
        NavigationStack {
            Text("Create Account")
                .titleFont()
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("First Name", text: $accountData.firstName)
                    .createAccountTextInput()
                TextField("Last Name", text: $accountData.lastName)
                    .createAccountTextInput()
                HStack {
                    TextField("Height (in)", value: $accountData.height, format: .number)
                        .createAccountTextInput()
                    Spacer()
                    TextField("Weight (lbs)", value: $accountData.weight, format: .number)
                        .createAccountTextInput()
                    Spacer()
                    TextField("Age", value: $accountData.age, format: .number)
                        .createAccountTextInput()
                }
                HStack {
                    Picker("Select Sex", selection: $accountData.sex) {
                        Text("Select").tag(nil as String?)
                        ForEach(accountData.sexes, id: \.self) { sex in
                            Text(sex).tag(sex)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 100, alignment: .trailing)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(UIColor.separator), lineWidth: 0.5)
                    )
                    TextField("Gender Identity", text: $accountData.genderIdentity)
                        .createAccountTextInput()
                }
            }
            .frame(maxWidth: 350)
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
