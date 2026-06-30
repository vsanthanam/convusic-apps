//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct AcknowledgementsView: View {

    var body: some View {
        List {
            Section("Tools") {
                ForEach(Acknowledgement.tools) { acknowledgement in
                    AcknowledgementView(acknowledment: acknowledgement)
                }
            }
            Section("Services") {
                ForEach(Acknowledgement.services) { acknowledgement in
                    AcknowledgementView(acknowledment: acknowledgement)
                }
            }
            Section("Powered by these services") {
                Text("Apple Music")
                Text("Spotify")
                Text("Railway")
                Text("CloudFlare")
            }
            Section("Inspiration") {
                Text("Amplosion")
                Text("Mapper")
            }
        }
        .navigationTitle("Acknowledgements")
    }

}

#Preview {
    AcknowledgementsView()
}
