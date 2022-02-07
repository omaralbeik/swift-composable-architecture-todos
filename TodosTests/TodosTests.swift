import ComposableArchitecture
import XCTest

@testable import Todos

final class TodosTests: XCTestCase {
  let scheduler = DispatchQueue.test

  func testAddTodo() {
    let state = TodosState(filter: .completed)
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.addTodoButtonTapped) {
      XCTAssertFalse($0.canEdit)
      $0.filter = .all
      $0.todos.insert(
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        at: 0
      )
      XCTAssert($0.canEdit)
    }
  }

  func testCanEdit() {
    let store = TestStore(
      initialState: TodosState(),
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.addTodoButtonTapped) {
      XCTAssertFalse($0.canEdit)
      $0.todos.insert(
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        at: 0
      )
      XCTAssert($0.canEdit)
    }
  }

  func testEditTodo() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        )
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(
      .todo(id: state.todos[0].id, action: .textFieldChanged("Learn Composable Architecture"))
    ) {
      $0.todos[id: state.todos[0].id]?.description = "Learn Composable Architecture"
    }
  }

  func testCompleteTodo() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: false
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
      $0.todos[id: state.todos[0].id]?.isComplete = true
    }
    scheduler.advance(by: 1)
    store.receive(.sortCompletedTodos) {
      $0.todos = [
        $0.todos[1],
        $0.todos[0],
      ]
    }
  }

  func testCompleteTodoDebounces() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: false
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
      $0.todos[id: state.todos[0].id]?.isComplete = true
    }
    scheduler.advance(by: 0.5)
    store.send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
      $0.todos[id: state.todos[0].id]?.isComplete = false
    }
    scheduler.advance(by: 1)
    store.receive(.sortCompletedTodos)
  }

  func testCanClearCompleted() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        )
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )
    store.send(
      .todo(id: state.todos[0].id, action: .checkBoxToggled)
    ) {
      XCTAssertFalse($0.canClearCompleted)
      $0.todos[id: state.todos[0].id]?.isComplete = true
      XCTAssert($0.canClearCompleted)
    }
    scheduler.advance(by: 1)
    store.receive(.sortCompletedTodos) {
      XCTAssert($0.canClearCompleted)
    }
  }

  func testClearCompleted() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: true
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.clearCompletedButtonTapped) {
      $0.todos = [
        $0.todos[0]
      ]
    }
  }

  func testDelete() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
          description: "",
          isComplete: false
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.delete([1])) {
      $0.todos = [
        $0.todos[0],
        $0.todos[2],
      ]
    }
  }

  func testDeleteAll() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: true
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.deleteAllTapped) {
      $0.editMode = .inactive
      $0.filter = .all
      $0.todos.removeAll()
    }
  }

  func testEditModeMoving() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
          description: "",
          isComplete: false
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.editModeChanged(.active)) {
      $0.editMode = .active
    }
    store.send(.move([0], 2)) {
      $0.todos = [
        $0.todos[1],
        $0.todos[0],
        $0.todos[2],
      ]
    }
    scheduler.advance(by: .milliseconds(100))
    store.receive(.sortCompletedTodos)
  }

  func testEditModeMovingWithFilter() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: true
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
          description: "",
          isComplete: true
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: self.scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.editModeChanged(.active)) {
      $0.editMode = .active
    }
    store.send(.filterSelected(.completed)) {
      $0.filter = .completed
    }
    store.send(.move([0], 1)) {
      $0.todos = [
        $0.todos[0],
        $0.todos[2],
        $0.todos[1],
        $0.todos[3],
      ]
    }
    self.scheduler.advance(by: .milliseconds(100))
    store.receive(.sortCompletedTodos)
  }

  func testFilteredEdit() {
    let state = TodosState(
      todos: [
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          description: "",
          isComplete: false
        ),
        Todo(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          description: "",
          isComplete: true
        ),
      ]
    )
    let store = TestStore(
      initialState: state,
      reducer: todosReducer,
      environment: TodosEnvironment(
        scheduler: scheduler.eraseToAnyScheduler(),
        uuid: UUID.incrementing
      )
    )

    store.send(.filterSelected(.completed)) {
      $0.filter = .completed
    }
    store.send(.todo(id: state.todos[1].id, action: .textFieldChanged("Did this already"))) {
      $0.todos[id: state.todos[1].id]?.description = "Did this already"
    }
  }
}

extension UUID {
  // A deterministic, auto-incrementing "UUID" generator for testing.
  static var incrementing: () -> UUID {
    var uuid = 0
    return {
      defer { uuid += 1 }
      return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
    }
  }
}
