import XCTest

@testable import FileMonitor
import FileMonitorShared

final class FileMonitorExplicitChangeTests: XCTestCase {

    let tmp = FileManager.default.temporaryDirectory
    let dir = String.random(length: 10)
    let testFileName = "\(String.random(length: 8)).\(String.random(length: 3))";

    override func setUpWithError() throws {
        super.setUp()
        let directory = tmp.appendingPathComponent(dir)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        print("Created directory: \(tmp.appendingPathComponent(dir).path)")

        let testFile = tmp.appendingPathComponent(dir).appendingPathComponent(testFileName)
        try "hello".write(to: testFile, atomically: false, encoding: .utf8)

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        let directory = tmp.appendingPathComponent(dir)
        try FileManager.default.removeItem(at: directory)
    }

    struct ChangeWatcher: FileDidChangeDelegate {
        static var fileChanges = 0
        static var missedChanges = 0
        let callback: ()->Void
        let file: URL

        init(on file: URL, completion: @escaping ()->Void) {
            self.file = file
            callback = completion
        }

        func fileDidChanged(event: FileChangeEvent) {
            switch event {
            case .changed(let fileInEvent):
                if file.lastPathComponent == fileInEvent.lastPathComponent {
                    ChangeWatcher.fileChanges = ChangeWatcher.fileChanges + 1
                    callback()
                }
            default:
                print("Missed", event)
                ChangeWatcher.missedChanges = ChangeWatcher.missedChanges + 1
            }
        }
    }

    func testLifecycleChange() throws {
        let expectation = expectation(description: "Wait for file creation")
        expectation.assertForOverFulfill = false

        let testFile = tmp.appendingPathComponent(dir).appendingPathComponent(testFileName)
        let watcher = ChangeWatcher(on: testFile) { expectation.fulfill() }

        let monitor = try FileMonitor(directory: tmp.appendingPathComponent(dir), delegate: watcher)
        try monitor.start()
        ChangeWatcher.fileChanges = 0

        let fileHandle = try FileHandle(forWritingTo: testFile)
        try fileHandle.seekToEnd()
        fileHandle.write("append some text".data(using: .utf8)!)
        try fileHandle.close()

        wait(for: [expectation], timeout: 10)

        XCTAssertEqual(ChangeWatcher.fileChanges, 1)
    }
}
