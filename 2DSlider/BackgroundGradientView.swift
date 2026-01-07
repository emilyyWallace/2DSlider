//
//  BackgroundGradientView.swift
//  2DSlider
//
//  Created by Emily Wallace on 12/2/25.
//

import SwiftUI

/// Layered gradient background: white-to-black vertical + warm horizontal glow
struct BackgroundGradientView: View {
	var body: some View {
		ZStack {
			// Base gradient: white at top → black at bottom
			LinearGradient(
				colors: [
					Color.white.opacity(0.25),
					Color.black.opacity(0.9)
				],
				startPoint: .top,
				endPoint: .bottom
			)

			// Warm glow: white on left → amber on right
			// Additive blend mode creates luminous effect
			LinearGradient(
				colors: [
					Color.white.opacity(0.1),
					Color.orange.opacity(0.4)
				],
				startPoint: .leading,
				endPoint: .trailing
			)
			.blendMode(.plusLighter)
		}
	}
}
