import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CurrentQuestionView()
                .tabItem {
                    Label("Question", systemImage: "questionmark.circle")
                }

            HistoryView(entries: EntryStorage.shared.loadEntries())
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
