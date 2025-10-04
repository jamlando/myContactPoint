import XCTest
@testable import MyContactPoint

final class MyContactPointTests: XCTestCase {
    
    func testLogoSize() throws {
        let smallSize = LogoSize.small.size
        let largeSize = LogoSize.large.size
        
        XCTAssertGreaterThan(largeSize, smallSize)
        XCTAssertEqual(smallSize, 40)
        XCTAssertEqual(largeSize, 80)
    }
    
    func testSwingVideoModel() throws {
        let video = SwingVideo(
            id: UUID(),
            userId: UUID(),
            filename: "test.mov",
            filePath: "test/path.mov",
            fileSize: 1024,
            durationSeconds: 5.0,
            resolution: "1920x1080",
            fps: 30,
            createdAt: Date(),
            updatedAt: Date(),
            metadata: [:]
        )
        
        XCTAssertNotNil(video.id)
        XCTAssertNotNil(video.userId)
        XCTAssertEqual(video.filename, "test.mov")
        XCTAssertEqual(video.filePath, "test/path.mov")
        XCTAssertEqual(video.fileSize, 1024)
        XCTAssertEqual(video.durationSeconds, 5.0)
        XCTAssertEqual(video.resolution, "1920x1080")
        XCTAssertEqual(video.fps, 30)
    }
    
    func testVideoMetadataModel() throws {
        let metadata = VideoMetadata(
            duration: 10.5,
            resolution: "1920x1080",
            fps: 30,
            fileSize: 1024000
        )
        
        XCTAssertEqual(metadata.duration, 10.5)
        XCTAssertEqual(metadata.resolution, "1920x1080")
        XCTAssertEqual(metadata.fps, 30)
        XCTAssertEqual(metadata.fileSize, 1024000)
    }
}
