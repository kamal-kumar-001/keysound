import Foundation
import AppKit

public final class LaunchAtLoginManager {
    public static let shared = LaunchAtLoginManager()

    private let fileManager = FileManager.default
    private let plistLabel = "com.kamal.KeySound"

    private var launchAgentsDirectory: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("LaunchAgents", isDirectory: true)
    }

    private var plistURL: URL {
        launchAgentsDirectory.appendingPathComponent("\(plistLabel).plist")
    }

    private init() {}

    public var isEnabled: Bool {
        return fileManager.fileExists(atPath: plistURL.path)
    }

    public func setEnabled(_ enable: Bool) {
        if enable {
            enableLaunchAtLogin()
        } else {
            disableLaunchAtLogin()
        }
    }

    private func enableLaunchAtLogin() {
        do {
            try fileManager.createDirectory(at: launchAgentsDirectory, withIntermediateDirectories: true)

            // Get path to current executable
            let executablePath = Bundle.main.executablePath ??
                (Bundle.main.bundlePath as NSString).appendingPathComponent("Contents/MacOS/KeySound")

            let plistContent: [String: Any] = [
                "Label": plistLabel,
                "ProgramArguments": [executablePath],
                "RunAtLoad": true,
                "KeepAlive": false,
                "ProcessType": "Interactive"
            ]

            let propertyList = try PropertyListSerialization.data(fromPropertyList: plistContent, format: .xml, options: 0)
            try propertyList.write(to: plistURL, options: .atomic)
        } catch {
            print("Failed to enable launch at login: \(error)")
        }
    }

    private func disableLaunchAtLogin() {
        do {
            if fileManager.fileExists(atPath: plistURL.path) {
                try fileManager.removeItem(at: plistURL)
            }
        } catch {
            print("Failed to disable launch at login: \(error)")
        }
    }
}
