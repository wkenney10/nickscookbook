import SwiftUI

// MARK: - Nick's Cartoon Logo
//
// Two-colour (orange + dark brown) cartoon portrait of Nick —
// short neat hair, rectangular glasses, collared shirt.

struct NickLogoView: View {
    var size: CGFloat = 110

    private let bgColor = Color.orange
    private let fgColor = Color(red: 0.12, green: 0.06, blue: 0.0)   // very dark brown

    var body: some View {
        ZStack {
            Circle()
                .fill(bgColor)
                .frame(width: size, height: size)

            Canvas { context, canvasSize in
                let w = canvasSize.width
                let h = canvasSize.height

                // ── Shirt / shoulders ──────────────────────────────────────
                context.fill(shouldersPath(w: w, h: h), with: .color(fgColor))

                // ── Collar detail (small white V) ──────────────────────────
                var collar = Path()
                collar.move(to: CGPoint(x: w * 0.46, y: h * 0.545))
                collar.addLine(to: CGPoint(x: w * 0.50, y: h * 0.575))
                collar.addLine(to: CGPoint(x: w * 0.54, y: h * 0.545))
                context.stroke(collar, with: .color(.white.opacity(0.55)),
                               style: StrokeStyle(lineWidth: w * 0.025, lineCap: .round, lineJoin: .round))

                // ── Head ───────────────────────────────────────────────────
                context.fill(headPath(w: w, h: h), with: .color(fgColor))

                // ── Hair (short, sits on top of head) ─────────────────────
                context.fill(hairPath(w: w, h: h), with: .color(fgColor))

                // ── Ears (small dark ovals on sides of head) ──────────────
                let earY   = h * 0.355
                let earR   = CGSize(width: w * 0.032, height: h * 0.048)
                var leftEar = Path()
                leftEar.addEllipse(in: CGRect(x: w * 0.295 - earR.width, y: earY - earR.height,
                                              width: earR.width * 2, height: earR.height * 2))
                context.fill(leftEar, with: .color(fgColor))

                var rightEar = Path()
                rightEar.addEllipse(in: CGRect(x: w * 0.705 - earR.width, y: earY - earR.height,
                                               width: earR.width * 2, height: earR.height * 2))
                context.fill(rightEar, with: .color(fgColor))

                // ── Skin tone fill for face interior ──────────────────────
                // A slightly lighter ellipse punched inside the head to suggest the face
                let skinColor = Color(red: 0.92, green: 0.78, blue: 0.62)
                let faceW = w * 0.285, faceH = h * 0.295
                var faceFill = Path()
                faceFill.addEllipse(in: CGRect(x: w/2 - faceW/2, y: h * 0.215, width: faceW, height: faceH))
                context.fill(faceFill, with: .color(skinColor))

                // ── Eyes (simple dark dots) ────────────────────────────────
                let eyeY  = h * 0.320
                let eyeRx = w * 0.030, eyeRy = h * 0.020
                for xPos in [w * 0.435, w * 0.565] {
                    var eye = Path()
                    eye.addEllipse(in: CGRect(x: xPos - eyeRx, y: eyeY - eyeRy,
                                             width: eyeRx * 2, height: eyeRy * 2))
                    context.fill(eye, with: .color(fgColor))
                }

                // ── Glasses (rectangular frames + bridge) ─────────────────
                let glassY    = h * 0.308
                let glassH    = h * 0.055
                let glassW    = w * 0.115
                let glassGap  = w * 0.040  // gap between the two lenses
                let leftLensX = w/2 - glassGap/2 - glassW
                let rightLensX = w/2 + glassGap/2
                let cornerR   = CGSize(width: w * 0.018, height: w * 0.018)
                let frameWidth = w * 0.022

                // Left lens
                var leftLens = Path()
                leftLens.addRoundedRect(in: CGRect(x: leftLensX, y: glassY,
                                                   width: glassW, height: glassH),
                                        cornerSize: cornerR)
                context.stroke(leftLens, with: .color(fgColor),
                               style: StrokeStyle(lineWidth: frameWidth))

                // Right lens
                var rightLens = Path()
                rightLens.addRoundedRect(in: CGRect(x: rightLensX, y: glassY,
                                                    width: glassW, height: glassH),
                                         cornerSize: cornerR)
                context.stroke(rightLens, with: .color(fgColor),
                               style: StrokeStyle(lineWidth: frameWidth))

                // Bridge connecting lenses
                var bridge = Path()
                bridge.move(to:    CGPoint(x: leftLensX + glassW, y: glassY + glassH * 0.4))
                bridge.addLine(to: CGPoint(x: rightLensX,          y: glassY + glassH * 0.4))
                context.stroke(bridge, with: .color(fgColor),
                               style: StrokeStyle(lineWidth: frameWidth * 0.7))

                // Temple arms (extend outward from lenses)
                for (lensX, side) in [(leftLensX, -1.0), (rightLensX + glassW, 1.0)] {
                    var temple = Path()
                    temple.move(to:    CGPoint(x: lensX, y: glassY + glassH * 0.3))
                    temple.addLine(to: CGPoint(x: lensX + side * w * 0.048, y: glassY + glassH * 0.3))
                    context.stroke(temple, with: .color(fgColor),
                                   style: StrokeStyle(lineWidth: frameWidth * 0.7))
                }

                // ── Friendly smile ─────────────────────────────────────────
                var smile = Path()
                smile.move(to: CGPoint(x: w * 0.438, y: h * 0.385))
                smile.addQuadCurve(to:    CGPoint(x: w * 0.562, y: h * 0.385),
                                   control: CGPoint(x: w * 0.500, y: h * 0.415))
                context.stroke(smile, with: .color(fgColor),
                               style: StrokeStyle(lineWidth: w * 0.020, lineCap: .round))
            }
            .frame(width: size, height: size)
        }
        .clipShape(Circle())
    }

