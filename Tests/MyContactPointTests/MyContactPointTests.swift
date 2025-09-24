import XCTest
@testable import MyContactPoint

final class MyContactPointTests: XCTestCase {
    
    func testAnalyticsService() throws {
        let analytics = AnalyticsService.shared
        // Test that analytics service can be instantiated
        XCTAssertNotNil(analytics)
    }
    
    func testDataPersistenceService() throws {
        let persistence = DataPersistenceService.shared
        // Test that data persistence service can be instantiated
        XCTAssertNotNil(persistence)
        
        // Test tutorial completion tracking
        persistence.tutorialCompleted = true
        XCTAssertTrue(persistence.tutorialCompleted)
        
        persistence.tutorialCompleted = false
        XCTAssertFalse(persistence.tutorialCompleted)
    }
    
    func testLogoSize() throws {
        let smallSize = LogoSize.small.size
        let largeSize = LogoSize.large.size
        
        XCTAssertGreaterThan(largeSize, smallSize)
        XCTAssertEqual(smallSize, 40)
        XCTAssertEqual(largeSize, 80)
    }
}
