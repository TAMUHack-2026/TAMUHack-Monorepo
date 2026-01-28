//
//  Styles.swift
//  MrBreathe
//
//  Created by K Panchal on 1/27/26.
//

import SwiftUI

// Set font style for main title text
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

// Size enum for buttons and text
enum RoundedSize: CGFloat {
    case small = 6
    case medium = 8
    case large = 10
}

// Set text style for Bluetooth indicator
struct OutlinedTextStyle: ViewModifier {
    let size: RoundedSize
    func body(content: Content) -> some View {
        content.foregroundStyle(Color.blue)
            .padding(size.rawValue)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

struct HighlightedTextStyle: ViewModifier {
    let size: RoundedSize
    func body(content: Content) -> some View {
        content.foregroundStyle(Color.white)
            .padding(size.rawValue)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
            )
    }
}

struct InvertedHighlightedTextStyle: ViewModifier {
    let size: RoundedSize
    func body(content: Content) -> some View {
        content.foregroundStyle(Color.blue)
            .padding(size.rawValue)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
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
    
    func outlined(size: RoundedSize = .medium) -> some View {
        self.modifier(OutlinedTextStyle(size: size))
    }
    
    func highlighted(size: RoundedSize = .medium) -> some View {
        self.modifier(HighlightedTextStyle(size: size))
    }
    
    func highlightedInverted(size: RoundedSize = .medium) -> some View {
        self.modifier(InvertedHighlightedTextStyle(size: size))
    }
}
