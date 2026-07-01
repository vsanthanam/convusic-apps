//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import Foundation
import Testing

struct PlatformRawValueTests {

    @Test
    func knownStringsMapToCases() {
        #expect(Platform(rawValue: "spotify") == .spotify)
        #expect(Platform(rawValue: "appleMusic") == .appleMusic)
        #expect(Platform(rawValue: "deezer") == .deezer)
        #expect(Platform(rawValue: "tidal") == .tidal)
        #expect(Platform(rawValue: "youtubeMusic") == .youtubeMusic)
        #expect(Platform(rawValue: "amazonMusic") == .amazonMusic)
    }

    @Test
    func unknownStringFallsToUnknownCase() {
        #expect(Platform(rawValue: "napster") == .unknown("napster"))
    }

    @Test
    func rawValueRoundTrips() {
        let platforms: [Platform] = [
            .spotify, .appleMusic, .deezer, .tidal, .youtubeMusic, .amazonMusic,
        ]
        for platform in platforms {
            #expect(Platform(rawValue: platform.rawValue) == platform)
        }
    }
}
