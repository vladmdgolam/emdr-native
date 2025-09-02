//
//  ContentView.swift
//  emdr
//
//  Created by Vlad Md Golam on 02.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var pointsPerSecond: Float = 400
    private let dotDiameter: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Metal-backed moving dot
                MetalView(
                    speed: pointsPerSecond,
                    dotRadius: Float(dotDiameter / 2),
                    color: SIMD4<Float>(1, 1, 1, 1)
                )
                .ignoresSafeArea()
            }
            .onAppear { calculateSpeed(width: geometry.size.width) }
            .onChange(of: geometry.size.width) { _, newWidth in calculateSpeed(width: newWidth) }
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
}

#Preview {
    ContentView()
}
