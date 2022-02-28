enum OnboardingStep: Codable {
  case actions
  case filters
  case todos
}

extension OnboardingStep {
  var next: Self? {
    switch self {
    case .actions:
      return .filters
    case .filters:
      return .todos
    case .todos:
      return nil
    }
  }

  var previous: Self {
    switch self {
    case .actions:
      return self
    case .filters:
      return .actions
    case .todos:
      return .filters
    }
  }
}

struct OnboardingState: Equatable, Codable {
  var todosState: TodosState = .placeholder
  var step: OnboardingStep? = .actions
}
