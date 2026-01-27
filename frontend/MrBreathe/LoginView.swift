//
//  LoginView.swift
//  MrBreathe
//
//  Created by K Panchal on 1/25/26.
//

import SwiftUI
import Combine

// Hold data for creating an account
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

// Set font style for main title text on login page
struct TitleFontStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.bold(true)
            .font(.largeTitle)
            .foregroundStyle(Color(.systemBlue))
    }
}

// Set Button style for sign up and login buttons
struct AccountButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundColor(Color(.white))
            .padding(6)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
    }
}

// Set TextField style for username and password fields
struct LoginTextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
    }
}

// Set TextField style for account creation fields
struct CreateAccountTextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
    }
}

// Register styles to View
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

// Main login screen
struct LoginView: View {
    @StateObject private var accountData = AccountData()
    @State private var showModal: Bool = false
    
    // Call when the Sign Up button is pressed
    func onSignUp() {
        showModal = true
    }
    
    // Call when the Log In button is pressed
    func onLogin() {
        
    }
    
    var body: some View {
        // Main title text
        Text("Mr. Breathe")
            .titleFont()
        
        // Username and password fields
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
            
            // Sign up buttons
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
    
    // Create a new account
    func onCreateAccount() {
        
    }
    
    var body: some View {
        NavigationStack {
            // Main title text
            Text("Create Account")
                .titleFont()
            
            // Form fields
            VStack(alignment: .leading, spacing: 15) {
                // Name fields
                TextField("First Name", text: $accountData.firstName)
                    .createAccountTextInput()
                TextField("Last Name", text: $accountData.lastName)
                    .createAccountTextInput()
                
                // Height, weight, age information in a line
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
                
                // Sex and gender information in a line
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
                
                // Account creation button
                Button(action: onCreateAccount) {
                    Text("Create Account")
                }
                    .accountButton()
                    .frame(maxWidth: .infinity)
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
