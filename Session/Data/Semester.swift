import Foundation
import SwiftData

@Model
final class Semester {
    var index: Int
    var title: String
    var startDate: Date
    var testDate: Date

    init(index: Int, title: String, startDate: Date, testDate: Date) {
        self.index = index
        self.title = title
        self.startDate = startDate
        self.testDate = testDate
    }
}
