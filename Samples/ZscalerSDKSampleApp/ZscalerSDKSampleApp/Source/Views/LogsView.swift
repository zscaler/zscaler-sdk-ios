
import SwiftUI

@MainActor
struct LogsView: View {
    @StateObject private var viewModel = LogsViewModel()
    @Binding var isVisible: Bool
    @State private var shareableURL: URL?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Actions")) {
                    ProgressButton("Export Logs", systemImage: "square.and.arrow.up.circle.fill", globalDisable: $viewModel.inProgress) {
                        if let url = viewModel.exportLogs() {
                            shareLogs(url: url)
                        }
                    }
                    ProgressButton("Clear Logs", systemImage: "trash.fill", role: .destructive, globalDisable: $viewModel.inProgress) {
                        viewModel.clearLogs()
                    }
                }
                .disabled(viewModel.inProgress)
                
                Section(header: Text("Events")) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if viewModel.eventEntries.isEmpty {
                        Text("No log events found.")
                            .foregroundColor(.secondary)
                    } else {
                        List(viewModel.eventEntries) { entry in
                            Text(entry.message)
                                .font(.body)
                        }
                    }
                }
            }
            .sheet(item: $shareableURL) { url in
                ShareSheet(activityItems: [url])
            }
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.loadLogs) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .onChange(of: isVisible) { isNowVisible in
                if isNowVisible {
                    viewModel.loadLogs()
                }
            }
            .onAppear(perform: viewModel.loadLogs)
        }
    }

    private func shareLogs(url: URL?) {
        self.shareableURL = url
    }
}

/// A wrapper for `UIActivityViewController` to use in SwiftUI.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            // Clean up the temporary zip file after sharing is complete
            if let url = activityItems.first as? URL {
                try? FileManager.default.removeItem(at: url)
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: Identifiable {
    public var id: String { self.absoluteString }
}
