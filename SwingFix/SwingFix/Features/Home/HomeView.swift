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
