//
//  AtomBubble.swift
//  MoooMoooAccount
//
//  Created by Hualiteq International on 2026/3/18.
//

import Foundation
import SwiftUI

// MARK: - Floating Atom View
struct AtomBubble: View {
    let atom: Atom
    let onTap: () -> Void
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var pulse: Bool = false
    @State private var scale: CGFloat = 1.0
    @State private var showTapCount: Bool = false
    
    var body: some View {
        ZStack {
            // Outer glow ring for high levels
            if atom.level >= 5 {
                Circle()
                    .stroke(atom.color.opacity(0.3), lineWidth: 2)
                    .frame(width: atom.size + 14, height: atom.size + 14)
                    .scaleEffect(pulse ? 1.2 : 0.95)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [atom.color.opacity(0.95), atom.color.opacity(0.3)],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: atom.size
                    )
                )
                .frame(width: atom.size, height: atom.size)
                .shadow(color: atom.color.opacity(0.7), radius: pulse ? atom.glowRadius * 1.5 : atom.glowRadius)
                .scaleEffect(pulse ? 1.08 : 1.0)
            
            VStack(spacing: 1) {
                Text(atom.label)
                    .font(.system(size: max(atom.size * 0.28, 6), weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                // Tap progress bar
                if let remaining = atom.tapsToNextLevel {
                    let next = levelConfigs.first(where: { $0.tapsRequired > atom.taps })
                    let prev = levelConfigs.last(where: { $0.tapsRequired <= atom.taps })
                    let total = (next?.tapsRequired ?? atom.taps) - (prev?.tapsRequired ?? 0)
                    let done = total - remaining
                    let progress = total > 0 ? CGFloat(done) / CGFloat(total) : 1.0
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: atom.size * 0.6, height: 3)
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: atom.size * 0.6 * progress, height: 3)
                    }
                }
            }
            
            // Tap count popup
            if showTapCount {
                Text("+1")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .offset(y: -atom.size * 0.8)
                    .transition(.asymmetric(
                        insertion: .offset(y: 0).combined(with: .opacity),
                        removal: .offset(y: -10).combined(with: .opacity)
                    ))
            }
        }
        .ignoresSafeArea()
        .scaleEffect(scale)
        .offset(x: offsetX, y: offsetY)                          // ✅ applies float drift
        .position(x: atom.position.x, y: atom.position.y)        // ✅ places atom on screen
        .onAppear {
            let duration = Double.random(in: 2.5...4.0)
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                offsetY = CGFloat.random(in: -18...18)
                offsetX = CGFloat.random(in: -12...12)
                pulse = true
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.35)) { scale = 1.5 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { scale = 1.0 }
            }
            withAnimation { showTapCount = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation { showTapCount = false }
            }
            onTap()
        }
    }
}
