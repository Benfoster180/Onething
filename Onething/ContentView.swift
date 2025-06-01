import SwiftUI

struct ContentView: View {
    @State private var selectedIndex = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            CurrentQuestionView()
                .tag(0)
                .tabItem {
                    Label("Question", systemImage: "questionmark.circle")
                }

            HistoryView(entries: EntryStorage.shared.loadEntries())
                .tag(1)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
        // Keep default tab bar visible by NOT setting .tabViewStyle(PageTabViewStyle())
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        // Swipe left → next tab
                        if selectedIndex < 1 {
                            selectedIndex += 1
                        }
                    } else if value.translation.width > 50 {
                        // Swipe right → previous tab
                        if selectedIndex > 0 {
                            selectedIndex -= 1
                        }
                    }
                }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
