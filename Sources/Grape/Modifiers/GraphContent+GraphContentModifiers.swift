import SwiftUI

#if canImport(Charts)
    import Charts
#endif

extension GraphContent {
    @inlinable
    @_disfavoredOverload
    public func foregroundStyle<S>(_ style: S) -> some GraphContent<NodeID>
    where S: SwiftUI.ShapeStyle {
        // SMTM fork: capture the raw Color if the generic style happens to be one, for colour lerp.
        return ModifiedGraphContent(self, GraphContentEffect.Shading(.style(style), fillColor: style as? Color))
    }

    @inlinable
    public func foregroundStyle(_ color: Color) -> some GraphContent<NodeID> {
        // SMTM fork: thread the raw Color through so the renderer can lerp it colour→colour.
        return ModifiedGraphContent(self, GraphContentEffect.Shading(.color(color), fillColor: color))
    }

    @inlinable
    @_disfavoredOverload
    public func symbol<S>(_ shape: S) -> some GraphContent<NodeID> where S: SwiftUI.Shape {
        return ModifiedGraphContent(self, GraphContentEffect.Symbol(shape))
    }

    #if canImport(Charts)
        @inlinable
        public func symbol(_ shape: BasicChartSymbolShape) -> some GraphContent<NodeID> {
            return ModifiedGraphContent(self, GraphContentEffect.Symbol(shape))
        }
    #endif

    @inlinable
    public func symbolSize(_ size: CGSize) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.SymbolSize(size))
    }

    @inlinable
    public func symbolSize(_ size: SIMD2<Double>) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.SymbolSize(size.cgSize))
    }

    @inlinable
    public func symbolSize(radius: CGFloat) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self,
            GraphContentEffect.SymbolSize(
                CGSize(width: radius * 2, height: radius * 2)
            ))
    }

    @inlinable
    public func annotation(
        _ text: Text?, alignment: Alignment = .bottom, offset: CGVector = .zero
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.TextAnnotation(text, alignment: alignment, offset: offset))
    }

    @inlinable
    public func annotation(
        _ text: Text?, alignment: Alignment = .bottom, offset: SIMD2<Double> = .zero
    ) -> some GraphContent<NodeID> {
        return annotation(text, alignment: alignment, offset: offset.cgVector)
    }

    @inlinable
    public func annotation(
        _ string: String?, alignment: Alignment = .bottom, offset: CGVector = .zero
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.TextAnnotation(nil, alignment: alignment, offset: offset))
    }

    @inlinable
    public func annotation(
        alignment: Alignment = .bottom, 
        offset: CGVector = .zero,
        @ViewBuilder _ content: () -> Text?
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.TextAnnotation(content(), alignment: alignment, offset: offset))
    }


    @inlinable
    @_disfavoredOverload
    public func annotation(
        _ tag: String,
        alignment: Alignment = .bottom,
        offset: CGVector = .zero,
        @ViewBuilder _ content: () -> some View
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.ViewAnnotation(tag, content(), alignment: alignment, offset: offset)
        )
    }

    /// SMTM fork: a **single-tint glyph** annotation (e.g. an SF Symbol). Pass the glyph's tint
    /// `Color`; the renderer draws the annotation as an alpha mask filled with that colour, so it can
    /// smoothly lerp old→new during a `contentColorTransition` (instead of snapping like a baked
    /// bitmap). Use only for annotations whose colour is a single flat tint.
    @inlinable
    @_disfavoredOverload
    public func annotation(
        _ tag: String,
        alignment: Alignment = .bottom,
        offset: CGVector = .zero,
        tint: Color,
        @ViewBuilder _ content: () -> some View
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self,
            GraphContentEffect.ViewAnnotation(tag, content(), alignment: alignment, offset: offset, tint: tint)
        )
    }


    /// Sets the stroke style for this graph content.
    ///
    /// - When a `.clip` color is applied to node marks, the stroke color of the symbol
    ///   will be **the same as the background (cliped to transparent).**
    /// - When a `.clip` color is applied to link marks, the stroke will not be drawn.
    /// - When a `nil` stroke style is applied to node marks, the stroke style will be the same as the default stroke style.
    @inlinable
    @_disfavoredOverload
    public func stroke(
        _ color: StrokeColor = .clip,
        _ strokeStyle: StrokeStyle? = nil
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.Stroke(color, strokeStyle))
    }

    @inlinable
    public func stroke(
        _ color: Color,
        _ strokeStyle: StrokeStyle? = nil
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.Stroke(.color(color), strokeStyle))
    }

    @inlinable
    public func linkShape(
        _ shape: some LinkShape
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect._LinkShape(shape))
    }
    
}
