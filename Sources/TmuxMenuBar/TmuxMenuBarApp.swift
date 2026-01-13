import SwiftUI

@Observable
final class AppState {
    var sessions: [String] = []
    var logs: [String: String] = [:]
    var selectedSession: String? = nil
    
    private var timer: Timer?
    
    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.refresh()
            }
        }
    }
    
    func refresh() {
        sessions = TmuxService.listSessions()
        for session in sessions {
            logs[session] = TmuxService.captureLogs(session: session)
        }
        // Clear selection if session no longer exists
        if let selected = selectedSession, !sessions.contains(selected) {
            selectedSession = nil
        }
    }
    
    func killSession(_ session: String) {
        TmuxService.killSession(session: session)
        if selectedSession == session {
            selectedSession = nil
        }
        refresh()
    }
    
    func killAllSessions() {
        TmuxService.killAllSessions()
        selectedSession = nil
        refresh()
    }
}

@main
struct TmuxMenuBarApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        MenuBarExtra("tmux", systemImage: "terminal.fill") {
            MenuContentView(appState: appState)
                .frame(width: 500, height: 400)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuContentView: View {
    @Bindable var appState: AppState
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Session list
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Sessions")
                        .font(.headline)
                    Spacer()
                    if !appState.sessions.isEmpty {
                        Button("Kill All") {
                            appState.killAllSessions()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.small)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                Divider()
                
                if appState.sessions.isEmpty {
                    Text("No active sessions")
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    List(appState.sessions, id: \.self, selection: $appState.selectedSession) { session in
                        Text(session)
                    }
                    .listStyle(.plain)
                }
                
                Divider()
                
                HStack {
                    Text("v\(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(width: 160)
            .background(.background)
            
            Divider()
            
            // Right: Logs panel
            VStack(spacing: 0) {
                if let session = appState.selectedSession {
                    HStack {
                        Text("Logs: \(session)")
                            .font(.headline)
                        Spacer()
                        Button("Kill") {
                            appState.killSession(session)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            Text(appState.logs[session] ?? "No output...")
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .padding(8)
                                .id("bottom")
                        }
                        .onChange(of: appState.logs[session]) { _, _ in
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("Select a session")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background.secondary)
        }
    }
}
