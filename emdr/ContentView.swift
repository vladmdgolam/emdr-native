//
//  ContentView.swift
//  emdr
//
//  Created by Vlad Md Golam on 02.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var pointsPerSecond: Float = 400
    @State private var paused: Bool = false
    private let dotDiameter: CGFloat = 40
    @State private var showResetToast: Bool = false
    @State private var lastWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Metal-backed moving dot
                MetalView(
                    speed: pointsPerSecond,
                    dotRadius: Float(dotDiameter / 2),
                    color: SIMD4<Float>(1, 1, 1, 1),
                    paused: paused,
                    onTripleTap: {
                        paused = false
                        // Recalculate default speed based on current width
                        calculateSpeed(width: lastWidth)
                        // Visual feedback
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            showResetToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                showResetToast = false
                            }
                        }
                    }
                )
                .ignoresSafeArea()

                // Gesture layer
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(tapToPause)
                    .simultaneousGesture(swipeToAdjustSpeed)

                // HUD Overlay
                VStack {
                    HStack {
                        Text("Speed: \(Int(pointsPerSecond)) pt/s")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        Spacer()
                    }
                    .padding([.top, .leading], 12)
                    Spacer()
                }

                // Reset toast
                if showResetToast {
                    VStack {
                        Text("Reset to defaults")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.7), in: Capsule())
                        Spacer()
                    }
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onAppear {
                lastWidth = geometry.size.width
                calculateSpeed(width: geometry.size.width)
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                lastWidth = newWidth
                calculateSpeed(width: newWidth)
            }
        }
    }
    
    private func calculateSpeed(width: CGFloat) {
        // Keep behavior similar to web: map width to a one-way duration [0.5, 1.0]s
        let minWidth: CGFloat = 320
        let maxWidth: CGFloat = 428
        let minDuration: CGFloat = 0.5
        let maxDuration: CGFloat = 1.0
        let clamped = max(minWidth, min(maxWidth, width))
        let t = (clamped - minWidth) / (maxWidth - minWidth)
        let duration = minDuration + t * (maxDuration - minDuration)
        let travel = max(0, width - dotDiameter) // points traveled one-way by the center
        pointsPerSecond = Float(travel / duration)
    }

    // MARK: - Gestures
    private var tapToPause: some Gesture {
        TapGesture()
            .onEnded { paused.toggle() }
    }

    private var swipeToAdjustSpeed: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onEnded { value in
                // Up increases speed, Down decreases. Scale factor keeps it subtle.
                let delta = Float(-value.translation.height) * 2.0 // pts -> points/sec
                let newSpeed = max(50, min(3000, pointsPerSecond + delta))
                pointsPerSecond = newSpeed
            }
    }
}

#Preview {
    ContentView()
}
