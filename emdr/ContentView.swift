//
//  ContentView.swift
//  emdr
//
//  Created by Vlad Md Golam on 02.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var animate: Bool = false
    @State private var animationDuration: Double = 1.0
    private let dotSize: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()
                
                // Moving white dot
                Circle()
                    .fill(Color.white)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: animate ? (geometry.size.width - dotSize) / 2 : -(geometry.size.width - dotSize) / 2)
                    .animation(
                        .linear(duration: animationDuration)
                        .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
            .onAppear {
                setupAnimation(width: geometry.size.width)
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                setupAnimation(width: newWidth)
            }
        }
    }
    
    private func setupAnimation(width: CGFloat) {
        calculateAnimationDuration(width: width)
        // Reset to left edge without animation, then start bouncing
        withAnimation(.none) { animate = false }
        DispatchQueue.main.async { animate = true }
    }
    
    private func calculateAnimationDuration(width: CGFloat) {
        // Map screen width to animation duration (similar to the web version)
        // Smaller screens = faster animation, larger screens = slower animation
        let minWidth: CGFloat = 320 // iPhone SE width
        let maxWidth: CGFloat = 428 // iPhone Pro Max width
        let minDuration: Double = 0.5
        let maxDuration: Double = 1.0
        
        animationDuration = mapLinear(
            value: width,
            inputMin: minWidth,
            inputMax: maxWidth,
            outputMin: minDuration,
            outputMax: maxDuration
        )
    }
    
    // Removed explicit offset mutations; animation is driven by `animate`
    
    private func mapLinear(value: CGFloat, inputMin: CGFloat, inputMax: CGFloat, outputMin: Double, outputMax: Double) -> Double {
        let clampedValue = max(inputMin, min(inputMax, value))
        let normalizedValue = (clampedValue - inputMin) / (inputMax - inputMin)
        return outputMin + Double(normalizedValue) * (outputMax - outputMin)
    }
}

#Preview {
    ContentView()
}
