import Combine
import PhotosUI
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedPickerItem: PhotosUI.PhotosPickerItem?
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
