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

    func login(username: String, password: String) -> Bool {
        let ok = !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if ok { isLoggedIn = true }
        return ok
    }

    func logout() {
        isLoggedIn = false
    }
}


