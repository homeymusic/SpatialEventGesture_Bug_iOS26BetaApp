import SwiftUI

struct ContentView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    @State private var activeIndices: Set<Int> = []
    @State private var activeLocations: [CGPoint] = []
    @State private var didCancel = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if didCancel {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Touches Cancelled")
                        .foregroundColor(.red)
                        .font(.subheadline).bold()
                } else {
                    Text(
                        activeLocations.isEmpty
                            ? "No active touches"
                            : activeLocations
                                .map { String(format: "(%.1f, %.1f)", $0.x, $0.y) }
                                .joined(separator: "  ")
                    )
                    .font(.subheadline).bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 30)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(0..<colors.count, id: \.self) { index in
                        Rectangle()
                            .foregroundColor(colors[index])
                            .brightness(activeIndices.contains(index) ? -0.3 : 0)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)                    }
                }
                .gesture(
                    SpatialEventGesture()
                        .onChanged { events in
                            // clear any previous cancel state
                            didCancel = false

                            // capture active touch locations
                            let activeTouches = events.filter { $0.phase == .active }
                            activeLocations = activeTouches.map { $0.location }

                            // compute which columns/rectangles are hit
                            let colWidth = geo.size.width / CGFloat(colors.count)
                            activeIndices = Set(activeTouches.map { event in
                                let idx = Int(event.location.x / colWidth)
                                return min(max(idx, 0), colors.count - 1)
                            })
                        }
                        .onEnded { events in
                            // if any ended with .cancelled, show the warning
                            didCancel = events.contains { $0.phase == .cancelled }
                            // clear highlights & locations
                            activeIndices.removeAll()
                            activeLocations.removeAll()
                        }
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
