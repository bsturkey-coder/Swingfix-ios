import AVKit
import SwiftUI

struct VideoReviewView: View {
    let video: ImportedVideo
    @State private var player: AVPlayer

    init(video: ImportedVideo) {
        self.video = video
        _player = State(initialValue: AVPlayer(url: video.url))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VideoPlayer(player: player)
                    .aspectRatio(9 / 16, contentMode: .fit)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Label("Video imported", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(AppColors.accent)

                Text(video.url.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text("Next, we’ll add trimming, frame-by-frame controls, and swing-position analysis.")
                    .foregroundStyle(.secondary)

                Button {
                    player.seek(to: .zero)
                    player.play()
                } label: {
                    Label("Replay Swing", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
            }
            .padding()
        }
        .background(AppColors.pageBackground)
        .navigationTitle("Review Swing")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { player.pause() }
    }
}
