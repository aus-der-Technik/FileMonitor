import Foundation
import FileMonitor

@main
public struct FileMonitorExample: FileDidChangedDelegate {

    public func fileDidChanged(event: FileChangeEvent) {
        print("FILE DID CHANGED")
    }

    public private(set) var text = "Hello, FileWatcher!"

    public static func main() {
        print(FileMonitorExample().text)
        let fileMonitor = FileMonitorExample()
        fileMonitor.run();
    }

    func run(){
        let tmp = FileManager.default.temporaryDirectory
        print("Watch \(tmp.path)")
        do {
            let monitor = try FileMonitor(directory: tmp, delegate: self )
            try monitor.start();
        } catch {
            print("ERROR: \(error)")
        }
        RunLoop.main.run()
    }
}
