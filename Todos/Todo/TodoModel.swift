import Foundation

struct Todo: Equatable, Identifiable, Comparable, Codable {
  var id: UUID
  var description = ""
  var isComplete = false

  static func < (lhs: Todo, rhs: Todo) -> Bool {
    return !lhs.isComplete && rhs.isComplete
  }
}

extension Todo {
  static let placeholders: [Self] = [
    .init(id: .init()),
    .init(id: .init(), description: "Buy milk", isComplete: false),
    .init(id: .init(), description: "Call Mom", isComplete: true),
  ]
}
