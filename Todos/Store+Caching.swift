import ComposableArchitecture

extension Reducer where State: Codable {
  func caching(
    key: String
  ) -> Reducer {
    return .init { state, action, environment in
      let effects = self.run(&state, action, environment)
      let state = state
      return .merge(
        .fireAndForget {
          state.save(key: key)
        },
        effects
      )
    }
  }
}

extension Store where State: Codable {
  convenience init<Environment>(
    storeKey: String,
    initialState: State,
    reducer: Reducer<State, Action, Environment>,
    environment: Environment
  ) {
    let state = State.load(key: storeKey) ?? initialState
    self.init(
      initialState: state,
      reducer: reducer.caching(key: storeKey),
      environment: environment
    )
  }
}

private extension Encodable {
  func save(key: String) {
    guard
      let userDefaults = UserDefaults(suiteName: key),
      let data = try? JSONEncoder().encode(self)
    else { return }
    userDefaults.removeObject(forKey: key)
    userDefaults.set(data, forKey: key)
  }
}

private extension Decodable {
  static func load(key: String) -> Self? {
    guard
      let userDefaults = UserDefaults(suiteName: key),
      let data = userDefaults.data(forKey: key)
    else { return nil }
    return try? JSONDecoder().decode(Self.self, from: data)
  }
}
