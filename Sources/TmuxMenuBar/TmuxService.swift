import Foundation

struct TmuxService {
    /// Returns list of active tmux session names
    static func listSessions() -> [String] {
        let output = run("tmux", "list-sessions", "-F", "#{session_name}")
        guard !output.isEmpty else { return [] }
        return output.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    /// Captures the visible pane content for a session
    static func captureLogs(session: String) -> String {
        run("tmux", "capture-pane", "-p", "-t", session)
    }
    
    /// Kills a tmux session
    static func killSession(session: String) {
        _ = run("tmux", "kill-session", "-t", session)
    }
    
    /// Kills all tmux sessions (kills the server)
    static func killAllSessions() {
        _ = run("tmux", "kill-server")
    }
    
    // MARK: - Private
    
    private static func run(_ args: String...) -> String {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = args
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ""
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