    // MARK: - Paths

    private func headPath(w: CGFloat, h: CGFloat) -> Path {
        var p = Path()
        // Slightly wider than tall, jawline is slightly narrower (chin)
        p.addEllipse(in: CGRect(x: w * 0.315, y: h * 0.200,
                                width: w * 0.370, height: h * 0.345))
        return p
    }

    private func hairPath(w: CGFloat, h: CGFloat) -> Path {
        // Short neat hair: a flattened dome that sits on the upper part of the head
        var p = Path()
        p.move(to: CGPoint(x: w * 0.315, y: h * 0.305))                      // left side
        p.addQuadCurve(to:    CGPoint(x: w * 0.330, y: h * 0.210),
                       control: CGPoint(x: w * 0.300, y: h * 0.240))         // left curve up
        p.addQuadCurve(to:    CGPoint(x: w * 0.500, y: h * 0.190),
                       control: CGPoint(x: w * 0.400, y: h * 0.185))         // across top-left
        p.addQuadCurve(to:    CGPoint(x: w * 0.670, y: h * 0.210),
                       control: CGPoint(x: w * 0.600, y: h * 0.185))         // across top-right
        p.addQuadCurve(to:    CGPoint(x: w * 0.685, y: h * 0.305),
                       control: CGPoint(x: w * 0.700, y: h * 0.240))         // right curve down
        p.addQuadCurve(to:    CGPoint(x: w * 0.315, y: h * 0.305),
                       control: CGPoint(x: w * 0.500, y: h * 0.250))         // close across
        p.closeSubpath()
        return p
    }

    private func shouldersPath(w: CGFloat, h: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0,    y: h))
        p.addLine(to: CGPoint(x: w, y: h))
        p.addQuadCurve(to:    CGPoint(x: w * 0.78, y: h * 0.540),
                       control: CGPoint(x: w * 0.95, y: h * 0.555))
        // neck indent right
        p.addQuadCurve(to:    CGPoint(x: w * 0.555, y: h * 0.515),
                       control: CGPoint(x: w * 0.70, y: h * 0.500))
        // neck indent left
        p.addQuadCurve(to:    CGPoint(x: w * 0.22, y: h * 0.540),
                       control: CGPoint(x: w * 0.30, y: h * 0.500))
        p.addQuadCurve(to:    CGPoint(x: 0, y: h),
                       control: CGPoint(x: w * 0.05, y: h * 0.555))
        p.closeSubpath()
        return p
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        NickLogoView(size: 80)
        NickLogoView(size: 110)
        NickLogoView(size: 140)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
