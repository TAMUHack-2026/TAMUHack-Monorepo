//
//  HomeView.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // Center vertically: push content into the middle
                Spacer()

                Button("Record") {
                    // TODO: Recording flow later
                }
                .buttonStyle(.borderedProminent)

                Button("Pair") {
                    // TODO: Bluetooth pairing later
                }
                .buttonStyle(.bordered)

                // iOS List placeholder under the buttons
                List {
                    // Leave blank for now (placeholder)
                    Section {
                        Text(" ")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log out") {
                        session.logout()
                    }
                }
            }
        }
    }
}
