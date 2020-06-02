//
//  ShowView.swift
//  Composable-TVMaze
//
//  Created by Joshua Homann on 5/31/20.
//  Copyright © 2020 com.josh. All rights reserved.
//
import Combine
import ComposableArchitecture
import SwiftUI
import TVMazeProvider

struct ShowsState: Equatable {
  var shows: [Show] = []
  var searchTerm = ""
  var selectedShow: Show?
  var seasons: [Season] = []
  var selectedEpisode: Episode?
  var isSheetPresented: Bool = false
  var seasonsState: SeasonsState {
    get { .init(selectedShow: selectedShow, seasons: seasons, selectedEpisode: selectedEpisode, isSheetPresented: isSheetPresented) }
    set {
      selectedShow = newValue.selectedShow
      seasons = newValue.seasons
      isSheetPresented = newValue.isSheetPresented
      selectedEpisode = newValue.selectedEpisode
    }
  }
}

enum ShowsAction: Equatable  {
  case seasons(SeasonsAction)
  case search(String)
  case update(shows: [Show])
  case setNavigation(selection: Show?)
}

struct ShowsEnvironment {
  var tvMazeProvider: TVMazeProvider
  var mainQueue: AnySchedulerOf<DispatchQueue>
  init(
    tvMazeProvider: TVMazeProvider = TVMazeService(),
    mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
  ) {
    self.tvMazeProvider = tvMazeProvider
    self.mainQueue = mainQueue
  }
}


let showsReducer = Reducer<ShowsState, ShowsAction, ShowsEnvironment>.combine(
  Reducer<ShowsState, ShowsAction, ShowsEnvironment>{ state, action, environment in
    switch action {
    case let .search(term):
      state.searchTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !state.searchTerm.isEmpty else {
        return .init(value: .update(shows: []))
      }
      struct SearchCompletionId: Hashable {}
      return Effect.concatenate(
        .cancel(id: SearchCompletionId()),
        environment
          .tvMazeProvider
          .search(query: state.searchTerm)
          .map(ShowsAction.update(shows:))
          .replaceError(with: ShowsAction.update(shows: []))
          .subscribe(on: environment.mainQueue)
          .eraseToEffect()
          .cancellable(id: SearchCompletionId())
          .debounce(id: SearchCompletionId(), for: 1, scheduler: environment.mainQueue)
      )

    case let .update(shows):
      state.shows = shows
      return .none

    case let .setNavigation(selection):
      state.selectedShow = selection
      return .none

    case .seasons:
      return .none
    }
  },
  seasonsReducer.pullback(
    state: \.seasonsState,
    action: /ShowsAction.seasons,
    environment: { environment in
      SeasonsEnvironment(tvMazeProvider: environment.tvMazeProvider)
    }
  )
)


struct ShowsView: View {
  let store: Store<ShowsState, ShowsAction>
  var body: some View {
    NavigationView {
      WithViewStore (self.store) { viewStore in
        VStack {
          SearchBar(viewStore.binding(
            get: { $0.searchTerm },
            send: ShowsAction.search
          ))
          List(viewStore.shows) { show in
            NavigationLink(
              destination: IfLetStore(
                self.store.scope(
                  state: { $0.seasonsState },
                  action: ShowsAction.seasons
                ),
                then: SeasonsView.init(store:),
                else: EmptyView()
              ),
              tag: show,
              selection: viewStore.binding(
                get: { $0.selectedShow },
                send: ShowsAction.setNavigation(selection:)
              )
            ) {
              Text(show.name)
            }
          }
        }
      }
      .navigationBarTitle("Show Search")
    }
  }
}

struct SearchBar : View {
  @Binding private var text: String
  init(_ text: Binding<String>) {
    _text = text
  }
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
      TextField("TV Show Search...", text: $text)
        .textFieldStyle(RoundedBorderTextFieldStyle())
      Button(action: { self.text = "" }) { Text("Clear") }
      .padding(8)
      .background(Color.accentColor)
      .foregroundColor(Color.white)
      .cornerRadius(4)
    }
    .padding()
  }
}
