import XCTest
@testable import FileMonitor

final class FileMonitorTests: XCTestCase, FileDidChangedDelegate {

    func testInitModule() throws {
        XCTAssertNoThrow(try FileMonitor())
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

        let monitor = try FileMonitor(delegate: inlineWatcher)
        try monitor.watch(directory: tmp)

        FileManager.default.createFile(atPath: file.path, contents: "hello".data(using: .utf8))
        sleep(3)
        XCTAssertEqual(InlineWatcher.fileChanges, 1)

        try "New Content".write(toFile: file.path, atomically: true, encoding: .utf8)
        sleep(3)
        XCTAssertEqual(InlineWatcher.fileChanges, 2)

        try FileManager.default.removeItem(at: file)
        sleep(3)
        XCTAssertEqual(InlineWatcher.fileChanges, 3)
    }

    // MARK: - Delegates
    func fileDidChanged(file: URL){

    }
}
