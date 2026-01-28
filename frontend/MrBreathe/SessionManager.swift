//
//  SessionManager.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI
import Combine

final class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var email: String? = nil
    @Published var profile: Profile? = nil

    func logout() {
        isLoggedIn = false
        email = nil
        profile = nil
    }
}




