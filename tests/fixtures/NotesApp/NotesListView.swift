import SwiftUI

struct NoteItem: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
}

struct NotesListView: View {
    let sampleNotes = (1...20).map { NoteItem(title: "Note \($0)", preview: "Preview for note \($0)...") }
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                        }
                        
                        Spacer().frame(width: 24)
                        
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
