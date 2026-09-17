//
//  ContentView.swift
//  MyInternLog
//
//  Created by Tyler on 6/13/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenSetup") private var hasSeenSetup = false
    @AppStorage("appTheme") private var appThemeRawValue = AppTheme.system.rawValue

    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRawValue) ?? .system
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            QuickNoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            StudyQueueListView()
                .tabItem {
                    Label("Queue", systemImage: "checklist")
                }

            ReflectionListView()
                .tabItem {
                    Label("Reflect", systemImage: "text.book.closed")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .preferredColorScheme(appTheme.colorScheme)
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenSetup },
            set: { isShowing in hasSeenSetup = !isShowing }
        )) {
            SetupView(onFinish: { hasSeenSetup = true })
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [QuickNote.self, StudyItem.self], inMemory: true)
}
