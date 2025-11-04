
import SwiftUI
import WebKit

struct RequestView: View {
    @StateObject private var viewModel = RequestViewModel()
    
    @FocusState private var isUrlFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack {
                    Picker("Request Mode", selection: $viewModel.requestMode) {
                        ForEach(RequestViewModel.RequestMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom)

                    Picker("SDK Config", selection: $viewModel.sdkConfig) {
                        ForEach(RequestViewModel.SDKConfig.allCases) { config in
                            Text(config.rawValue).tag(config)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom)
                    
                    HStack {
                        TextField("URL", text: $viewModel.url, prompt: Text("Enter URL"))
                            .focused($isUrlFieldFocused)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)

                        Button(action: {
                            isUrlFieldFocused = false
                            viewModel.executeRequest()
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                        }.accessibilityIdentifier("go_button")
                    }
                }
                .padding()
                
                switch viewModel.responseState {
                case .idle:
                    Spacer()
                    if viewModel.requestMode == .web {
                        Text("Enter a URL and tap Go to load it in the web view.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Perform a request to see the response.")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                case .loading:
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                case let .webView(webView, id):
                    WebView(webView: webView)
                        .id(id)
                        .frame(minHeight: 400)
                case .urlResponse(let statusCode, let headers, let body):
                    Form {
                        Section(header: Text("Status Code")) {
                            Text("\(statusCode)")
                                .accessibilityIdentifier("response_code")
                        }
                        
                        Section(header: Text("Headers")) {
                            ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key): \(value)")
                                    .font(.caption)
                            }
                        }

                        Section(header: Text("Response Body")) {
                            ScrollView {
                                Text(body)
                                    .accessibilityIdentifier("response_body")
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                case .error(let message):
                    ScrollView {
                        Text(message)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isUrlFieldFocused = false }
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("update.")
    }
}

#Preview {
    RequestView()
}
