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
            VideoQualityCheckView(video: video)
        }
        .overlay {
            if viewModel.isImporting {
                importingOverlay
            }
        }
        .alert(
            "Video Import Failed",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unexpected error occurred.")
        }
        .onChange(of: viewModel.selectedPickerItem) {
            Task {
                await viewModel.importSelectedVideo()
            }
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

            PhotosPicker(
                selection: $viewModel.selectedPickerItem,
                matching: .videos
            ) {
                HStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(AppColors.accent)
                        .background(AppColors.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Import Video")
                            .font(.headline)

                        Text("Choose an existing swing from Photos")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, minHeight: 92)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
        }
    }

    private var recentSwings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Swings")
                .font(.title3.bold())

            ContentUnavailableView(
                "No Swings Yet",
                systemImage: "clock.arrow.circlepath",
                description: Text(
                    "Imported and recorded swings will appear here."
                )
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var importingOverlay: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)

                Text("Importing swing…")
                    .font(.headline)
            }
            .padding(28)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
