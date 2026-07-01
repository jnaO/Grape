import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// SMTM fork additions supporting a **true per-node colour transition** (node lerps old→new colour)
/// when the graph content recolours. Grape draws to a `Canvas`, so it doesn't get SwiftUI's implicit
/// colour animation — the renderer interpolates colours itself over a configurable duration/curve.

/// Easing applied to the linear transition progress. Kept minimal + self-contained (SwiftUI's
/// `Animation` curve can't be sampled from a `Canvas`); `easeInOut` mirrors the app's doughnut morph.
public enum GraphColorTransitionCurve: Sendable, Hashable {
    case linear
    case easeIn
    case easeOut
    case easeInOut

    /// Maps linear progress `t ∈ [0, 1]` to eased progress.
    @inlinable
    public func apply(_ t: Double) -> Double {
        let x = min(max(t, 0), 1)
        switch self {
        case .linear: return x
        case .easeIn: return x * x * x
        case .easeOut: return 1 - pow(1 - x, 3)
        case .easeInOut: return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
        }
    }
}

/// Pure sRGB linear interpolation between two colours (mirrors the app's
/// `Utilities/ColorInterpolation.swift` `lerpColor`, kept identical + unit-tested there).
@inlinable
func lerpColor(_ a: Color, _ b: Color, _ t: Double) -> Color {
    let x = min(max(t, 0), 1)
    #if canImport(AppKit)
    typealias PlatformColor = NSColor
    #else
    typealias PlatformColor = UIColor
    #endif
    guard let ca = PlatformColor(a).usingColorSpaceSRGB(),
        let cb = PlatformColor(b).usingColorSpaceSRGB()
    else { return a }

    var ra: CGFloat = 0, ga: CGFloat = 0, ba: CGFloat = 0, aa: CGFloat = 0
    var rb: CGFloat = 0, gb: CGFloat = 0, bb: CGFloat = 0, ab: CGFloat = 0
    ca.getRed(&ra, green: &ga, blue: &ba, alpha: &aa)
    cb.getRed(&rb, green: &gb, blue: &bb, alpha: &ab)

    let rr = ra + (rb - ra) * x
    let gg = ga + (gb - ga) * x
    let bb2 = ba + (bb - ba) * x
    let aa2 = aa + (ab - aa) * x
    return Color(.sRGB, red: Double(rr), green: Double(gg), blue: Double(bb2), opacity: Double(aa2))
}

#if canImport(AppKit)
extension NSColor {
    @inlinable
    func usingColorSpaceSRGB() -> NSColor? { usingColorSpace(.sRGB) }
}
#elseif canImport(UIKit)
extension UIColor {
    @inlinable
    func usingColorSpaceSRGB() -> UIColor? { self }
}
#endif

/// Platform-agnostic `CGColor` for a SwiftUI `Color` (used to fill the glyph alpha-mask tint).
@inlinable
func platformCGColor(_ color: Color) -> CGColor {
    #if canImport(AppKit)
    let ns = NSColor(color)
    return (ns.usingColorSpaceSRGB() ?? ns).cgColor
    #else
    return UIColor(color).cgColor
    #endif
}
