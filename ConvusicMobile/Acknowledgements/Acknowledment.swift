//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

struct Acknowledgement: Equatable, Hashable, Identifiable {

    let id: String
    let name: String
    let url: URL

    static let tools: [Acknowledgement] = [
        .init(id: "jbird", name: "JBird", url: URL(string: "https://www.usejbird.com")!),
        .init(id: "safariui", name: "SafariUI", url: URL(string: "https://www.safariui.com")!),
        .init(id: "viewscope", name: "ViewScope", url: URL(string: "https://www.viewsco.pe")!)
    ]

}
