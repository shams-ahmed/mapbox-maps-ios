import XCTest
@testable import MapboxMaps

final class RotateGestureHandlerTests: XCTestCase {
    var gestureRecognizer: MockRotationGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var rotateGestureHandler: RotateGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!
    var view: UIView!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockRotationGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        rotateGestureHandler = RotateGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
        delegate = MockGestureHandlerDelegate()
        rotateGestureHandler.delegate = delegate
    }

    override func tearDown() {
        view = nil
        delegate = nil
        rotateGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        gestureRecognizer = nil
        super.setUp()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === rotateGestureHandler.gestureRecognizer)
    }

    func testAllowedSimultaneousGestures() {
        XCTAssertTrue(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UIPinchGestureRecognizer()))
    }

    func testDisallowedSimultaneousGestures() {
        XCTAssertFalse(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UIPanGestureRecognizer()))
        XCTAssertFalse(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UITapGestureRecognizer()))
        XCTAssertFalse(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UIRotationGestureRecognizer()))
    }

    func testRotationAngleBelowThresholdIgnored() {
        gestureRecognizer.getRotationStub.defaultReturnValue = 2
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        XCTAssertEqual(gestureRecognizer.setRotationStub.invocations.first?.parameters, 0)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
        XCTAssertEqual(delegate.gestureBeganStub.invocations.count, 0)
    }


    func testRotationVelocityBelowThresholdIgnored() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getVelocityStub.defaultReturnValue = 0.039.radiansPerSecond
        gestureRecognizer.getRotationStub.defaultReturnValue = 30.toRadians()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        XCTAssertEqual(gestureRecognizer.setRotationStub.invocations.first?.parameters, 0)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
        XCTAssertEqual(delegate.gestureBeganStub.invocations.count, 0)
    }

    func testRotationHighVelocityLowRotationIgnored() {
        let velocityRotationThresholds: [Double: Double] = [1: 3, 0.07: 5, 0.15: 7, 0.5: 15]
            .mapKeys { $0 + 0.01 } // increase rotation just above the threshold
            .mapValues { $0 - 1 } // decrease rotation just below the threshold

        for (velocityThreshold, rotationThreshold) in velocityRotationThresholds {
            gestureRecognizer.getStateStub.defaultReturnValue = .changed
            gestureRecognizer.getVelocityStub.defaultReturnValue = velocityThreshold.radiansPerSecond
            gestureRecognizer.getRotationStub.defaultReturnValue = rotationThreshold.toRadians()
            gestureRecognizer.sendActions()

            gestureRecognizer.getStateStub.defaultReturnValue = .ended
            gestureRecognizer.sendActions()
        }

        XCTAssertEqual(gestureRecognizer.setRotationStub.invocations.count, velocityRotationThresholds.count)
        XCTAssertTrue(gestureRecognizer.setRotationStub.invocations.allSatisfy { $0.parameters.isZero })
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
        XCTAssertEqual(delegate.gestureBeganStub.invocations.count, 0)
    }

    func testSufficientVelicityAndRotationInvokesSetCamera() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.getVelocityStub.defaultReturnValue = 1.radiansPerSecond
        gestureRecognizer.getRotationStub.defaultReturnValue = 30.toRadians()
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.invocations.count, 1)
    }

    func testDelegateGetsNotifiedAboutPinchGestureBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.getVelocityStub.defaultReturnValue = 1.radiansPerSecond
        gestureRecognizer.getRotationStub.defaultReturnValue = 30.toRadians()
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.invocations.first?.parameters, .pinch)
    }

    func testDelegateGetsNotifiedAboutPinchGestureEnded() {
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.first?.parameters.gestureType, .pinch)
    }

    func testDelegateGetsNotifiedAboutPinchGestureCancelled() {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.first?.parameters.gestureType, .pinch)
    }

    func testRotationIsAppliedAroundTouchMidpoint() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationInViewStub.defaultReturnValue = .random()
        gestureRecognizer.getVelocityStub.defaultReturnValue = 1.radiansPerSecond
        gestureRecognizer.getRotationStub.defaultReturnValue = 30.toRadians()
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.first?.parameters.anchor,
                       gestureRecognizer.locationInViewStub.defaultReturnValue)
    }

    func testFocalPointOveridesTouchMidpointAnchor() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        
        rotateGestureHandler.focalPoint = .random()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.getVelocityStub.defaultReturnValue = 1.radiansPerSecond
        gestureRecognizer.getRotationStub.defaultReturnValue = 30.toRadians()
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.first?.parameters.anchor, rotateGestureHandler.focalPoint)
    }

    func testRotationChanged() throws {
        mapboxMap.cameraState.bearing = .random(in: 0..<360)
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.getVelocityStub.defaultReturnValue = 1.radiansPerSecond
        gestureRecognizer.getRotationStub.defaultReturnValue = -90.toRadians()
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        let params = try XCTUnwrap(mapboxMap.setCameraStub.invocations.first?.parameters)
        let bearing = try XCTUnwrap(params.bearing)
        XCTAssertEqual(
            bearing,
            (mapboxMap.cameraState.bearing + 90).truncatingRemainder(dividingBy: 360), accuracy: 1e-13)
        XCTAssertNil(params.center)
        XCTAssertNil(params.zoom)
        XCTAssertNil(params.pitch)
        XCTAssertEqual(params.anchor, .zero)
        XCTAssertNil(params.padding)
    }

    func testSimultaneousRotateAndPinchZoomEnabledDefaultValue() {
        XCTAssertEqual(rotateGestureHandler.simultaneousRotateAndPinchZoomEnabled, true)
    }

    func testRotationRecognizesSimultaneouslyWithPinch() {
        let shouldRecognizeSimultaneously = rotateGestureHandler.gestureRecognizer(
            gestureRecognizer,
            shouldRecognizeSimultaneouslyWith: UIPinchGestureRecognizer()
        )

        XCTAssertTrue(shouldRecognizeSimultaneously)
    }

    func testRotationShouldNotRecognizeSimultaneouslyWithNonPinch() {
        let recognizers = [UIPanGestureRecognizer(), UILongPressGestureRecognizer(), UISwipeGestureRecognizer(), UIScreenEdgePanGestureRecognizer(), UITapGestureRecognizer()]

        for recognizer in recognizers {
            let shouldRecognizeSimultaneously = rotateGestureHandler.gestureRecognizer(
                gestureRecognizer,
                shouldRecognizeSimultaneouslyWith: recognizer
            )

            XCTAssertFalse(shouldRecognizeSimultaneously)
        }
    }

    func testRotationShouldNotRecognizeSimultaneouslyWhenRotateAndPinchDisabled() {
        rotateGestureHandler.simultaneousRotateAndPinchZoomEnabled = false

        let shouldRecognizeSimultaneously = rotateGestureHandler.gestureRecognizer(
            gestureRecognizer,
            shouldRecognizeSimultaneouslyWith: UIPinchGestureRecognizer()
        )

        XCTAssertFalse(shouldRecognizeSimultaneously)
    }
}

fileprivate extension Double {
    var radiansPerSecond: CGFloat { self * 17.4532925 }
}
