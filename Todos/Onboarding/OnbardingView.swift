import ComposableArchitecture
import SwiftUI

struct OnboardingStepEnvironmentKey: EnvironmentKey {
  static var defaultValue: OnboardingStep?
}

extension EnvironmentValues {
  var onboardingStep: OnboardingStep? {
    get {
      return self[OnboardingStepEnvironmentKey.self]
    }
    set {
      self[OnboardingStepEnvironmentKey.self] = newValue
    }
  }
}

struct OnboardingView: View {
  let store: Store<OnboardingState, OnboardingAction>
  let todosStore: Store<TodosState, TodosAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      if let step = viewStore.step {
        ZStack {
          TodosView(
            store: store.scope(
              state: \.todosState,
              action: OnboardingAction.todosAction
            )
          )
          .redacted()
          .environment(\.onboardingStep, viewStore.step)

          VStack {
            Spacer()

            switch step {
            case .actions:
              Text("Use the navbar actions to mass delete todos, clear all your completed todos, or add a new one.")
            case .filters:
              Text("Use the filters bar to change what todos are currently displayed to you. Try changing a filter")
            case .todos:
              Text("Here's your list of todos. You can check one off to complete it, or edit its title by tapping on the current title.")
            }

            HStack {
              Button(action: { viewStore.send(.previousButtonTapped) }) {
                Image(systemName: "chevron.left")
              }
              .frame(width: 44, height: 44)
              .foregroundColor(.white)
              .background(Color.gray)
              .clipShape(Circle())

              Spacer()

              Button(viewStore.step == .todos ? "Let's get Started!" : "Skip") {
                viewStore.send(.skipButtonTapped)
              }
              .padding()

              Spacer()

              Button(action: { viewStore.send(.nextButtonTapped) }) {
                Image(systemName: "chevron.right")
              }
              .frame(width: 44, height: 44)
              .foregroundColor(.white)
              .background(Color.gray)
              .clipShape(Circle())
            }
          }
          .padding([.leading, .trailing], 40)
          .padding(.top, 400)
          .padding(.bottom, 50)
          .ignoresSafeArea()
        }
      } else {
        TodosView(store: todosStore)
      }
    }
  }
}

extension RedactionReasons {
  static let onboarding = RedactionReasons(rawValue: 1 << 10)
}

struct Redactable: ViewModifier {
  @Environment(\.redactionReasons)
  private var reasons

  @ViewBuilder
  func body(content: Content) -> some View {
    if reasons.contains(.onboarding) {
      content
        .blur(radius: 3)
        .opacity(0.25)
    } else {
      content
    }
  }
}

extension View {
  func redactable() -> some View {
    modifier(Redactable())
  }

  @ViewBuilder
  func redacted() -> some View {
    self.redacted(reason: .onboarding)
  }

  @ViewBuilder
  func unredacted(if condition: Bool) -> some View {
    if condition {
      self.unredacted()
    } else {
      self
    }
  }
}
