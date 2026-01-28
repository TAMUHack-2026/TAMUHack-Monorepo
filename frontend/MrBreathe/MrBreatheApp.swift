//
//  MrBreatheApp.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

@main
struct MrBreatheApp: App {
    @StateObject private var session = SessionManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}

