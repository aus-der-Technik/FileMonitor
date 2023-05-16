import XCTest

@testable import FileMonitor

final class FileMonitorTests: XCTestCase {

    func testInitModule() throws {
        XCTAssertNoThrow(try FileMonitor(directory: FileManager.default.temporaryDirectory))
    }

    func testLifecycle() throws {
        var expectation = expectation(description: "Wait for file change")
        expectation.assertForOverFulfill = false

        let tmp = FileManager.default.temporaryDirectory
        let dir = String.random(length: 10)
        try FileManager.default.createDirectory(at: tmp.appendingPathComponent(dir), withIntermediateDirectories: true)
        print("Created directory: \(tmp.appendingPathComponent(dir).path)")

        let file = tmp.appendingPathComponent(dir).appendingPathComponent("\(String.random(length: 8)).\(String.random(length: 3))");
        print("Testfile: \(file)")

        struct Watcher: FileDidChangedDelegate {
            static var fileChanges = 0
            let callback: ()->Void

            func fileDidChanged(event: FileChangeEvent) {
                print("**** IN")
                Watcher.fileChanges = Watcher.fileChanges + 1
                callback()
            }

            init(completion: @escaping ()->Void) {
                callback = completion
            }
        }
        let watcher = Watcher() { expectation.fulfill() }

        let monitor = try FileMonitor(directory: tmp.appendingPathComponent(dir), delegate: watcher)
        try monitor.start()
        Watcher.fileChanges = 0

        FileManager.default.createFile(atPath: file.path, contents: "hello".data(using: .utf8))
        wait(for: [expectation], timeout: 10)
        print("\(Watcher.fileChanges) file changes.")

        //XCTAssertEqual(Watcher.fileChanges, 1)

        //try "New Content".write(toFile: file.path, atomically: true, encoding: .utf8)
        //XCTAssertEqual(fileChanges, 2)

        //try FileManager.default.removeItem(at: file)
        //XCTAssertEqual(fileChanges, 3)
    }

}
