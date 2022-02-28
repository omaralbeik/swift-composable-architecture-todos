import Combine
import ComposableArchitecture
import SwiftUI

struct TodoView: View {
  let store: Store<Todo, TodoAction>

  @Environment(\.onboardingStep)
  private var onboardingStep

  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Button(action: { viewStore.send(.checkBoxToggled) }) {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(.plain)

        if viewStore.isComplete {
          HStack {
            Text(viewStore.description.isEmpty ? "Untitled Todo" : viewStore.description)
              .strikethrough()
            Spacer()
          }
        } else {
          TextField(
            "Untitled Todo",
            text: viewStore.binding(get: \.description, send: TodoAction.textFieldChanged)
          )
            .disabled([.actions, .filters].contains(onboardingStep))
        }
      }
      .foregroundColor(viewStore.isComplete ? .gray : nil)
    }
  }
}

struct TodoView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(Todo.placeholders) { todo in
      TodoView(store: .init(
        initialState: todo,
        reducer: todoReducer,
        environment: TodoEnvironment()
      ))
      .previewLayout(.fixed(width: 300, height: 50))
      .padding()
    }
  }
}
