
import SwiftUI

struct ProgressButton: View {
    let text: String
    let systemImage: String? // Made optional
    let role: ButtonRole? // Added role property
    let action: () async -> Void
    @Binding var globalDisable: Bool // Use a binding to disable all buttons
    @State private var localSpinnerActive: Bool = false // Local state for this button's spinner
    
    // Initializer for text and optional role (no system image)
    init(_ text: String, role: ButtonRole? = nil, globalDisable: Binding<Bool>, action: @escaping () async -> Void) {
        self.text = text
        self.systemImage = nil
        self.role = role
        self._globalDisable = globalDisable
        self.action = action
    }

    // Initializer for text, system image, and optional role
    init(_ text: String, systemImage: String, role: ButtonRole? = nil, globalDisable: Binding<Bool>, action: @escaping () async -> Void) {
        self.text = text
        self.systemImage = systemImage
        self.role = role
        self._globalDisable = globalDisable
        self.action = action
    }

    var body: some View {
        Button(role: role, action: {
            localSpinnerActive = true
            globalDisable = true // Disable all buttons in the section
            Task {
                await action()
                await MainActor.run {
                    localSpinnerActive = false
                    globalDisable = false
                }
            }
        }) {
            HStack {
                if let systemImage = systemImage { // Conditionally display Label or Text
                    Label(text, systemImage: systemImage)
                } else {
                    Text(text)
                }
                if localSpinnerActive { // Spinner logic now driven by local state
                    Spacer()
                    ProgressView()
                }
            }
        }
    }
}

