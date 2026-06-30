import ForceSimulation
import SwiftUI

// MARK: - Show Me The Money fork additions
//
// Live node-position read on the existing `GraphProxy` seam (mirrors `setNodeFixation`):
// read a node's simulation-space position / kinetic state from the running (or paused)
// simulation. Enables seeding new nodes from neighbours' live positions and seekable
// layout state (roadmap Items 3–4).
//
// The live-recolour fix is NOT here: it is the one-line `resolvedViews` merge change in
// `ForceDirectedGraphModel.revive` (prefer the freshly-built view, like `resolvedTexts`).
//
// Kept in a single file (plus the protocol requirements added to `_AnyGraphProxyProtocol`)
// so the fork patch stays cohesive and easy to rebase onto upstream.

extension ForceDirectedGraphModel {

    /// Live position of `nodeID` in **simulation** coordinates.
    @inlinable
    public func position<ID>(of nodeID: ID) -> SIMD2<Double>? where ID: Hashable {
        guard let nodeID = nodeID as? NodeID else { return nil }
        return simulationContext.getKineticState(nodeID: nodeID)?.position
    }

    /// Live kinetic state of `nodeID` in **simulation** coordinates.
    @inlinable
    public func kineticState<ID>(of nodeID: ID) -> KineticState? where ID: Hashable {
        guard let nodeID = nodeID as? NodeID else { return nil }
        return simulationContext.getKineticState(nodeID: nodeID)
    }
}

@MainActor
extension GraphProxy {

    /// The node's live position in **simulation** coordinates, or `nil` if the node is
    /// unknown. Map to the viewport with `finalTransform` if a screen-space value is needed.
    @inlinable
    public func position<ID: Hashable>(of nodeID: ID) -> SIMD2<Double>? {
        storage?.position(of: nodeID)
    }

    /// The node's full live kinetic state (position/velocity/fixation) in **simulation**
    /// coordinates, or `nil` if the node is unknown.
    @inlinable
    public func kineticState<ID: Hashable>(of nodeID: ID) -> KineticState? {
        storage?.kineticState(of: nodeID)
    }
}
