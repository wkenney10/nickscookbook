import SwiftUI

// MARK: - Nick's Cartoon Logo
//
// A two-colour cartoon portrait logo — orange background with a dark
// silhouette — used in the empty-state hero area of Nick's Cookbook.
// The style is deliberately simple and bold so it reads well at any size.

struct NickLogoView: View {
    var size: CGFloat = 110

    // Two brand colours
    private let bgColor   = Color.orange                               // warm orange
    private let fgColor   = Color(red: 0.12, green: 0.06, blue: 0.0)  // very dark brown

    var body: some View {
        ZStack {
            // ── Background circle ──────────────────────────────────────────
            Circle()
                .fill(bgColor)
                .frame(width: size, height: size)

            // ── Silhouette drawn with SwiftUI Canvas ───────────────────────
            Canvas { context, canvasSize in
                let w = canvasSize.width
                let h = canvasSize.height

                // Neck + shoulders (drawn first so head sits on top)
                let shoulderPath = shouldersPath(in: canvasSize)
                context.fill(shoulderPath, with: .color(fgColor))

                // Head
                let headPath = headPath(in: canvasSize)
                context.fill(headPath, with: .color(fgColor))

                // Facial features — two small bright dots for eyes
                let eyeY  = h * 0.315
                let eyeR  = w * 0.030
                let leftEyeX  = w * 0.435
                let rightEyeX = w * 0.565

                var eyeLeft = Path()
                eyeLeft.addEllipse(in: CGRect(x: leftEyeX - eyeR, y: eyeY - eyeR,
                                              width: eyeR * 2, height: eyeR * 2))
                context.fill(eyeLeft, with: .color(.white))

                var eyeRight = Path()
                eyeRight.addEllipse(in: CGRect(x: rightEyeX - eyeR, y: eyeY - eyeR,
                                               width: eyeR * 2, height: eyeR * 2))
                context.fill(eyeRight, with: .color(.white))

                // Smile arc
                var smilePath = Path()
                smilePath.move(to: CGPoint(x: w * 0.43, y: h * 0.365))
                smilePath.addQuadCurve(to:    CGPoint(x: w * 0.57, y: h * 0.365),
                                       control: CGPoint(x: w * 0.50, y: h * 0.400))
                context.stroke(smilePath,
                               with: .color(.white),
                               style: StrokeStyle(lineWidth: w * 0.022, lineCap: .round))

                // Chef-style hat brim + top
                let hatPath = hatPath(in: canvasSize)
                context.fill(hatPath, with: .color(fgColor))
            }
            .frame(width: size, height: size)
        }
        .clipShape(Circle())
    }

    // MARK: - Shape helpers

    private func headPath(in size: CGSize) -> Path {
        let w = size.width, h = size.height
        let cx = w / 2
        let cy = h * 0.365           // centre-y of the head oval
        let rx = w * 0.175           // horizontal radius
        let ry = h * 0.190           // vertical radius
        var p = Path()
        p.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        return p
    }

    private func shouldersPath(in size: CGSize) -> Path {
        let w = size.width, h = size.height
        // A rounded trapezoid for the shirt/shoulders at the bottom of the circle
        var p = Path()
        p.move(to: CGPoint(x: w * 0.05, y: h))          // bottom-left corner
        p.addLine(to: CGPoint(x: w * 0.95, y: h))        // bottom-right corner
        // curve up to the right shoulder
        p.addQuadCurve(to:    CGPoint(x: w * 0.80, y: h * 0.545),
                       control: CGPoint(x: w * 0.92, y: h * 0.56))
        // neckline (concave curve across top)
        p.addQuadCurve(to:    CGPoint(x: w * 0.20, y: h * 0.545),
                       control: CGPoint(x: w * 0.50, y: h * 0.500))
        // curve down to the left shoulder
        p.addQuadCurve(to:    CGPoint(x: w * 0.05, y: h),
                       control: CGPoint(x: w * 0.08, y: h * 0.56))
        p.closeSubpath()
        return p
    }

    private func hatPath(in size: CGSize) -> Path {
        let w = size.width, h = size.height
        // A simple two-part chef's hat:
        //  1. Wide flat brim
        //  2. Rounded toque on top
        var p = Path()

        // Brim (a thin rounded rectangle)
        let brimY = h * 0.175
        let brimH = h * 0.040
        p.addRoundedRect(in: CGRect(x: w * 0.30, y: brimY,
                                    width: w * 0.40, height: brimH),
                         cornerSize: CGSize(width: brimH / 2, height: brimH / 2))

        // Toque dome
        let toqueW = w * 0.30
        let toqueH = h * 0.120
        let toqueX = w * 0.35
        let toqueY = brimY - toqueH
        p.addEllipse(in: CGRect(x: toqueX, y: toqueY, width: toqueW, height: toqueH + brimH * 0.6))

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
}
