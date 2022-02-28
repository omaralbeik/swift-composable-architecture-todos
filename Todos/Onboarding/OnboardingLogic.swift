import ComposableArchitecture

enum OnboardingAction: Equatable {
  case previousButtonTapped
  case nextButtonTapped
  case skipButtonTapped
  case todosAction(TodosAction)
}

typealias OnboardingEnvironment = TodosEnvironment

let onboardingReducer = Reducer<OnboardingState, OnboardingAction, OnboardingEnvironment> { state, action, env in
  switch action {
  case .previousButtonTapped:
    state.step = state.step?.previous
    state.todosState.filter = .all
    return .none

  case .nextButtonTapped where state.step == .actions:
    state.todosState.todos.removeAll(where: \.description.isEmpty)
    fallthrough

  case .nextButtonTapped:
    state.step = state.step?.next
    state.todosState.filter = .all
    return .none

  case .skipButtonTapped:
    state.todosState.filter = .all
    state.step = nil
    return .none

  case .todosAction(.addTodoButtonTapped) where state.step == .actions:
    state.todosState.todos.append(.init(id: env.uuid()))
    return .none

  case .todosAction(.filterSelected(let filter)) where state.step == .filters:
    state.todosState.filter = filter
    return .none

  case .todosAction(let todosAction) where state.step == .todos:
    switch todosAction {
    case .todo(id: _, action: _), .sortCompletedTodos:
      return todosReducer
        .run(&state.todosState, todosAction, env)
        .map(OnboardingAction.todosAction)
    default:
      return .none
    }

  case .todosAction:
    return .none
  }
}
