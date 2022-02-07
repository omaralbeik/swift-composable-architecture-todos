import ComposableArchitecture
import SwiftUI

struct TodoView: View {
  let store: Store<Todo, TodoAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Button(action: { viewStore.send(.checkBoxToggled) }) {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(.plain)

        if viewStore.isComplete {
          Text(viewStore.description.isEmpty ? "Untitled Todo" : viewStore.description)
            .strikethrough()
        } else {
          TextField(
            "Untitled Todo",
            text: viewStore.binding(get: \.description, send: TodoAction.textFieldChanged)
          )
        }
      }
      .foregroundColor(viewStore.isComplete ? .gray : nil)
    }
  }
}
