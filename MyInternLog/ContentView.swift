//
//  ContentView.swift
//  MyInternLog
//
//  Created by Tyler on 6/13/26.
//

import SwiftUI
import SwiftData

private enum AppTab {
    case home, notes, queue, reflect, search
}

struct ContentView: View {
    @AppStorage("hasSeenSetup") private var hasSeenSetup = false
    @AppStorage("appTheme") private var appThemeRawValue = AppTheme.system.rawValue
    @StateObject private var router = NotificationRouter.shared

    private let demoMode = DemoMode.shared

    @State private var selectedTab: AppTab = .home
    @State private var showingQuickCaptureFromReminder = false
    @State private var showingReflectionFromReminder = false

    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRawValue) ?? .system
    }

    private var tabs: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)

            QuickNoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(AppTab.notes)

            StudyQueueListView()
                .tabItem {
                    Label("Queue", systemImage: "checklist")
                }
                .tag(AppTab.queue)

            ReflectionListView()
                .tabItem {
                    Label("Reflect", systemImage: "text.book.closed")
                }
                .tag(AppTab.reflect)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)
        }
    }

    var body: some View {
        // The accessory sits above the tab bar. A top banner would land on the
        // navigation bars' buttons, because each tab's NavigationStack ignores it.
        Group {
            if demoMode.isOn {
                tabs.tabViewBottomAccessory { DemoModeBanner() }
            } else {
                tabs
            }
        }
        .preferredColorScheme(appTheme.colorScheme)
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenSetup },
            set: { isShowing in hasSeenSetup = !isShowing }
        )) {
            SetupView(onFinish: { hasSeenSetup = true })
        }
        .sheet(isPresented: $showingQuickCaptureFromReminder) {
            AddQuickNoteView()
        }
        .sheet(isPresented: $showingReflectionFromReminder) {
            StartReflectionView()
        }
        .onChange(of: router.pendingDestination) { _, destination in
            switch destination {
            case .quickCapture:
                selectedTab = .notes
                showingQuickCaptureFromReminder = true
            case .reflection:
                selectedTab = .reflect
                showingReflectionFromReminder = true
            case nil:
                break
            }
            router.pendingDestination = nil
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [QuickNote.self, StudyItem.self], inMemory: true)
}
