//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import Observation

/// A per-key observable box. Only `current` is observed, so a change to one
/// key re-renders exactly the views that read that key.
@MainActor
@Observable
public final class PreferenceCell {

    public var current: PreferencePrimitive?

    public init(_ initial: PreferencePrimitive?) {
        self.current = initial
    }

}
