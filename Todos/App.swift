import ComposableArchitecture
import SwiftUI

@main
struct TodosApp: App {
  let store = Store(
    cache: DocumentsCache(key: "todos"),
    ignoreCachingDuplicates: { $0.todos == $1.todos },
    initialState: TodosState(),
    reducer: todosReducer.debug(),
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
