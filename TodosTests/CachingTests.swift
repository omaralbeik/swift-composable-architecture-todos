import ComposableArchitecture
import XCTest

@testable import Todos

final class CachingTests: XCTestCase {
  final class FakeCache: Caching {
    let key = ""
    var value: Any?
    var saveCallCounter = 0
    var loadCallCounter = 0

    func save<Value: Encodable>(_ value: Value) {
      self.value = value
      saveCallCounter += 1
    }

    func load<Value: Decodable>() -> Value? {
      loadCallCounter += 1
      return value as? Value
    }
  }

  enum Action: Equatable {
    case updateState(String)
  }

  struct Environment {}

  let stringReducer = Reducer<String, Action, Environment> { state, action, env in
    switch action {
    case .updateState(let newState):
      state = newState
      return .none
    }
  }

  func testCachingReducer() {
    let cache = FakeCache()
    let store = TestStore(
      initialState: "",
      reducer: stringReducer.caching(cache: cache, ignoreCachingDuplicates: { $0 == $1 }),
      environment: Environment()
    )
    XCTAssertNil(cache.value)
    store.send(.updateState("hello world!")) {
      $0 = "hello world!"
      XCTAssertEqual($0, cache.value as? String)
      XCTAssertEqual(cache.saveCallCounter, 1)
    }

    for _ in 0...10 {
      store.send(.updateState("hello world!"))
    }
    XCTAssertEqual(cache.saveCallCounter, 1)
  }
}
