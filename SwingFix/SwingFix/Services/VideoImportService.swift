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
