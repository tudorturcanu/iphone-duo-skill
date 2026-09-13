import SwiftUI

struct NotesRootView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    NotesListView()
                case 1:
                    Text("Search View")
                case 2:
                    Text("Settings View")
                default:
                    NotesListView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Anti-pattern: Hardcoded Dynamic Island padding
            .padding(.top, 59)
            // Anti-pattern: Fixed frame referencing UIScreen
            .frame(width: UIScreen.main.bounds.width)
            
            // Anti-pattern: Homemade bottom tab bar pinned to bottom ignoring safe area
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    VStack {
                        Image(systemName: "note.text")
                        Text("Notes")
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { selectedTab = 1 }) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { selectedTab = 2 }) {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 83)
            .background(Color(.secondarySystemBackground))
            .ignoresSafeArea()
        }
    }
}
