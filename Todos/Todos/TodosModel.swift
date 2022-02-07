import ComposableArchitecture
import SwiftUI

struct TodosState: Equatable {
  var editMode: EditMode = .inactive
  var filter: TodosFilter = .all
  var todos: IdentifiedArrayOf<Todo> = []

  var filteredTodos: IdentifiedArrayOf<Todo> {
    switch filter {
    case .all:
      return todos
    case .active:
      return todos.filter { !$0.isComplete }
    case .completed:
      return todos.filter(\.isComplete)
    }
  }

  var canEdit: Bool {
    return !todos.isEmpty
  }

  var canClearCompleted: Bool {
    return todos.contains(where: \.isComplete)
  }

  var canDeleteAll: Bool {
    return !todos.isEmpty && editMode == .active
  }
}

enum TodosFilter: LocalizedStringKey, CaseIterable, Hashable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
}
