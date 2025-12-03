# Interactive Grid with Proximity Glow

A SwiftUI experiment featuring a draggable circle that snaps to a grid of dots, with a dynamic proximity-based glow effect.

## What It Does

This app displays a centered interactive grid with:
- **11×11 grid of dots** arranged in a square container
- **Draggable white circle** that snaps to grid positions
- **Proximity glow effect** - dots near the circle glow and scale up while dragging
- **Visual feedback** - dots in the same row/column as the circle are highlighted
- **Smooth animations** - spring-based motion for natural feel

## How It Works

### Core Concepts

**Grid System**
- The grid uses a coordinate system centered at the middle dot (5,5 in an 11×11 grid)
- Each dot's position is calculated based on spacing derived from the container size
- The container is 90% of screen width, keeping everything proportional

**Drag Interaction**
- Touch anywhere in the container to move the circle to that location
- The circle follows your finger with smooth tracking
- On release, it snaps to the nearest grid dot with spring animation
- The circle is clamped to stay within bounds, even when scaled up

**Proximity Glow Effect**
- While dragging, dots within ~2 grid cells of the circle react
- Closer dots scale up more (up to 6×) and gain white glow shadows
- Effect uses distance-based influence factor (0 to 1)
- Only active during drag - disappears when you release

**Visual States**
- **Center dot**: Grey ring (the origin point)
- **Previous position**: Slightly larger, lighter grey dot
- **Same row/column**: Solid white dots
- **Other dots**: Grey dots
- **Near circle while dragging**: Glowing, scaled-up dots

### Key Components

**State Management**
- `gridIndex`: Which dot the circle is currently snapped to (x, y tuple)
- `dragOffset`: How far the circle has moved from its snapped position
- `isDragging`: Whether the user is actively dragging
- `previousGridIndex`: Tracks the last position for visual feedback

**Layout Helpers**
- `containerSize`: Square container sized at 90% of screen width
- `gridSpacing`: Distance between dots (calculated from container size)
- `circlePosition`: Screen position of the circle based on grid index
- `liveCircleCenter`: Real-time position including drag offset

**Gesture Handling**
- Gesture attached to entire container for easier interaction
- `onChanged`: Updates drag offset, keeps circle clamped in bounds
- `onEnded`: Finds nearest grid index and animates snap

## Technical Details

- **Language**: Swift
- **Framework**: SwiftUI
- **Minimum iOS**: iOS 14+ (uses modern SwiftUI features)
- **Animations**: Spring-based with tunable response and damping
- **Blend Mode**: `.plusLighter` for additive gradient layering

## Features to Tune

Want to adjust the feel? Here are some key values to play with:

| Property | Location | Effect |
|----------|----------|--------|
| `dragScale` | ContentView.swift:9 | How much circle grows when dragging (1.5 = 150%) |
| `maxRadius` | ContentView.swift:134 | Proximity glow radius (2.2 = ~2 cells) |
| `glowScale` | ContentView.swift:141 | Max scale for glowing dots (5 = up to 6× size) |
| `spring(response:dampingFraction:)` | Multiple locations | Animation timing and bounciness |

## Background Design

The container features a layered gradient background:
1. **Base layer**: White (top) → Black (bottom) for depth
2. **Accent layer**: White (left) → Orange/amber (right) with `.plusLighter` blend mode
3. Result: Subtle warm glow that adds dimension

---

## Reflections

### What Was Hard

<!-- Add your thoughts here about the challenging parts of this project -->


### What Was Surprising

<!-- Add your thoughts here about unexpected discoveries or behaviors -->


### What I Learned

<!-- Add your thoughts here about key takeaways and new skills -->


---

## Future Ideas

Some potential enhancements:
- Add haptic feedback on snap
- Make grid size adjustable
- Add color themes or gradient options
- Multi-circle interaction
- Save/load grid patterns
- Animate between different grid configurations
