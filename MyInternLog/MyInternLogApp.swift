//
//  MyInternLogApp.swift
//  MyInternLog
//
//  Created by Tyler on 6/13/26.
//

import SwiftUI
import SwiftData

@main
struct MyInternLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [QuickNote.self, StudyItem.self])
    }
}
