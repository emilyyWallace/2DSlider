//
//  DotsGridView.swift
//  2DSlider
//
//  Created by Emily Wallace on 12/2/25.
//

import SwiftUI

/// Grid of dots with proximity glow effect when dragging the circle
struct DotsGridView: View {
	let config: GridConfiguration
	let containerSize: CGSize
	let gridOrigin: CGPoint
	let gridSpacingX: CGFloat
	let gridSpacingY: CGFloat
	let dotSize: CGFloat
	let gridIndex: (x: Int, y: Int)
	let previousGridIndex: (x: Int, y: Int)?
	let liveCircleCenter: CGPoint
	let isDragging: Bool

	var body: some View {
		ZStack {
			let centerIndex = config.numDotsWidth / 2
			ForEach(0..<config.numDotsWidth, id: \.self) { i in
				ForEach(0..<config.numDotsHeight, id: \.self) { j in
					let isCenter = (i == centerIndex && j == centerIndex)
					let isPrevious = checkIsPrevious(i: i, j: j)
					let inSameRowOrCol = (i == gridIndex.x || j == gridIndex.y)

					let dotPosition = calculateDotPosition(i: i, j: j, centerIndex: centerIndex)
					let glowEffects = calculateGlowEffects(dotPosition: dotPosition)

					ZStack {
						// Center dot: hollow ring
						if isCenter {
							Circle()
								.stroke(Color.gray, lineWidth: 2)
								.frame(width: dotSize * 1.4, height: dotSize * 1.4)
						// Previous position: light grey filled
						} else if isPrevious {
							Circle()
								.fill(Color(white: 0.7))
								.frame(width: dotSize * 1.4, height: dotSize * 1.4)
						// Normal dots: white if aligned with circle, grey otherwise
						} else {
							Circle()
								.fill(inSameRowOrCol ? .white : Color.gray)
								.frame(width: dotSize, height: dotSize)
						}
					}
					.scaleEffect(glowEffects.scale)
					.shadow(
						color: Color.white.opacity(glowEffects.shadowOpacity),
						radius: glowEffects.shadowRadius
					)
					.position(dotPosition)
				}
			}
		}
		.animation(.spring(response: 0.25, dampingFraction: 0.8), value: isDragging)
	}

	// Check if this dot was the previous circle position
	private func checkIsPrevious(i: Int, j: Int) -> Bool {
		guard let prev = previousGridIndex else { return false }
		return prev.x == i && prev.y == j &&
			   (prev.x != gridIndex.x || prev.y != gridIndex.y)
	}

	private func calculateDotPosition(i: Int, j: Int, centerIndex: Int) -> CGPoint {
		let dotX = gridOrigin.x + CGFloat(i - config.numDotsWidth / 2) * gridSpacingX
		let dotY = gridOrigin.y + CGFloat(j - config.numDotsHeight / 2) * gridSpacingY
		return CGPoint(x: dotX, y: dotY)
	}

	// Proximity glow: dots near the dragged circle grow and glow
	// Influence decreases with distance, max radius ~2 cell widths
	private func calculateGlowEffects(dotPosition: CGPoint) -> (scale: CGFloat, shadowRadius: CGFloat, shadowOpacity: Double) {
		let dx = dotPosition.x - liveCircleCenter.x
		let dy = dotPosition.y - liveCircleCenter.y
		let distance = sqrt(dx * dx + dy * dy)
		let maxRadius = gridSpacingX * 2.2

		let rawInfluence = max(0, 1 - distance / maxRadius)
		let influence = isDragging ? rawInfluence : 0

		let glowScale: CGFloat = 1.0 + influence * 5
		let glowShadowRadius: CGFloat = influence * 24
		let glowShadowOpacity: Double = Double(influence) * 0.9

		return (glowScale, glowShadowRadius, glowShadowOpacity)
	}
}
