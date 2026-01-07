//
//  GridHelpers.swift
//  2DSlider
//
//  Created by Emily Wallace on 12/2/25.
//

import SwiftUI

/// Utility functions for grid calculations and positioning
struct GridHelpers {
	/// Converts a screen point to the nearest grid index (for snapping)
	static func findNearestGridIndex(
		at point: CGPoint,
		gridOrigin: CGPoint,
		gridSpacingX: CGFloat,
		gridSpacingY: CGFloat,
		numDotsWidth: Int
	) -> (x: Int, y: Int) {
		let relativeX = point.x - gridOrigin.x
		let relativeY = point.y - gridOrigin.y

		let spacingUnitsX = relativeX / gridSpacingX
		let spacingUnitsY = relativeY / gridSpacingY

		let centerIndex = numDotsWidth / 2
		let i = Int(round(spacingUnitsX)) + centerIndex
		let j = Int(round(spacingUnitsY)) + centerIndex

		let clampedI = max(0, min(numDotsWidth - 1, i))
		let clampedJ = max(0, min(numDotsWidth - 1, j))

		return (x: clampedI, y: clampedJ)
	}

	/// Keeps the circle fully inside the container, accounting for scaled size
	static func clampCircleCenter(
		_ point: CGPoint,
		containerSize: CGSize,
		circleSize: CGFloat,
		dragScale: CGFloat
	) -> CGPoint {
		// Effective radius when dragging (scaled up + padding)
		let radius = ((circleSize / 2) * dragScale) + (dragScale * 2)

		let minX = radius
		let maxX = containerSize.width - radius
		let minY = radius
		let maxY = containerSize.height - radius

		let clampedX = min(max(point.x, minX), maxX)
		let clampedY = min(max(point.y, minY), maxY)

		return CGPoint(x: clampedX, y: clampedY)
	}

	/// Converts a grid index to screen position
	static func calculateCirclePosition(
		gridIndex: (x: Int, y: Int),
		gridOrigin: CGPoint,
		gridSpacingX: CGFloat,
		gridSpacingY: CGFloat,
		numDotsWidth: Int
	) -> CGPoint {
		let centerIndex = numDotsWidth / 2
		let x = gridOrigin.x + CGFloat(gridIndex.x - centerIndex) * gridSpacingX
		let y = gridOrigin.y + CGFloat(gridIndex.y - centerIndex) * gridSpacingY
		return CGPoint(x: x, y: y)
	}
}
