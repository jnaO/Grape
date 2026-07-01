import SwiftUI

@usableFromInline
enum PathOrSymbolSize: Equatable {
    case path(Path)
    case symbolSize(CGSize)
}

@usableFromInline
internal enum RenderOperation<NodeID: Hashable> {

    @usableFromInline
    struct Node {
        @usableFromInline
        let mark: NodeMark<NodeID>
        @usableFromInline
        let fill: GraphicsContext.Shading?
        @usableFromInline
        let stroke: GraphContentEffect.Stroke?
        @usableFromInline
        let pathOrSymbolSize: PathOrSymbolSize
        /// SMTM fork: the raw fill `Color` when `.foregroundStyle` was a plain `Color` (else `nil`),
        /// captured alongside the opaque `fill` Shading so the renderer can lerp it colour→colour.
        @usableFromInline
        let fillColor: Color?

        @inlinable
        init(
            _ mark: NodeMark<NodeID>,
            _ fill: GraphicsContext.Shading?,
            _ stroke: GraphContentEffect.Stroke?,
            _ pathOrSymbolSize: PathOrSymbolSize,
            _ fillColor: Color? = nil
        ) {
            self.mark = mark
            self.fill = fill
            self.stroke = stroke
            self.pathOrSymbolSize = pathOrSymbolSize
            self.fillColor = fillColor
        }
    }

    @usableFromInline
    struct Link {
        @usableFromInline
        let mark: LinkMark<NodeID>
        @usableFromInline
        let stroke: GraphContentEffect.Stroke?
        @usableFromInline
        let path: ((SIMD2<Double>, SIMD2<Double>) -> Path)?

        @inlinable
        init(
            _ mark: LinkMark<NodeID>,
            _ stroke: GraphContentEffect.Stroke?,
            _ path: ((SIMD2<Double>, SIMD2<Double>) -> Path)?
        ) {
            self.mark = mark
            self.stroke = stroke
            self.path = path
        }
    }
}

extension RenderOperation.Node: Equatable {
    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        let fillEq = lhs.fill == nil && rhs.fill == nil
        let pathEq = lhs.pathOrSymbolSize == rhs.pathOrSymbolSize
        return lhs.mark == rhs.mark
            && fillEq
            && lhs.stroke == rhs.stroke
            && pathEq
    }
}

extension RenderOperation.Link: Equatable {
    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        let pathEq = lhs.path == nil && rhs.path == nil
        return lhs.mark == rhs.mark
            && lhs.stroke == rhs.stroke
            && pathEq
    }
}

// @usableFromInline
// internal enum RenderingOperation<NodeID: Hashable> {
//     case node(
//         NodeMark<NodeID>,
//         GraphicsContext.Shading?,
//         StrokeStyle?,
//         ((SIMD2<Double>) -> Path)?
//     )
//     case link(
//         LinkMark<NodeID>,
//         GraphicsContext.Shading?,
//         StrokeStyle?,
//         ((SIMD2<Double>, SIMD2<Double>) -> Path)?
//     )
//     case label(Text, id: GraphRenderingStates<NodeID>.StateID)
// }

// extension RenderingOperation: Equatable {
//     @inlinable
//     internal static func == (lhs: Self, rhs: Self) -> Bool {
//         return false
//     }
// }
