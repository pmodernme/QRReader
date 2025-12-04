import XCTest
@testable import QRReader

#if canImport(UIKit) && canImport(AVFoundation)
import SwiftUI
import AVFoundation

final class QRReaderTests: XCTestCase {

    func testStopDoesNotCauseExclusivityViolation() throws {
        // This test exercises the stop() method to ensure it doesn't cause
        // Swift exclusivity violations when setting session to nil

        let view = QRReaderView()

        // Simulate having a session
        let expectation = XCTestExpectation(description: "Session configured")

        // We can't actually start the camera in tests, but we can test the stop logic
        // by directly manipulating the session property
        let mockSession = AVCaptureSession()
        view.session = mockSession

        // This should not crash with exclusivity violation
        view.stop()

        // Verify session was cleared
        XCTAssertNil(view.session)

        // Give async operations time to complete
        let waitExpectation = XCTestExpectation(description: "Async cleanup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
    }

    func testMultipleStopCallsDoNotCrash() throws {
        // Test that calling stop multiple times doesn't cause issues
        let view = QRReaderView()

        let mockSession = AVCaptureSession()
        view.session = mockSession

        // Multiple stops should be safe
        view.stop()
        view.stop()
        view.stop()

        XCTAssertNil(view.session)
    }

    func testUIViewRepresentableDismantleDoesNotCrash() throws {
        // Test the SwiftUI lifecycle path where the crash was occurring
        let view = QRReaderView()
        let mockSession = AVCaptureSession()
        view.session = mockSession

        // Simulate SwiftUI calling dismantleUIView
        QRReader.dismantleUIView(view, coordinator: ())

        XCTAssertNil(view.session)

        // Give async operations time to complete
        let waitExpectation = XCTestExpectation(description: "Async cleanup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
    }

    func testConcurrentStopCalls() throws {
        // Test multiple concurrent stop calls to stress test the fix
        let view = QRReaderView()
        let mockSession = AVCaptureSession()
        view.session = mockSession

        let expectation = XCTestExpectation(description: "Concurrent stops complete")
        expectation.expectedFulfillmentCount = 5

        for _ in 0..<5 {
            DispatchQueue.global().async {
                view.stop()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
        XCTAssertNil(view.session)
    }
}

#else

final class QRReaderTests: XCTestCase {
    func testExample() throws {
        // Tests require UIKit and AVFoundation
        XCTSkip("Tests require UIKit and AVFoundation")
    }
}

#endif
