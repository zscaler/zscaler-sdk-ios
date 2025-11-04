
import SwiftUI

struct MainView: View {
    enum Page {
        case tunnel
        case request
        case options
        case logs
    }

    @State var selection = Page.tunnel
    
    var body: some View {
        TabView(selection: $selection) {
            TunnelView()
                .tag(Page.tunnel)
                .tabItem {
                    Image(systemName: "tram.fill.tunnel")
                    Text("Tunnel")
                }

            RequestView()
                .tag(Page.request)
                .tabItem {
                    Image(systemName: "network")
                    Text("Request")
                }

            LogsView(isVisible: .constant(selection == .logs))
                .tag(Page.logs)
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Logs")
                }

            SettingsView()
                .tag(Page.options)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
