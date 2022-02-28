import Combine
import ComposableArchitecture
import SwiftUI

struct TodosView: View {
  let store: Store<TodosState, TodosAction>

  @ObservedObject
  private var viewStore: ViewStore<TodosState, TodosAction>

  @Environment(\.onboardingStep)
  private var onboardingStep

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
        .redactable()
        .unredacted(if: onboardingStep == .filters)

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
              .deleteDisabled(onboardingStep != nil)
              .moveDisabled(onboardingStep != nil)
              .redactable()
          }
          .unredacted(if: onboardingStep == .todos)
        }
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarLeading) {
          if viewStore.canEdit {
            EditButton()
              .accessibilityHint(Text("Edit todos"))
              .redactable()
          }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
          if viewStore.canDeleteAll {
            Button("Delete All") {
              viewStore.send(.deleteAllTapped, animation: .default)
            }
            .foregroundColor(.red)
            .redactable()
          }

          if viewStore.canClearCompleted {
            Button(action: { viewStore.send(.clearCompletedButtonTapped, animation: .default) }) {
              Image(systemName: "strikethrough")
            }
            .accessibility(label: Text("Clear completed"))
            .redactable()
          }

          Button(action: { viewStore.send(.addTodoButtonTapped, animation: .default) }) {
            Image(systemName: "plus")
          }
          .accessibility(label: Text("Add todo"))
          .redactable()
          .unredacted(if: onboardingStep == .actions)
        }
      }
      .environment(
        \.editMode,
         viewStore.binding(get: \.editMode, send: TodosAction.editModeChanged)
      )
      .navigationTitle("Todos")
    }
    .navigationViewStyle(.stack)
  }
}

struct TodosView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TodosView(store: .init(
        initialState: .placeholder,
          reducer: todosReducer,
          environment: .init(scheduler: .main.eraseToAnyScheduler(), uuid: UUID.init)
      ))
    }
  }
}
