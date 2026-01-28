//
//  RecordEntry.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/27/26.
//

import Foundation

struct RecordEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let data: String
}
