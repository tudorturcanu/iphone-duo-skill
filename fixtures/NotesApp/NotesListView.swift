import SwiftUI

struct NoteItem: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
}

struct NotesListView: View {
    let sampleNotes = (1...20).map { NoteItem(title: "Note \($0)", preview: "Preview for note \($0)...") }
    
    // Anti-pattern: Odd number of grid columns (splits items across the fold)
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sampleNotes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.title).font(.headline)
                            Text(note.preview).font(.caption).foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("All Notes")
            .toolbar {
                // Anti-pattern: Manual spacers in toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Anti-pattern: Symbol only without title
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                        }
                        
                        Spacer().frame(width: 24)
                        
                        // Anti-pattern: Homemade ellipsis menu competing with system overflow
                        Menu {
                            Button("Sort by Date", action: {})
                            Button("Select Notes", action: {})
                            Button("Settings", action: {})
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            }
        }
    }
}
