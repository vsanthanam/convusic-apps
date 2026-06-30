//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

/// An `@AppStorage`-like property wrapper for a (typically synced) preference.
///
/// It is a stateless adapter: it reads the shared `PreferenceCoordinator` from
/// the environment and delegates all reads/writes to it. Whether a key actually
/// reaches iCloud is governed by the key's `scope` and the `useiCloud` flag.
@MainActor
@propertyWrapper
public struct CloudPreference<Value: Storable>: DynamicProperty {

    public init(_ key: PreferenceDescriptor<Value>) {
        self.key = key
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
