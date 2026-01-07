//
//  GridConfiguration.swift
//  2DSlider
//
//  Created by Emily Wallace on 12/2/25.
//

import SwiftUI

/// Configuration values for the 2D grid slider
struct GridConfiguration {
	// Grid dimensions
	let numDotsWidth: Int = 11
	let numDotsHeight: Int = 11

	let dragScale: CGFloat = 1.5

	func containerSize(screenWidth: CGFloat) -> CGSize {
		let squareSize = screenWidth * 0.9
		return CGSize(width: squareSize, height: squareSize)
	}
	
	func gridOrigin(containerSize: CGSize) -> CGPoint {
		CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
	}

	func gridSpacingX(containerSize: CGSize) -> CGFloat {
		containerSize.width / CGFloat(numDotsWidth + 1)
	}

	func gridSpacingY(containerSize: CGSize) -> CGFloat {
		containerSize.height / CGFloat(numDotsHeight + 1)
	}

	func dotSize(gridSpacingX: CGFloat) -> CGFloat {
		gridSpacingX * 0.15
	}

	func circleSize(gridSpacingX: CGFloat) -> CGFloat {
		gridSpacingX * 0.85
	}
}
