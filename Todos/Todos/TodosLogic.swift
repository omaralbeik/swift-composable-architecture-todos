import Combine
import ComposableArchitecture
import SwiftUI

enum TodosAction: Equatable {
  case addTodoButtonTapped
  case clearCompletedButtonTapped
  case filterSelected(TodosFilter)
  case delete(IndexSet)
  case deleteAllTapped
  case editModeChanged(EditMode)
  case move(IndexSet, Int)
  case sortCompletedTodos
  case todo(id: Todo.ID, action: TodoAction)
}

struct TodosEnvironment {
  var scheduler: AnySchedulerOf<DispatchQueue>
  var uuid: () -> UUID
}

let todosReducer = Reducer<TodosState, TodosAction, TodosEnvironment>.combine(
  todoReducer.forEach(
    state: \.todos,
    action: /TodosAction.todo,
    environment: { _ in TodoEnvironment() }
  ),
  Reducer { state, action, env in
    switch action {
    case .addTodoButtonTapped:
      state.filter = .all
      state.todos.insert(Todo(id: env.uuid()), at: 0)
      return .none

    case .clearCompletedButtonTapped:
      state.todos.removeAll(where: \.isComplete)
      return .none

    case .filterSelected(let filter):
      state.filter = filter
      return .none

    case .delete(let indexSet):
      state.todos.remove(atOffsets: indexSet)
      return .none

    case .deleteAllTapped:
      state.editMode = .inactive
      state.filter = .all
      state.todos.removeAll()
      return .none

    case .editModeChanged(let mode):
      state.editMode = mode
      return .none

    case .move(let source, let destination):
      let sourceInTodos = source
        .map { state.filteredTodos[$0] }
        .compactMap { state.todos.index(id: $0.id) }
      let destinationInTodos = state.todos.index(id: state.filteredTodos[destination].id)!
      state.todos.move(fromOffsets: IndexSet(sourceInTodos), toOffset: destinationInTodos)
      return Effect(value: .sortCompletedTodos)
        .delay(for: .milliseconds(100), scheduler: env.scheduler)
        .eraseToEffect()

    case .sortCompletedTodos:
      state.todos.sort()
      return .none

    case .todo(let id, action: .checkBoxToggled):
      struct TodoCompletionId: Hashable {}
      return Effect(value: .sortCompletedTodos)
        .debounce(id: TodoCompletionId(), for: 1, scheduler: env.scheduler)

    case .todo:
      return .none
    }
  }
)
