//
//  LoginView.swift
//  MrBreathe
//
//  Created by K Panchal on 1/25/26.
//

import SwiftUI

func onSignIn() {
    
}

func onLogin() {
    
}

struct LoginView: View {
    @State private var email: String = ""
    @FocusState private var emailFocus: Bool
    @State private var password: String = ""
    @FocusState private var passwordFocus: Bool
    
    var body: some View {
        Text("Mr. Breathe")
            .bold(true)
            .font(.largeTitle)
            .foregroundStyle(Color(.systemBlue))
            .padding(100)
        HStack {
            Button(action: onSignIn) {
                Text("Sign In")
                    .foregroundStyle(Color(.white))
                    .padding(6)
            }
            .background(Color(.systemBlue))
            .buttonBorderShape(.roundedRectangle)
            
            Button(action: onLogin) {
                Text("Log In")
                    .foregroundStyle(Color(.white))
                    .padding(6)
            }
            .background(Color(.systemBlue))
            .buttonBorderShape(.roundedRectangle)
        }

    }
}

#Preview {
    LoginView()
}
