#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$REPO_ROOT" ]] || { echo "Run this from inside the SwingFix Git repository."; exit 1; }
cd "$REPO_ROOT"

SOURCE_ROOT="SwingFix/SwingFix"
[[ -d "$SOURCE_ROOT" ]] || { echo "Missing $SOURCE_ROOT"; exit 1; }

mkdir -p "$SOURCE_ROOT/App" "$SOURCE_ROOT/Features/Home/Components" "$SOURCE_ROOT/Features/Capture" "$SOURCE_ROOT/Features/Review" "$SOURCE_ROOT/DesignSystem/Components" "$SOURCE_ROOT/DesignSystem/Colors" "$SOURCE_ROOT/Models" "$SOURCE_ROOT/Services"

cat > "$SOURCE_ROOT/SwingFixApp.swift" <<'EOF'
import SwiftUI

@main
struct SwingFixApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
EOF

cat > "$SOURCE_ROOT/App/RootView.swift" <<'EOF'
import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    RootView()
}
EOF

cat > "$SOURCE_ROOT/Models/ImportedVideo.swift" <<'EOF'
import Foundation

struct ImportedVideo: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let importedAt: Date

    init(id: UUID = UUID(), url: URL, importedAt: Date = .now) {
        self.id = id
        self.url = url
        self.importedAt = importedAt
    }
}
EOF

cat > "$SOURCE_ROOT/Services/VideoImportService.swift" <<'EOF'
import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct SelectedVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let ext = received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)

            try FileManager.default.copyItem(at: received.file, to: destination)
            return SelectedVideo(url: destination)
        }
    }
}

actor VideoImportService {
    func importVideo(from temporaryURL: URL) throws -> ImportedVideo {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base
            .appendingPathComponent("SwingFix", isDirectory: true)
            .appendingPathComponent("ImportedVideos", isDirectory: true)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let ext = temporaryURL.pathExtension.isEmpty ? "mov" : temporaryURL.pathExtension
        let destination = directory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)

        try FileManager.default.copyItem(at: temporaryURL, to: destination)
        return ImportedVideo(url: destination)
    }
}
EOF

cat > "$SOURCE_ROOT/Features/Home/HomeViewModel.swift" <<'EOF'
import Foundation
import PhotosUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedPickerItem: PhotosPickerItem?
    @Published var importedVideo: ImportedVideo?
    @Published var isImporting = false
    @Published var errorMessage: String?

    private let importService = VideoImportService()

    func importSelectedVideo() async {
        guard let selectedPickerItem else { return }

        isImporting = true
        errorMessage = nil

        defer {
            isImporting = false
            self.selectedPickerItem = nil
        }

        do {
            guard let selectedVideo = try await selectedPickerItem.loadTransferable(type: SelectedVideo.self) else {
                errorMessage = "The selected video could not be loaded."
                return
            }

            importedVideo = try await importService.importVideo(from: selectedVideo.url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
EOF

cat > "$SOURCE_ROOT/DesignSystem/Colors/AppColors.swift" <<'EOF'
import SwiftUI

enum AppColors {
    static let accent = Color.green
    static let pageBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
}
EOF

cat > "$SOURCE_ROOT/DesignSystem/Components/ActionCard.swift" <<'EOF'
import SwiftUI

struct ActionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let isPrimary: Bool
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        isPrimary: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isPrimary = isPrimary
        self.content = content()
    }

    var body: some View {
        content
            .buttonStyle(.plain)
            .overlay {
                HStack(spacing: 16) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(isPrimary ? .white : AppColors.accent)
                        .background(isPrimary ? Color.white.opacity(0.18) : AppColors.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(isPrimary ? .white.opacity(0.82) : .secondary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(isPrimary ? .white.opacity(0.8) : .tertiary)
                }
                .foregroundStyle(isPrimary ? .white : .primary)
                .padding(18)
            }
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(isPrimary ? AppColors.accent : AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
EOF

cat > "$SOURCE_ROOT/Features/Home/Components/HomeHeroView.swift" <<'EOF'
import SwiftUI

struct HomeHeroView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "figure.golf")
                .font(.system(size: 58))
                .foregroundStyle(AppColors.accent)

            Text("Your swing. One clear fix.")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Record or import a swing and get focused feedback without the golf-jargon avalanche.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 14)
    }
}
EOF

cat > "$SOURCE_ROOT/Features/Home/HomeView.swift" <<'EOF'
import PhotosUI
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HomeHeroView()
                swingActions
                recentSwings
            }
            .padding()
        }
        .background(AppColors.pageBackground)
        .navigationTitle("SwingFix")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $viewModel.importedVideo) { video in
            VideoReviewView(video: video)
        }
        .overlay {
            if viewModel.isImporting {
                ZStack {
                    Color.black.opacity(0.22).ignoresSafeArea()
                    VStack(spacing: 14) {
                        ProgressView().controlSize(.large)
                        Text("Importing swing…").font(.headline)
                    }
                    .padding(28)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .alert(
            "Video Import Failed",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unexpected error occurred.")
        }
        .onChange(of: viewModel.selectedPickerItem) {
            Task { await viewModel.importSelectedVideo() }
        }
    }

    private var swingActions: some View {
        VStack(spacing: 14) {
            ActionCard(
                title: "Record Swing",
                subtitle: "Use the rear camera at the range",
                systemImage: "video.fill",
                isPrimary: true
            ) {
                NavigationLink {
                    RecordSwingPlaceholderView()
                } label: {
                    Color.clear
                }
            }

            ActionCard(
                title: "Import Video",
                subtitle: "Choose an existing swing from Photos",
                systemImage: "square.and.arrow.down"
            ) {
                PhotosPicker(selection: $viewModel.selectedPickerItem, matching: .videos) {
                    Color.clear
                }
            }
        }
    }

    private var recentSwings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Swings").font(.title3.bold())

            ContentUnavailableView(
                "No Swings Yet",
                systemImage: "clock.arrow.circlepath",
                description: Text("Imported and recorded swings will appear here.")
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
}
EOF

cat > "$SOURCE_ROOT/Features/Capture/RecordSwingPlaceholderView.swift" <<'EOF'
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
EOF

cat > "$SOURCE_ROOT/Features/Review/VideoReviewView.swift" <<'EOF'
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
EOF

cat > "$SOURCE_ROOT/ContentView.swift" <<'EOF'
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
}
EOF

echo "Feature installed."
echo "Open Xcode, build, and test Import Video."
echo "Then commit with:"
echo 'git add .'
echo 'git commit -m "Add home experience and video import flow"'
echo 'git push'
