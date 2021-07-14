import UIKit

/// The `GestureHandlerDelegate` protocol supports communication
/// from the Gestures module to the `MapView`.
internal protocol GestureHandlerDelegate: AnyObject {

    // View has been tapped with a number of taps and number of finger touches
    func tapped(numberOfTaps: Int, numberOfTouches: Int)

    func panBegan(at point: CGPoint)

    // View has been panned
    func panned(from startPoint: CGPoint, to: CGPoint)

    // Pan on the view has ended with a residual offset
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint)

    // Cancel any gesture transitions that are happening
    func cancelGestureTransitions()

    // Notifies conformer that a gesture has begun
    func gestureBegan(for gestureType: GestureType)

    // Returns initial scale of the map
    func scaleForZoom() -> CGFloat

    // Pinch began on the view
    func pinchBegan(with anchor: CGPoint)

    // Pinch on the view has changed with a new zoom and anchor
    func pinchChanged(with zoom: CGFloat, anchor: CGPoint, previousAnchor: CGPoint)

    // Pinch has completed with a final scale and possible drift
    func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint)

    // Requests initial bearing of the map
    func rotationStartAngle() -> CGFloat

    // Bearing should change with `changedAngle` at a given `anchor`
    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat)

    // Rotation gesture is complete with a `finalAngle` and a given `anchor`
    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State)

    // Zoom changes based on new location of gesture
    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint)

    // Quick zoom gesture ended
    func quickZoomEnded()

    // Returns initial pitch of the map
    func initialPitch() -> CGFloat

    // Pitch gesture changed
    func pitchChanged(newPitch: CGFloat)

    // Pitch gesture ended
    func pitchEnded()
}

// Provides default implementation of GestureSupportableView methods.
internal extension GestureHandlerDelegate {

    func tapped(numberOfTaps: Int, numberOfTouches: Int) {}

    func panBegan(at point: CGPoint) {}

    // View has been panned
    func panned(from startPoint: CGPoint, to endPoint: CGPoint) {}

    // Pan on the view has ended (with a potential drift)
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint) {}

    func cancelGestureTransitions() {}

    func gestureBegan(for gestureType: GestureType) {}

    func scaleForZoom() -> CGFloat { return 0.0 }

    func pinchBegan(with anchor: CGPoint) { }

    func pinchChanged(with zoom: CGFloat, anchor: CGPoint, previousAnchor: CGPoint) { }

    func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {}

    func rotationStartAngle() -> CGFloat { return 0.0 }

    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {}

    func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {}

    func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {}

    func quickZoomEnded() {}

    func initialPitch() -> CGFloat { return 0.0 }

    func horizontalPitchTiltTolerance() -> Double { return 45.0 }

    func pitchChanged(newPitch: CGFloat) {}

    func pitchEnded() {}
}
