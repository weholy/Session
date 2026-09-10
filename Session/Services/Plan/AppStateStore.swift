import Foundation
import SwiftData

@MainActor
enum AppStateStore {
    static func load(in context: ModelContext) -> AppState {
        if let existing = try? context.fetch(FetchDescriptor<AppState>()).first {
            return existing
        }
        let created = AppState()
        context.insert(created)
        try? context.save()
        return created
    }

    static func profile(in context: ModelContext) -> AthleteProfile? {
        try? context.fetch(FetchDescriptor<AthleteProfile>()).first
    }

    static func semesters(in context: ModelContext) -> [Semester] {
        (try? context.fetch(FetchDescriptor<Semester>(sortBy: [SortDescriptor(\.index)]))) ?? []
    }
}
