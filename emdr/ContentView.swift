//
//  ContentView.swift
//  emdr
//
//  Created by Vlad Md Golam on 02.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var pointsPerSecond: Float = 2500
    @State private var paused: Bool = false
    private let dotDiameter: CGFloat = 80
    @State private var showResetToast: Bool = false
    @State private var lastWidth: CGFloat = 0
    @State private var isSliding: Bool = false
    // pointsPerSecond is authoritative; default is 2500 pt/s
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Metal-backed moving dot
                MetalView(
                    speed: pointsPerSecond,
                    dotRadius: Float(dotDiameter / 2),
                    color: SIMD4<Float>(1, 1, 1, 1),
                    paused: paused,
                    onTripleTap: { handleReset() },
                    onTap: { paused.toggle() },
                    onPanChanged: { dy in handlePanChanged(dy) },
                    onPanEnded: { handlePanEnded() }
                )
                .ignoresSafeArea()

                // HUD/Toast overlay only; no hit testing so gestures reach MetalView
                Color.clear.allowsHitTesting(false)

                // HUD Overlay (only while sliding) — show only the number (pt/s)
                if isSliding {
                    VStack {
                        HStack {
                            Text("\(Int(pointsPerSecond))")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6), in: Capsule())
                            Spacer()
                        }
                        .padding([.top, .leading], 12)
                        Spacer()
                    }
                    .transition(.opacity)
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
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                lastWidth = newWidth
            }
        }
    }

    // MARK: - Gesture handlers via MetalView
    private func handleReset() {
        paused = false
        pointsPerSecond = 2500
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { showResetToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { showResetToast = false }
        }
    }

    private func handlePanChanged(_ dy: CGFloat) {
        isSliding = true
        // Up is negative dy -> increases speed; down decreases.
        let deltaSpeed = Float(-dy) * 15.0 // scale factor
        let newSpeed = max(100, min(8000, pointsPerSecond + deltaSpeed))
        pointsPerSecond = newSpeed
    }

    private func handlePanEnded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.2)) { isSliding = false }
        }
    }
}

#Preview {
    ContentView()
}
