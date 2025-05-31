//
//  AllEntriesView.swift
//  Onething
//
//  Created by Ben Foster on 31/05/2025.
//

import SwiftUI

struct AllEntriesView: View {
    @State private var entries: [DailyEntry] = []

    var body: some View {
        NavigationView {
            List(entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Q: \(entry.question)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("A: \(entry.answer)")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                    Text(entry.date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.themePurple)
            }
            .navigationTitle("All Answers")
            .background(Color.themePurple)
            .onAppear {
                entries = EntryStorage.shared.loadEntries()
            }
            .listStyle(PlainListStyle())  // Cleaner list style
        }
        .accentColor(.white)
        .background(Color.themePurple)
    }
}

struct AllEntriesView_Previews: PreviewProvider {
    static var previews: some View {
        AllEntriesView()
    }
}
