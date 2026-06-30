//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

/// A property wrapper for a preference that must never reach iCloud KVS. Its
/// init forces `.appLocal` scope (writes to `UserDefaults.standard` + the
/// app-group mirror only).
@MainActor
@propertyWrapper
public struct LocalPreference<Value: Storable>: DynamicProperty {

    public init(_ name: String, default value: Value) {
        self.key = PreferenceDescriptor(name, default: value, scope: .appLocal)
    }

    public var wrappedValue: Value {
        get { coordinator.value(for: key) }
        nonmutating set { coordinator.setValue(newValue, for: key) }
    }

    public var projectedValue: Binding<Value> {
        coordinator.binding(for: key)
    }

    @Environment(PreferenceCoordinator.self)
    private var coordinator

    private let key: PreferenceDescriptor<Value>

}
