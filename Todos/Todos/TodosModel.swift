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
    case todos
  }
}

enum TodosFilter: LocalizedStringKey, CaseIterable, Hashable, Codable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
}

extension TodosState {
  static let placeholder = Self(
    editMode: .inactive,
    filter: .all,
    todos: [
      .init(id: .init(), description: "Buy milk", isComplete: false),
      .init(id: .init(), description: "Organize desk", isComplete: false),
      .init(id: .init(), description: "Call Mom", isComplete: true),
    ]
  )
}
