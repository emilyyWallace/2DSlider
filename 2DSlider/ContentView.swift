import SwiftUI

struct ContentView: View {

	// MARK: - Grid Configuration

	private let numDotsWidth: Int = 11  // Total dots across
	private let numDotsHeight: Int = 11  // Total dots down
	private let dragScale: CGFloat = 1.5  // How much the circle grows when dragging

	// MARK: - State

	@State private var gridIndex: (x: Int, y: Int) = (3, 3)  // Which dot the circle is snapped to
	@State private var screenSize: CGSize = .zero  // Updated from geometry reader
	@State private var dragOffset: CGSize = .zero  // Distance from snap point while dragging
	@State private var previousGridIndex: (x: Int, y: Int)? = nil  // Track where we moved from

	@State private var isDragging: Bool = false  // Active drag state

	@State private var snapPulse: CGFloat = 0  // For snap animation (not currently used)

	// MARK: - Layout helpers

	private var containerSize: CGSize {
		let squareSize = screenSize.width * 0.9  // 90% of screen width
		return CGSize(width: squareSize, height: squareSize)
	}

	private var gridOrigin: CGPoint {
		CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
	}

	private var gridSpacingX: CGFloat {
		containerSize.width / CGFloat(numDotsWidth + 1)
	}

	private var gridSpacingY: CGFloat {
		containerSize.height / CGFloat(numDotsHeight + 1)
	}

	private var dotSize: CGFloat {
		gridSpacingX * 0.15  // Dots are 15% of spacing
	}

	private var circleSize: CGFloat {
		gridSpacingX * 0.85  // Main circle is 85% of spacing
	}

	private var circlePosition: CGPoint {
		let centerIndex = numDotsWidth / 2
		let x = gridOrigin.x + CGFloat(gridIndex.x - centerIndex) * gridSpacingX
		let y = gridOrigin.y + CGFloat(gridIndex.y - centerIndex) * gridSpacingY
		return CGPoint(x: x, y: y)
	}
	
	private var activeGridIndex: (x: Int, y: Int) {
		// Index of dots grid for where the main circle is
		// While dragging: live-update based on where the circle actually is
		// After release: use the snapped position
		if isDragging {
			let livePoint = CGPoint(
				x: circlePosition.x + dragOffset.width,
				y: circlePosition.y + dragOffset.height
			)
			return findNearestGridIndex(at: livePoint)
		} else {
			// After snapping, use the committed index
			return gridIndex
		}
	}

	private var liveCircleCenter: CGPoint {
		// Real-time circle position including any drag offset
		CGPoint(
			x: circlePosition.x + dragOffset.width,
			y: circlePosition.y + dragOffset.height
		)
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack { // This positions the interactive grid in the center of the screen
				ZStack { // This is the interactive part of the view
					// MARK: Background gradients
					// Base gradient: white at top → black at bottom
					LinearGradient(
							colors: [
								Color.white.opacity(0.25),
								Color.black.opacity(0.9)
							],
							startPoint: .top,
							endPoint: .bottom
						)

						// Layered gradient: white on left → amber on right
						// Using plusLighter blend mode to add warmth
						LinearGradient(
							colors: [
								Color.white.opacity(0.1),
								Color.orange.opacity(0.4)  // tweak tone here
							],
							startPoint: .leading,
							endPoint: .trailing
						)
						.blendMode(.plusLighter)  // Additive blending for glow effect

					// MARK: Dots grid (same coordinate space as the circle)
					ZStack {
						let centerIndex = numDotsWidth / 2
						ForEach(0..<numDotsWidth, id: \.self) { i in
							ForEach(0..<numDotsHeight, id: \.self) { j in
								// Figure out what kind of dot this is
								let isCenter = (i == centerIndex && j == centerIndex)

								// Check if this was where we just moved from
								let isPrevious: Bool = {
									guard let prev = previousGridIndex else { return false }
									return prev.x == i && prev.y == j &&
										   (prev.x != gridIndex.x || prev.y != gridIndex.y)
								}()

								// Highlight dots in same row or column as the circle
								let inSameRowOrCol = (i == gridIndex.x || j == gridIndex.y)

								// Calculate actual screen position for this dot
								let dotX = gridOrigin.x + CGFloat(i - numDotsWidth / 2) * gridSpacingX
								let dotY = gridOrigin.y + CGFloat(j - numDotsHeight / 2) * gridSpacingY

								// MARK: Proximity glow effect
								// Distance from this dot to the live circle center (in points)
								let dx = dotX - liveCircleCenter.x
								let dy = dotY - liveCircleCenter.y
								let distance = sqrt(dx * dx + dy * dy)

								// Radius of influence (tune this)
								let maxRadius = gridSpacingX * 2.2  // about ~2 cell widths

								// Influence factor 0...1 (1 = right under the circle, 0 = outside radius)
								let rawInfluence = max(0, 1 - distance / maxRadius)
								let influence = isDragging ? rawInfluence : 0  // only glow while dragging

								// Apply the glow - dots near the circle get bigger and glowier
								let glowScale: CGFloat = 1.0 + influence * 5       // up to 6× at center (tune this)
								let glowShadowRadius: CGFloat = influence * 24        // max radius 24
								let glowShadowOpacity: Double = Double(influence) * 0.9

								ZStack {
									if isCenter {
										// Center point: grey ring
										Circle()
											.stroke(Color.gray, lineWidth: 2)
											.frame(width: dotSize * 1.4, height: dotSize * 1.4)

									} else if isPrevious {
										// Moved from point: slightly larger, lighter grey
										Circle()
											.fill(Color(white: 0.7))
											.frame(width: dotSize * 1.4, height: dotSize * 1.4)

									} else {
										// Normal dots:
										// same row or col as big circle: solid white
										// others: grey
										Circle()
											.fill(inSameRowOrCol ? .white : Color.gray)
											.frame(width: dotSize, height: dotSize)
									}
								}
								// NEW: smooth circular “field” around the circle
								.scaleEffect(glowScale)
								.shadow(
									color: Color.white.opacity(glowShadowOpacity),
									radius: glowShadowRadius
								)
								.position(
									x: dotX,
									y: dotY
								)
							}
						}
					}.animation(.spring(response: 0.25, dampingFraction: 0.8), value: isDragging)

					// MARK: Main draggable circle
					Circle()
						.fill(.white)
						.frame(width: circleSize, height: circleSize)
						.scaleEffect(isDragging ? dragScale : 1.0)  // Grow when picked up
						// Soft glow using a shadow
						.shadow(
							color: Color.white.opacity(isDragging ? 0.75 : 0),
							radius: isDragging ? 24 : 0
						)
						// Tiny extra fade when dragging for visual polish
						.opacity(isDragging ? 0.96 : 1.0)
						.position(
							x: circlePosition.x + dragOffset.width,
							y: circlePosition.y + dragOffset.height
						)
						// Old approach: gesture on circle directly (moved to container below)
//						.gesture(
//							dragPositionGesture(
//								containerSize: containerSize,
//								gridSpacingX: gridSpacingX,
//								gridSpacingY: gridSpacingY,
//								gridOrigin: gridOrigin
//							)
//						)
						.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
						// Snap pulse effect (not currently used)
						//.scaleEffect((isDragging ? dragScale : 1.0) + snapPulse)
				}
				.frame(width: containerSize.width, height: containerSize.height)
				.mask(
					RoundedRectangle(cornerRadius: 16, style: .continuous)  // Rounded corners
				)
				.contentShape(Rectangle())  // Make the whole container tappable
				.gesture(
					// Gesture on the whole container so you can drag from anywhere
					dragPositionGesture(
						containerSize: containerSize,
						gridSpacingX: gridSpacingX,
						gridSpacingY: gridSpacingY,
						gridOrigin: gridOrigin
					)
				)

			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.padding()
			.onChange(of: geometry.size) { _, newValue in
				screenSize = newValue  // Update when device rotates, etc.
			}
			.onAppear {
				screenSize = geometry.size  // Initialize on first load
			}
		}
	}

