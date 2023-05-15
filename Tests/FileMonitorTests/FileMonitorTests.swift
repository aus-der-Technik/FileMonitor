import XCTest
@testable import FileMonitor

final class FileMonitorTests: XCTestCase, FileDidChangedDelegate {

    func testInitModule() throws {
        XCTAssertNoThrow(try FileMonitor(directory: FileManager.default.temporaryDirectory))
    }

    func testLifecycle() throws {

        struct InlineWatcher: FileDidChangedDelegate {
            static var fileChanges = 0

            func fileDidChanged(file: URL) {
                InlineWatcher.fileChanges = InlineWatcher.fileChanges + 1
            }
        }
        let inlineWatcher = InlineWatcher()

        let tmp = FileManager.default.temporaryDirectory
        let file = tmp.appendingPathComponent("foo.txt");

        try FileMonitor(directory: tmp, delegate: inlineWatcher)

        FileManager.default.createFile(atPath: file.path, contents: "hello".data(using: .utf8))

        XCTAssertEqual(InlineWatcher.fileChanges, 1)

        try "New Content".write(toFile: file.path, atomically: true, encoding: .utf8)
        XCTAssertEqual(InlineWatcher.fileChanges, 2)

        try FileManager.default.removeItem(at: file)
        XCTAssertEqual(InlineWatcher.fileChanges, 3)
    }

    // MARK: - Delegates
    func fileDidChanged(file: URL){

    }
}
