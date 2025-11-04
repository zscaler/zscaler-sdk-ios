
import SwiftUI

struct NotificationEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let name: String?
    let message: String?
}


struct TunnelView: View {
    @StateObject var viewModel = TunnelViewModel()
    
    @State private var isInProgress = false
   
    enum Field {
        case appKey, accessToken
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    TextField("App Key", text: $viewModel.appKey, prompt: Text("Enter App Key"))
                        .focused($focusedField, equals: .appKey)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                    TextField("Access Token", text: $viewModel.accessToken, prompt: Text("Enter Access Token"))
                        .focused($focusedField, equals: .accessToken)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                }
                
                Section(header: Text("Tunnel Control")) {
                    ProgressButton("Start Pre-Login Tunnel", globalDisable: $isInProgress, action: viewModel.startPreLogin)
                    ProgressButton("Start Zero-Trust Tunnel", globalDisable: $isInProgress, action: viewModel.startZeroTrust)
                    ProgressButton("Stop Tunnel", role: .destructive, globalDisable: $isInProgress, action: viewModel.stopTunnel)
                }
                .disabled(isInProgress)
                
                Section(header: Text("Status")) {
                    Text("State: \(viewModel.tunnelConnectionState)")
                    Text("Type: \(viewModel.tunnelType.description)")
                }
                
                Section(header: Text("Notifications")) {
                    if viewModel.notifications.isEmpty {
                        Text("No notifications yet.")
                            .foregroundColor(.secondary)
                    } else {
                        List(viewModel.notifications) { notification in
                            VStack(alignment: .leading) {
                                Text(notification.name ?? "???")
                                    .font(.callout)
                                if let message = notification.message, message != "" {
                                    Text(message)
                                        .font(.subheadline)
                                }
                                Text(notification.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.alertIsPresented) {
                Button("OK") {
                }
            } message: {
                Text(viewModel.alertText)
            }
            .navigationTitle("Tunnel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
}

#Preview {
    TunnelView()
}
