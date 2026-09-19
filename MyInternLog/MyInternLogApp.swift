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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // Opened once per launch. RootView decides whether to use it or demo mode's sample store.
    private let realContainer = AppSchema.makeRealContainer()

    var body: some Scene {
        WindowGroup {
            RootView(realContainer: realContainer)
        }
    }
}
