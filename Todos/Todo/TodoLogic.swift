import Combine
import ComposableArchitecture
import SwiftUI

enum TodoAction: Equatable {
  case checkBoxToggled
  case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, env in
  switch action {
  case .checkBoxToggled:
    state.isComplete.toggle()
    return .none
  case .textFieldChanged(let description):
    state.description = description
    return .none
  }
}
