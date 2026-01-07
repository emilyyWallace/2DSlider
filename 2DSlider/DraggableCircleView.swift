//
//  DraggableCircleView.swift
//  2DSlider
//
//  Created by Emily Wallace on 12/2/25.
//

import SwiftUI

/// Main draggable circle with visual feedback:
/// - Scales up when dragging
/// - Glows with shadow during drag
/// - Slightly fades for depth effect
struct DraggableCircleView: View {
	let circleSize: CGFloat
	let dragScale: CGFloat
	let isDragging: Bool
	let circlePosition: CGPoint
	let dragOffset: CGSize

	var body: some View {
		Circle()
			.fill(.white)
			.frame(width: circleSize, height: circleSize)
			.scaleEffect(isDragging ? dragScale : 1.0)
			.shadow(
				color: Color.white.opacity(isDragging ? 0.75 : 0),
				radius: isDragging ? 24 : 0
			)
			.opacity(isDragging ? 0.96 : 1.0)
			.position(
				x: circlePosition.x + dragOffset.width,
				y: circlePosition.y + dragOffset.height
			)
			.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
	}
}
