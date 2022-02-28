import ComposableArchitecture
import XCTest

@testable import Todos

final class OnboardingTests: XCTestCase {
  let scheduler = DispatchQueue.test

  func testNext() {
    XCTAssertEqual(OnboardingStep.actions.next, .filters)
    XCTAssertEqual(OnboardingStep.filters.next, .todos)
    XCTAssertNil(OnboardingStep.todos.next)
  }

  func testPrevious() {
    XCTAssertEqual(OnboardingStep.actions.previous, .actions)
    XCTAssertEqual(OnboardingStep.filters.previous, .actions)
    XCTAssertEqual(OnboardingStep.todos.previous, .filters)
  }

  func createStore(
    state: OnboardingState
  ) -> TestStore<OnboardingState, OnboardingState, OnboardingAction, OnboardingAction, OnboardingEnvironment> {
    return TestStore(
      initialState: state,
      reducer: onboardingReducer,
      environment: OnboardingEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )
  }

  func testTappingAddActionAndTappingNext() {
    let state = OnboardingState(todosState: .init(), step: .actions)
    let store = createStore(state: state)

    store.send(.todosAction(.addTodoButtonTapped)) {
      $0.todosState.todos.insert(
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        at: 0
      )
    }

    store.send(.nextButtonTapped) {
      $0.todosState.todos.remove(at: 0)
      $0.step = .filters
    }
  }

  func testSelectingFilterAndTappingPrevious() {
    let state = OnboardingState(todosState: .init(), step: .filters)
    let store = createStore(state: state)

    store.send(.todosAction(.filterSelected(.completed))) {
      $0.todosState.filter = .completed
    }

    store.send(.previousButtonTapped) {
      $0.todosState.filter = .all
      $0.step = .actions
    }
  }

  func testTappingSkip() {
    let state = OnboardingState(todosState: .init(filter: .active), step: .actions)
    let store = createStore(state: state)

    store.send(.skipButtonTapped) {
      $0.todosState.filter = .all
      $0.step = nil
    }
  }

  func testUpdatingTodo() {
    let todo = Todo(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
      description: "",
      isComplete: false
    )
    let state = OnboardingState(todosState: .init(todos: [todo]), step: .filters)
    let store = createStore(state: state)

    store.send(.todosAction(.todo(id: todo.id, action: .checkBoxToggled))) {
      XCTAssertFalse($0.todosState.todos[0].isComplete)
    }

    store.send(.nextButtonTapped) {
      $0.step = .todos
    }

    store.send(.todosAction(.todo(id: todo.id, action: .checkBoxToggled))) {
      $0.todosState.todos = [.init(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        description: "",
        isComplete: true
      )]
    }
    scheduler.advance(by: 1)
    store.receive(.todosAction(.sortCompletedTodos))

    store.send(.todosAction(.todo(id: todo.id, action: .textFieldChanged("Buy milk")))) {
      $0.todosState.todos = [.init(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        description: "Buy milk",
        isComplete: true
      )]
    }

    store.send(.todosAction(.deleteAllTapped)) {
      XCTAssertFalse($0.todosState.todos.isEmpty)
    }
  }
}
