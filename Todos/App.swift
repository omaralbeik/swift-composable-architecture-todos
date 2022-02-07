import ComposableArchitecture
import SwiftUI

@main
struct TodosApp: App {
  let store = Store(
    initialState: TodosState(),
    reducer: todosReducer,
    environment: TodosEnvironment(
      scheduler: .main,
      uuid: UUID.init
    )
  )
  var body: some Scene {
    WindowGroup {
      TodosView(store: store)
    }
  }
}
