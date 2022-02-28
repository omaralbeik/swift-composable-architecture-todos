import ComposableArchitecture
import SwiftUI

@main
struct TodosApp: App {

  let todosStore = Store(
    cache: DocumentsCache(key: "todos"),
    ignoreCachingDuplicates: { $0.todos == $1.todos },
    initialState: TodosState(),
    reducer: todosReducer,
    environment: TodosEnvironment(
      scheduler: .main,
      uuid: UUID.init
    )
  )

  let onboardingStore = Store(
    cache: DocumentsCache(key: "onboarding"),
    ignoreCachingDuplicates: { $0.step == $1.step },
    initialState: OnboardingState(),
    reducer: onboardingReducer,
    environment: OnboardingEnvironment(
      scheduler: .main,
      uuid: UUID.init
    )
  )

  var body: some Scene {
    WindowGroup {
      OnboardingView(store: onboardingStore, todosStore: todosStore)
    }
  }
}
