//
//  ContentView.swift
//  MyInternLog
//
//  Created by Tyler on 6/13/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            QuickNoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            StudyQueueListView()
                .tabItem {
                    Label("Queue", systemImage: "checklist")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [QuickNote.self, StudyItem.self], inMemory: true)
}
