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
