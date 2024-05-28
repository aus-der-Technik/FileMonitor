import XCTest

@testable import FileMonitor
import FileMonitorShared

final class FileMonitorTests: XCTestCase {

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

    func testInitModule() throws {
        XCTAssertNoThrow(try FileMonitor(directory: FileManager.default.temporaryDirectory))
    }

    struct Watcher: FileDidChangeDelegate {
        static var fileChanges = 0
        let callback: ()->Void
        let file: URL

        init(on file: URL, completion: @escaping ()->Void) {
            self.file = file
            callback = completion
        }

        func fileDidChanged(event: FileChangeEvent) {
            switch event {
            case .changed(let fileInEvent), .deleted(let fileInEvent), .added(let fileInEvent):
                if file.lastPathComponent == fileInEvent.lastPathComponent {
                    Watcher.fileChanges = Watcher.fileChanges + 1
                    callback()
                }
            }
        }
    }

    func testLifecycleCreate() throws {
        let expectation = expectation(description: "Wait for file creation")
        expectation.assertForOverFulfill = false

        let testFile = tmp.appendingPathComponent(dir).appendingPathComponent("\(String.random(length: 8)).\(String.random(length: 3))");
        let watcher = Watcher(on: testFile) { expectation.fulfill() }

        let monitor = try FileMonitor(directory: tmp.appendingPathComponent(dir), delegate: watcher)
        try monitor.start()
        Watcher.fileChanges = 0

        FileManager.default.createFile(atPath: testFile.path, contents: "hello".data(using: .utf8))
        wait(for: [expectation], timeout: 10)

        XCTAssertGreaterThan(Watcher.fileChanges, 0)
    }

    func testLifecycleChange() async throws {
        let expectation = expectation(description: "Wait for file creation")
        expectation.assertForOverFulfill = false
        let asyncExpectation = XCTestExpectation(description: "Async wait for file creation")
        expectation.assertForOverFulfill = true

        let testFile = tmp.appendingPathComponent(dir).appendingPathComponent("\(String.random(length: 8)).\(String.random(length: 3))");
        FileManager.default.createFile(atPath: testFile.path, contents: "hello".data(using: .utf8))

        let watcher = Watcher(on: testFile) { expectation.fulfill() }

        let monitor = try FileMonitor(directory: tmp.appendingPathComponent(dir), delegate: watcher)
        try monitor.start()
        Watcher.fileChanges = 0

        var events = [FileChange]()
        for await event in monitor.stream {
            events.append(event)
            asyncExpectation.fulfill()
            monitor.stop()
        }

        try "New Content".write(toFile: testFile.path, atomically: true, encoding: .utf8)
        await fulfillment(of: [expectation, asyncExpectation], timeout: 10)

        XCTAssertGreaterThan(Watcher.fileChanges, 0)
        XCTAssertGreaterThan(events.count, 0)
    }

    func testLifecycleDelete() throws {
        let expectation = expectation(description: "Wait for file deletion")
        expectation.assertForOverFulfill = false

        let testFile = tmp.appendingPathComponent(dir).appendingPathComponent("\(String.random(length: 8)).\(String.random(length: 3))");
        FileManager.default.createFile(atPath: testFile.path, contents: "hello".data(using: .utf8))

        let watcher = Watcher(on: testFile) { expectation.fulfill() }

        let monitor = try FileMonitor(directory: tmp.appendingPathComponent(dir), delegate: watcher)
        try monitor.start()
        Watcher.fileChanges = 0

        try FileManager.default.removeItem(at: testFile)
        wait(for: [expectation], timeout: 10)

        XCTAssertGreaterThan(Watcher.fileChanges, 0)
    }


}
