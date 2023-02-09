import SwiftUI
import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct CameraDebugView: View {
    @Binding var camera: CameraState

    var body: some View {
        Menu {
            Group {
                navButton("NewYork", .newYork)
                navButton("DC", .dc)
                navButton("Helsinki", .helsinki)
                navButton("Berlin", .berlin)
                navButton("London", .london)
            }
        } label: {
            VStack(alignment: .leading) {
                let latlon = String(format: "%.4f, %.4f", camera.center.latitude, camera.center.longitude)
                Text("\(latlon)")
                VStack(alignment: .leading) {
                    Text("zoom: \(String(format: "%.2f", camera.zoom))")
                    Text("bearing: \(String(format: "%.2f", camera.bearing))")
                    Text("pitch: \(String(format: "%.2f", camera.pitch))")
                }.foregroundColor(.gray)
            }
        }
        .foregroundColor(.primary)
        .font(.safeMonospaced)
        .padding(5)
        .floating(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
    }

    func navButton(_ label: String, _ destination: CLLocationCoordinate2D) -> some View {
        Button(label, action: { camera.center = destination })
    }
}

@available(iOS 14.0, *)
struct CameraDebugViewModifier: ViewModifier {
    var alignment: Alignment
    @Binding var camera: CameraState
    func body(content: Content) -> some View {
        content.safeOverlay(alignment: alignment) {
            CameraDebugView(camera: $camera)
        }
    }
}

@available(iOS 14.0, *)
extension View {
    func cameraDebugOverlay(
        alignment: Alignment = .bottomTrailing,
        camera: Binding<CameraState>) -> some  View {
            modifier(CameraDebugViewModifier(alignment: alignment, camera: camera.projectedValue))
    }
}

@available(iOS 14.0, *)
struct CameraDebugView_Preview: PreviewProvider {
    struct PreviewView: View {
        @State var camera = CameraState(
            center: .london,
            padding: .zero,
            zoom: 12,
            bearing: -0.76890,
            pitch: 32.77)
        var body: some View {
            CameraDebugView(camera: $camera)
        }
    }
    static var previews: some View {
            PreviewView()
    }
}


