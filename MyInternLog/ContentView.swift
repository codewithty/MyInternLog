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
        QuickNoteListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuickNote.self, inMemory: true)
}
