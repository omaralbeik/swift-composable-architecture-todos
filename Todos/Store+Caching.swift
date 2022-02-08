import ComposableArchitecture

protocol Caching {
  var key: String { get }
  func save<Value: Encodable>(_ value: Value)
  func load<Value: Decodable>() -> Value?
}

final class UserDefaultsCache: Caching {
  init(
    key: String,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    guard let userDefaults = UserDefaults(suiteName: key) else {
      fatalError("Unable to create store with key: \(key)")
    }
    self.key = key
    self.userDefaults = userDefaults
    self.decoder = decoder
    self.encoder = encoder
  }

  let key: String
  let decoder: JSONDecoder
  let encoder: JSONEncoder
  let userDefaults: UserDefaults

  func save<Value: Encodable>(_ value: Value) {
    guard let data = try? encoder.encode(value) else { return }
    userDefaults.set(data, forKey: key)
  }

  func load<Value: Decodable>() -> Value? {
    guard let data = userDefaults.data(forKey: key) else { return nil }
    return try? decoder.decode(Value.self, from: data)
  }
}

final class DocumentsCache: Caching {
  init(
    key: String,
    fileManager: FileManager = .default,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.key = key
    self.decoder = decoder
    self.encoder = encoder

    self.fileUrl = fileManager
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("\(key).json")
  }

  let key: String
  let decoder: JSONDecoder
  let encoder: JSONEncoder
  let fileUrl: URL

  func save<Value: Encodable>(_ value: Value) {
    let data = try? encoder.encode(value)
    try? data?.write(to: fileUrl)
  }

  func load<Value: Decodable>() -> Value? {
    guard let data = try? Data(contentsOf: fileUrl) else { return nil }
    return try? decoder.decode(Value.self, from: data)
  }
}

extension Reducer where State: Codable {
  func caching(
    cache: Caching,
    ignoreCachingDuplicates isDuplicate: ((State, State) -> Bool)? = nil
  ) -> Reducer {
    return .init { state, action, environment in
      let previousState = state
      let effects = self.run(&state, action, environment)
      let nextState = state

      if isDuplicate?(previousState, nextState) == true {
        return effects
      }

      return .merge(
        .fireAndForget {
          cache.save(nextState)
        },
        effects
      )
    }
  }
}

extension Store where State: Codable {
  convenience init<Environment>(
    cache: Caching,
    ignoreCachingDuplicates isDuplicate: ((State, State) -> Bool)? = nil,
    initialState: State,
    reducer: Reducer<State, Action, Environment>,
    environment: Environment
  ) {
    let state = cache.load() ?? initialState
    self.init(
      initialState: state,
      reducer: reducer.caching(cache: cache, ignoreCachingDuplicates: isDuplicate),
      environment: environment
    )
  }
}
