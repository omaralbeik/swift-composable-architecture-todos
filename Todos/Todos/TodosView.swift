import Combine
import ComposableArchitecture
import SwiftUI

struct TodosView: View {
  let store: Store<TodosState, TodosAction>
  @ObservedObject var viewStore: ViewStore<TodosState, TodosAction>

  init(store: Store<TodosState, TodosAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    NavigationView {
      VStack {
        Picker(
          "Filter",
          selection: viewStore.binding(
            get: \.filter,
            send: TodosAction.filterSelected
          )
        ) {
          ForEach(TodosFilter.allCases, id: \.self) { filter in
            Text(filter.rawValue).tag(filter)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)

        if viewStore.todos.isEmpty {
          VStack(spacing: 16) {
            Spacer()
            Text("No todos yet!")
              .font(.title)
            Button("Add todo") {
              viewStore.send(.addTodoButtonTapped, animation: .default)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
          }
        } else {
          List {
            ForEachStore(
              store.scope(state: \.filteredTodos, action: TodosAction.todo),
              content: TodoView.init
            )
            .onDelete { viewStore.send(.delete($0)) }
            .onMove { viewStore.send(.move($0, $1)) }
          }
          
        }
      }
      .navigationTitle("Todos")
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarLeading) {
          if viewStore.canEdit {
            EditButton()
              .accessibilityHint(Text("Edit todos"))
          }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
          if viewStore.canDeleteAll {
            Button("Delete All") {
              viewStore.send(.deleteAllTapped, animation: .default)
            }
            .foregroundColor(.red)
          }

          if viewStore.canClearCompleted {
            Button(action: { viewStore.send(.clearCompletedButtonTapped, animation: .default) }) {
              Image(systemName: "strikethrough")
            }
            .accessibility(label: Text("Clear completed"))
          }

          Button(action: { viewStore.send(.addTodoButtonTapped, animation: .default) }) {
            Image(systemName: "plus")
          }
          .accessibility(label: Text("Add todo"))
        }
      }
      .environment(
        \.editMode,
         viewStore.binding(get: \.editMode, send: TodosAction.editModeChanged)
      )
    }
    .navigationViewStyle(.stack)
  }
}
