import XCTest
@testable import FileMonitor

final class FileMonitorTests: XCTestCase {

    func testInitModule() throws {
        XCTAssertNoThrow(try FileMonitor(directory: FileManager.default.temporaryDirectory))
    }

    func testLifecycle() throws {
        let expectation = expectation(description: "Wait for file change")

        let tmp = FileManager.default.temporaryDirectory
        let file = tmp.appendingPathComponent("foo.txt");
        print("--> \(tmp)")

        struct Watcher: FileDidChangedDelegate {
            let expectation: XCTestExpectation
            static var fileChanges = 0
            func fileDidChanged(file: URL){
                print("IN")
                Watcher.fileChanges = Watcher.fileChanges + 1

                expectation.fulfill()
            }
        }
        let watcher = Watcher(expectation: expectation)
        print("-A")
        let monitor = try FileMonitor(directory: tmp, delegate: watcher)
        print("-B")
        try monitor.start()
        print("-C")

        FileManager.default.createFile(atPath: file.path, contents: "hello".data(using: .utf8))
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(Watcher.fileChanges, 1)

        //try "New Content".write(toFile: file.path, atomically: true, encoding: .utf8)
        //XCTAssertEqual(fileChanges, 2)

        //try FileManager.default.removeItem(at: file)
        //XCTAssertEqual(fileChanges, 3)
    }

}
