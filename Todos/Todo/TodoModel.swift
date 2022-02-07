import Foundation

struct Todo: Equatable, Identifiable, Comparable {
  var id: UUID
  var description = ""
  var isComplete = false

  static func < (lhs: Todo, rhs: Todo) -> Bool {
    return !lhs.isComplete && rhs.isComplete
  }
}
