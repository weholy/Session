import Foundation

enum ExerciseCatalog {
    static let all: [Exercise] = load()

    private static let index: [String: Exercise] = Dictionary(
        all.map { ($0.id, $0) },
        uniquingKeysWith: { first, _ in first }
    )

    static subscript(id: String) -> Exercise? { index[id] }

    static func name(_ id: String) -> String { index[id]?.name ?? id }

    static func inCategory(_ category: ExerciseCategory) -> [Exercise] {
        all.filter { $0.category == category }
    }

    private static func load() -> [Exercise] {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        return (try? JSONDecoder().decode([Exercise].self, from: data)) ?? []
    }
}
