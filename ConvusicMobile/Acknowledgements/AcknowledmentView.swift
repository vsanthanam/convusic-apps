//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct AcknowledgementView: View {

    @Environment(\.openURL)
    var openURL

    let acknowledment: Acknowledgement

    var body: some View {
        Button {
            openURL(acknowledment.url)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(acknowledment.name)
                        .foregroundStyle(.primary)
                    Text(acknowledment.url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }

}
