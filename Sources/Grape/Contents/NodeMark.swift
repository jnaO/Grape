import SwiftUI
import simd
import Charts

public struct NodeMark<NodeID: Hashable>: GraphContent, Identifiable, Equatable {

    public var id: NodeID

    @inlinable
    public init(
        id: NodeID
    ) {
        self.id = id
    }

    @inlinable
    public var body: _IdentifiableNever<NodeID> {
        _IdentifiableNever<_>()
    }
    
    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        context.nodeOperations.append(
            .init(
                self,
                context.states.currentShading,
                context.states.currentStroke,
                context.states.currentSymbolShapeOrSize,
                context.states.currentFillColor  // SMTM fork: raw fill Color for colour lerp
            )
        )
        context.states.currentID = .node(id)
        context.nodeHitSizeAreaLookup[id] = simd_length_squared(
            context.states.currentSymbolSizeOrDefault.simd)
    }
}

public struct AnnotationNodeMark<NodeID: Hashable>: GraphContent, Identifiable {

    public var id: NodeID

    @usableFromInline
    var radius: CGFloat

    @usableFromInline
    var annotation: AnyView

    @inlinable
    public init(id: NodeID, radius: CGFloat, @ViewBuilder annnotation: () -> some View) {
        self.id = id 
        self.radius = radius
        self.annotation = AnyView(annnotation())
    }

    @inlinable
    public var body: some GraphContent<NodeID> {
        NodeMark(id: id)
            .symbolSize(radius: radius)
            .foregroundStyle(.clear)
            .annotation("\(id)", alignment: .center, offset: .zero) {
                annotation
            }
    }

}
