//
//  ContentView.swift
//  2DSlider
//
//  Created by Emily Wallace on 12/2/25.
//

import SwiftUI

/// Main view: 2D grid slider with draggable circle that snaps to dots
struct ContentView: View {
	private let config = GridConfiguration()

	// State
	@State private var gridIndex: (x: Int, y: Int) = (3, 3) // Current snapped position
	@State private var screenSize: CGSize = .zero
	@State private var dragOffset: CGSize = .zero // Offset from snap point while dragging
	@State private var previousGridIndex: (x: Int, y: Int)? = nil // For visual feedback
	@State private var isDragging: Bool = false

	// Computed layout properties
	private var containerSize: CGSize {
		config.containerSize(screenWidth: screenSize.width)
	}

	private var gridOrigin: CGPoint {
		config.gridOrigin(containerSize: containerSize)
	}

	private var gridSpacingX: CGFloat {
		config.gridSpacingX(containerSize: containerSize)
	}

	private var gridSpacingY: CGFloat {
		config.gridSpacingY(containerSize: containerSize)
	}

	private var dotSize: CGFloat {
		config.dotSize(gridSpacingX: gridSpacingX)
	}

	private var circleSize: CGFloat {
		config.circleSize(gridSpacingX: gridSpacingX)
	}

	private var circlePosition: CGPoint {
		GridHelpers.calculateCirclePosition(
			gridIndex: gridIndex,
			gridOrigin: gridOrigin,
			gridSpacingX: gridSpacingX,
			gridSpacingY: gridSpacingY,
			numDotsWidth: config.numDotsWidth
		)
	}

	// Real-time position including drag offset
	private var liveCircleCenter: CGPoint {
		CGPoint(
			x: circlePosition.x + dragOffset.width,
			y: circlePosition.y + dragOffset.height
		)
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack {
					BackgroundGradientView()

					DotsGridView(
						config: config,
						containerSize: containerSize,
						gridOrigin: gridOrigin,
						gridSpacingX: gridSpacingX,
						gridSpacingY: gridSpacingY,
						dotSize: dotSize,
						gridIndex: gridIndex,
						previousGridIndex: previousGridIndex,
						liveCircleCenter: liveCircleCenter,
						isDragging: isDragging
					)

					DraggableCircleView(
						circleSize: circleSize,
						dragScale: config.dragScale,
						isDragging: isDragging,
						circlePosition: circlePosition,
						dragOffset: dragOffset
					)
				}
				.frame(width: containerSize.width, height: containerSize.height)
				.mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
				.contentShape(Rectangle())
				.gesture(dragGesture)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.padding()
			.onChange(of: geometry.size) { _, newValue in
				screenSize = newValue
			}
			.onAppear {
				screenSize = geometry.size
			}
		}
	}

	// Drag gesture: free movement while dragging, snap to nearest dot on release
	private var dragGesture: some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { value in
				isDragging = true

				// Keep circle inside container
				let clampedCenter = GridHelpers.clampCircleCenter(
					value.location,
					containerSize: containerSize,
					circleSize: circleSize,
					dragScale: config.dragScale
				)

				dragOffset = CGSize(
					width: clampedCenter.x - circlePosition.x,
					height: clampedCenter.y - circlePosition.y
				)
			}
			.onEnded { value in
				let finalCenter = GridHelpers.clampCircleCenter(
					value.location,
					containerSize: containerSize,
					circleSize: circleSize,
					dragScale: config.dragScale
				)

				// Find nearest dot and snap to it
				let nearestIndex = GridHelpers.findNearestGridIndex(
					at: finalCenter,
					gridOrigin: gridOrigin,
					gridSpacingX: gridSpacingX,
					gridSpacingY: gridSpacingY,
					numDotsWidth: config.numDotsWidth
				)

				previousGridIndex = gridIndex

				withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
					gridIndex = nearestIndex
					dragOffset = .zero
				}

				isDragging = false
			}
	}
}

#Preview {
	ContentView()
}
