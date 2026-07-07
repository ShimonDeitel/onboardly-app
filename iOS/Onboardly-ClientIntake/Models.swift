import Foundation

struct ClientTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var step: String = ""
    var status: String = ""
    var notes: String = ""
    var dateAdded: Date = Date()
}
