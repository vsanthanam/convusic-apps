//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

/// A property wrapper for the local-only `useiCloud` master toggle. Its setter
/// triggers the coordinator's enable/disable reconciliation.
@MainActor
@propertyWrapper
public struct CloudEnabled: DynamicProperty {

    public init() {}

    public var wrappedValue: Bool {
        get {
            coordinator.isCloudEnabled }
        nonmutating set {
            coordinator.setCloudEnabled(newValue)
        }
    }

    public var projectedValue: Binding<Bool> {
        Binding {
            coordinator.isCloudEnabled
        } set: { newValue in
            coordinator.setCloudEnabled(newValue)
        }
    }

    @Environment(PreferenceCoordinator.self)
    private var coordinator

}
