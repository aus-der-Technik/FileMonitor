import XCTest

@testable import FileMonitor

final class FileMonitorExplicitAddTests: XCTestCase {

    let tmp = FileManager.default.temporaryDirectory
    let dir = String.random(length: 10)

    override func setUpWithError() throws {
        super.setUp()
        let directory = tmp.appendingPathComponent(dir)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        print("Created directory: \(tmp.appendingPathComponent(dir).path)")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        let directory = tmp.appendingPathComponent(dir)
        try FileManager.default.removeItem(at: directory)
    }

    struct AddWatcher: FileDidChangedDelegate {
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
            case .added(let fileInEvent):
                if file.lastPathComponent == fileInEvent.lastPathComponent {
                    AddWatcher.fileChanges = AddWatcher.fileChanges + 1
                    callback()
                }
            default:
                AddWatcher.missedChanges = AddWatcher.missedChanges + 1
            }
        }
    }

    func testLifecycleCreate() throws {
        let expectation = expectation(description: "Wait for file creation")
        expectation.assertForOverFulfill = false

        let testFile = tmp.appendingPathComponent(dir).appendingPathComponent("\(String.random(length: 8)).\(String.random(length: 3))");
        let watcher = AddWatcher(on: testFile) { expectation.fulfill() }

        let monitor = try FileMonitor(directory: tmp.appendingPathComponent(dir), delegate: watcher)
        try monitor.start()
        AddWatcher.fileChanges = 0

        try "hello".write(to: testFile, atomically: false, encoding: .utf8)
        wait(for: [expectation], timeout: 10)

        XCTAssertEqual(AddWatcher.fileChanges, 1)
    }
}
