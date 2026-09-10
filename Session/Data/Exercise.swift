import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let equipment: [Equipment]
    let unit: LoadUnit
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let steps: [String]
    let mistakes: [String]
    let breathing: String
    let tempo: String
    let media: String?
    let easier: [String]
    let harder: [String]
}

extension Exercise {
    var categoryTitle: String {
        switch category {
        case .pull: "Тяга"
        case .push: "Жим"
        case .legs: "Ноги"
        case .core: "Кор"
        case .conditioning: "Кардио"
        case .mobility: "Мобилити"
        }
    }
}
