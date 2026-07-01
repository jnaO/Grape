import ForceSimulation
import SwiftUI


public struct ForceDirectedGraph<NodeID: Hashable, Content: GraphContent>
where NodeID == Content.NodeID {

    // public typealias NodeID = Content.NodeID

    @inlinable
    @Environment(\.self)
    internal var environment: EnvironmentValues

    @inlinable
    @Environment(\.graphForegroundScaleEnvironment)
    internal var graphForegroundScale

    @inlinable
    @Environment(\.colorScheme)
    internal var colorScheme

    @inlinable
    @Environment(\.colorSchemeContrast)
    internal var colorSchemeContrast

    // the copy of the graph context to be used for comparison in `onChange`
    // should be not used for rendering
    @usableFromInline
    internal let _graphRenderingContextShadow: _GraphRenderingContext<NodeID>

    @usableFromInline
    internal let _forceDescriptors: SealedForceDescriptor<NodeID>

    // // TBD: Some state to be retained when the graph is updated
    // @State
    // @inlinable
    // internal var clickCount = 0

    // @State
    @inlinable
    internal var model: ForceDirectedGraphModel<Content.NodeID>
    {
        @storageRestrictions(initializes: _model)
        init(initialValue) {
            _model = .init(initialValue: initialValue)
        }
        get { _model.wrappedValue }
        set { _model.wrappedValue = newValue }
    }

    @usableFromInline
    internal var _model: State<ForceDirectedGraphModel<Content.NodeID>>

    /// The default force to be applied to the graph
    ///
    /// - Returns: The default forces
    @inlinable
    static public func defaultForce() -> SealedForceDescriptor<NodeID> {
        .link().center()
    }

    /// Creates a force-directed graph view.
    ///
    /// This function creates a force-directed graph view with the given parameters.
    ///
    /// - Parameters:
    ///   - states: The initial state of the force-directed graph.
    ///   - ticksPerSecond: The number of ticks per second. Notice that this only determines the frequency of
    ///     the simulation updates, and the actual frame rate may be different.
    ///   - graph: The graph content. The `ForceDirectedGraph` will observe the changes of the graph content
    ///     and try to update the elements with minimal changes across the parameter updates.
    ///   - buildForce: The forces to be applied to the graph.
    ///   - emittingNewNodesWithStates: Tells the simulation where to place the new nodes and provide their
    ///     initial kinetic states. This is only applied on the new nodes that is not seen before when the
    ///     graph is created (or updated).
    @inlinable
    @MainActor
    public init(
        states: ForceDirectedGraphState = ForceDirectedGraphState(),
        ticksPerSecond: Double = 60.0,
        @GraphContentBuilder<NodeID> graph: () -> Content,
        force buildForce: () -> SealedForceDescriptor<NodeID> = defaultForce,
        emittingNewNodesWithStates: @escaping (NodeID) -> KineticState = defaultKineticStateProvider
    ) {

        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)

        self._graphRenderingContextShadow = gctx

        self._forceDescriptors = buildForce()

        self.model = .init(
            gctx,
            forceDescriptor: self._forceDescriptors,
            stateMixin: states,
            emittingNewNodesWith: emittingNewNodesWithStates,
            ticksPerSecond: ticksPerSecond
        )

    }

    @inlinable
    public static func defaultKineticStateProvider(nodeID: NodeID) -> KineticState {
        .init(position: .zero)
    }

}

extension ForceDirectedGraph {
    /// SMTM fork: enable a **true per-node colour cross-fade** when the graph content recolours
    /// (Grape draws to a `Canvas`, which doesn't receive SwiftUI's implicit colour animation, so it
    /// would otherwise snap). `duration: 0` disables the transition (snap). The model already
    /// defaults to `0.8` / `.easeInOut` (the app's doughnut morph); this modifier overrides it.
    @inlinable
    @MainActor
    public func contentColorTransition(
        duration: Double,
        curve: GraphColorTransitionCurve = .easeInOut
    ) -> Self {
        self.model.colorTransitionDuration = duration
        self.model.colorTransitionCurve = curve
        return self
    }

    /// SMTM fork: enable a **staggered per-node fade-in entrance**. Each node fades its opacity 0→1
    /// over `duration` from the moment it first appears in the graph; because node tiers are added to
    /// the content over time (app-side), this yields a cascaded reveal. `duration: 0` disables it
    /// (nodes draw at full alpha immediately — the default, so the fork is unchanged unless opted in).
    /// Motion-agnostic: a consumer turns the cascade off under Reduce Motion simply by passing
    /// `duration: 0`; the fork bakes in no motion variant.
    @inlinable
    @MainActor
    public func nodeFadeIn(
        duration: Double,
        curve: GraphColorTransitionCurve = .easeInOut
    ) -> Self {
        self.model.nodeFadeInDuration = duration
        self.model.nodeFadeInCurve = curve
        return self
    }
}
