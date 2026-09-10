import SwiftUI
import SwiftData

@main
struct SessionApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: AthleteProfile.self,
                Semester.self,
                TrainingPlan.self,
                PlannedDay.self,
                PlannedExercise.self,
                SetLog.self,
                Debt.self,
                WeeklyReview.self,
                TestResult.self,
                PersonalRecord.self,
                CoachMessage.self,
                AppState.self
            )
        } catch {
            fatalError("Не удалось создать хранилище: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
