
import SwiftUI
import Zscaler

struct EventFetchError: Error, LocalizedError {
    var description: String
    var errorDescription: String? { description }
}

struct EventEntry: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
class LogsViewModel: ObservableObject {
    private let fileName: String = "events.json"

    @Published var eventEntries: [EventEntry] = []
    @Published var inProgress: Bool = false
    @Published var errorMessage: String?

    // MARK: - Public Methods (for View)

    func loadLogs() {
        self.inProgress = true
        self.errorMessage = nil
        self.eventEntries = []
        
        defer { self.inProgress = false }

        do {
            let content = try getLogFileContent()
            let lines = content.split(whereSeparator: \.isNewline)
            
            self.eventEntries = lines.reversed().map { line in
                return EventEntry(message: String(line))
            }
        } catch {
            self.errorMessage = "Failed to load events: \(error.localizedDescription)"
        }
    }

    // MARK: - SDK Usage Examples

    func exportLogs() -> URL? {
        self.inProgress = true
        defer { self.inProgress = false }

        var directory: URL
        if #available(iOS 16.0, *) {
            directory = URL.documentsDirectory
        } else {
            directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
        // SDK Usage: Exporting logs to a specified directory
        return ZscalerSDK.sharedInstance().exportLogs(destination: directory.absoluteString)
    }

    func clearLogs() {
        self.inProgress = true
        defer { self.inProgress = false }
        
        // Clear SDK logs and events
        ZscalerSDK.sharedInstance().clearLogs()

        loadLogs()
    }
    
    // MARK: - Private Helpers

    private func getLogFileContent() throws -> String {
        let fileManager = FileManager.default
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw EventFetchError(description: "Error: Unable to get Application Support directory")
        }
    
        let logDirPath = appSupportDir
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.zscaler.sdk.zscalersdk-ios.TestApp")
            .appendingPathComponent(Bundle(for: ZscalerSDK.self).bundleIdentifier ?? "com.zscaler.sdk.zscalersdk-ios")
            .appendingPathComponent("logs")
            
        let jsonFilePath = logDirPath.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: jsonFilePath.path) else { return "" }
        return try String(contentsOf: jsonFilePath, encoding: .utf8)
    }
}
