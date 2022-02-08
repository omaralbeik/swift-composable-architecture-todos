import ComposableArchitecture
import SwiftUI

struct TodosState: Equatable, Codable {
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

  enum CodingKeys: String, CodingKey {
    case filter
    case todos
  }
}

enum TodosFilter: LocalizedStringKey, CaseIterable, Hashable, Codable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
}
