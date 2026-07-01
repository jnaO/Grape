import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct ForegroundStyle<S> where S: ShapeStyle {
        @usableFromInline
        let style: S

        @inlinable
        public init(_ style: S) {
            self.style = style
        }
    }

    @usableFromInline
    internal struct Shading {
        @usableFromInline
        let shading: GraphicsContext.Shading
        /// SMTM fork: the raw `Color` when this shading came from `.foregroundStyle(Color)` (else
        /// `nil`), so the renderer can lerp it colour→colour. The `.foregroundStyle` modifiers are
        /// the app's actual fill path (NOT `ForegroundStyle`), so the capture must live here.
        @usableFromInline
        let fillColor: Color?

        @inlinable
        public init(_ shading: GraphicsContext.Shading, fillColor: Color? = nil) {
            self.shading = shading
            self.fillColor = fillColor
        }
    }

    @usableFromInline
    internal struct ShadingBy {
        @usableFromInline
        let value: AnyHashable
        @inlinable
        public init<T: Hashable>(by value: T) {
            self.value = value
        }
    }
}

extension GraphContentEffect.ForegroundStyle: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        let shading: GraphicsContext.Shading = .style(style)
        context.states.shading.append(shading)
        // SMTM fork: capture the raw Color for true colour lerp (nil for gradients/materials).
        context.states.fillColor.append(style as? Color)
        // context.operations.append(.updateShading(shading))
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.shading.removeLast()
        context.states.fillColor.removeLast()  // SMTM fork: keep in lockstep with `shading`
        // context.operations.append(
        //     .updateShading(context.states.currentShading)
        // )
    }
}

extension GraphContentEffect.Shading: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.shading.append(shading)
        context.states.fillColor.append(fillColor)  // SMTM fork: raw Color for colour lerp (nil for gradients/materials)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.shading.removeLast()
        context.states.fillColor.removeLast()  // SMTM fork: keep in lockstep with `shading`
    }
}
