import SwiftUI

struct RecordSwingPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "Camera Capture Is Next",
            systemImage: "video.badge.plus",
            description: Text("The import and review flow is ready. Camera recording is the next feature.")
        )
        .navigationTitle("Record Swing")
    }
}