	// MARK: - Gestures

	private func dragPositionGesture(containerSize: CGSize,
									 gridSpacingX: CGFloat,
									 gridSpacingY: CGFloat,
									 gridOrigin: CGPoint) -> some Gesture {
		DragGesture(minimumDistance: 0)  // No minimum = responds immediately to touch
			.onChanged { value in
				isDragging = true

				// Where the user is touching
				let proposedCenter = value.location

				// Keep the circle fully inside the container (accounting for scale)
				let clampedCenter = clampCircleCenter(proposedCenter)

				// How far from the snapped position are we?
				dragOffset = CGSize(
					width: clampedCenter.x - circlePosition.x,
					height: clampedCenter.y - circlePosition.y
				)
			}
			.onEnded { value in
				// Where the circle ended up when released
				let proposedCenter = value.location
				let finalCenter = clampCircleCenter(proposedCenter)

				// Find the closest dot to snap to
				let nearestIndex = findNearestGridIndex(at: finalCenter)

				// Remember where we came from (for visual feedback)
				previousGridIndex = gridIndex

				// Animate the snap to the new position
				withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
					gridIndex = nearestIndex
					dragOffset = .zero  // Reset offset since we've snapped
				}

				isDragging = false
			}
	}
	// MARK: - Helpers

	private func findNearestGridIndex(at point: CGPoint) -> (x: Int, y: Int) {
		// Convert a screen point to the nearest grid index
		// This is how we snap the circle to dots

		// How far from center (in pixels)?
		let relativeX = point.x - gridOrigin.x
		let relativeY = point.y - gridOrigin.y

		// How many spacing units away from center?
		let spacingUnitsX = relativeX / gridSpacingX
		let spacingUnitsY = relativeY / gridSpacingY

		// Convert to grid index (center dot is at numDotsWidth/2)
		let centerIndex = numDotsWidth / 2  // = 5 for 11x11
		let i = Int(round(spacingUnitsX)) + centerIndex
		let j = Int(round(spacingUnitsY)) + centerIndex

		// Clamp to valid range (0 to 10 for 11x11 grid)
		let clampedI = max(0, min(numDotsWidth - 1, i))
		let clampedJ = max(0, min(numDotsHeight - 1, j))

		return (x: clampedI, y: clampedJ)
	}

	private func clampCircleCenter(_ point: CGPoint) -> CGPoint {
		// Keep the circle fully inside the container, accounting for its scaled size

		// Effective radius when dragging (scaled up + a bit of padding)
		let radius = ((circleSize / 2) * dragScale) + (dragScale * 2)

		// Boundaries
		let minX = radius
		let maxX = containerSize.width - radius
		let minY = radius
		let maxY = containerSize.height - radius

		// Clamp the point
		let clampedX = min(max(point.x, minX), maxX)
		let clampedY = min(max(point.y, minY), maxY)

		return CGPoint(x: clampedX, y: clampedY)
	}
}

#Preview {
	ContentView()
}
