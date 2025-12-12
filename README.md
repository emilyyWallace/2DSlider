# Interactive 2D Slider

A SwiftUI experiment featuring a draggable circle that snaps to a grid of dots with a dynamic proximity-based glow effect that simulates a two-dimensional slider.

## What It Does

- Displays a grid of dots in a centered square container
- Drag a white circle to any position and watch it snap to the nearest dot
- Dots near the circle glow and scale up while you're dragging
- Dots in the same row/column as the circle are highlighted
- Smooth spring-based animations create a natural, responsive feel

## Features I Implemented

- **Grid with Snap Points**: Grid of dots where a draggable circle snaps to positions with spring animation
- **Proximity Glow Effect**: Distance-based visual effect that makes nearby dots scale up (up to 6x) and glow white while dragging
- **Drag Anywhere Interaction**: The entire container responds to touch, not just the circle itself, making it easier to move the circle around

## What I Found Challenging

- **Getting the proximity glow math right**: Calculating the distance from each dot to the moving circle in real-time, then converting that to influence factors (0 to 1) for scaling and shadow effects took multiple attempts to get smooth
- **Clamping the circle within bounds**: Making sure the circle stayed fully inside the container while accounting for its scaled-up size during dragging required careful calculation of the effective radius

## What I Learned

- **Real-time distance calculations**: You can create dynamic visual effects by calculating distances between elements in real-time and using those values to drive animations and transformations
- **Gesture handling trade-offs**: Attaching a gesture to the container instead of just the draggable element creates a much better user experience, even though it requires more coordinate math
- **Coordinate space consistency**: Keeping the same coordinate space across all parts of the view (dots, circle, and gestures) by using shared grid origin and spacing calculations made everything align perfectly and simplified the math


---
*Created by Emily Wallace*
