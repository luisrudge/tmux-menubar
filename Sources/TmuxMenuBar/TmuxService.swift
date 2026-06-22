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
    
    /// Default tmux socket path for the current user
    private static var socketPath: String {
        "/private/tmp/tmux-\(getuid())/default"
    }
    
    /// Find tmux binary path (Homebrew locations + system PATH)
    private static var tmuxPath: String {
        let candidates = [
            "/opt/homebrew/bin/tmux",  // Apple Silicon Homebrew
            "/usr/local/bin/tmux",      // Intel Homebrew
            "/usr/bin/tmux"             // System install
        ]
        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return "tmux"  // Fallback to PATH lookup
    }
    
    private static func run(_ args: String...) -> String {
        let process = Process()
        let pipe = Pipe()
        
        // Build args: replace "tmux" with full path and add socket
        var allArgs = Array(args)
        if let tmuxIndex = allArgs.firstIndex(of: "tmux") {
            allArgs[tmuxIndex] = tmuxPath
            allArgs.insert(contentsOf: ["-S", socketPath], at: tmuxIndex + 1)
        }
        
        process.executableURL = URL(fileURLWithPath: allArgs.removeFirst())
        process.arguments = allArgs
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
