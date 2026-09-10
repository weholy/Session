import Foundation
import SwiftData

@Model
final class CoachMessage {
    var createdAt: Date
    var role: CoachRole
    var text: String
    var thread: CoachThread
    var contextKey: String?

    init(role: CoachRole, text: String, thread: CoachThread, contextKey: String? = nil) {
        self.createdAt = .now
        self.role = role
        self.text = text
        self.thread = thread
        self.contextKey = contextKey
    }
}
