//
//  TabbarView.swift
//  Composable-TVMaze
//
//  Created by Joshua Homann on 6/1/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI
import TVMazeProvider

struct AppState: Equatable {
  var shows: [Show] = []
  var searchTerm = ""
  var selectedShow: Show?
  var seasons: [Season] = []
  var selectedEpisode: Episode?
  var isSheetPresented: Bool = true

  var showsState: ShowsState {
    get { .init(
        shows: shows,
        searchTerm: searchTerm,
        seasons: seasons,
        selectedEpisode: selectedEpisode,
        isSheetPresented: isSheetPresented
      )
    }
    set {
      shows = newValue.shows
      searchTerm = newValue.searchTerm
    }
  }
}

enum AppAction: Equatable  {
  case showsAction(ShowsAction)
}

struct AppEnvironment {
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

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  showsReducer.pullback(
    state: \.showsState,
    action: /AppAction.showsAction,
    environment: { environment in
      ShowsEnvironment(tvMazeProvider: environment.tvMazeProvider)
    }
  )
)

struct TababarView: View {
  let store: Store<AppState, AppAction>
  var body: some View {
    TabView {
      ShowsView(store: self.store.scope(
        state: { $0.showsState },
        action: AppAction.showsAction
      ))
        .tabItem {
          Image(systemName: "tv")
          Text("Shows")
        }
      Text("TODO")
        .tabItem {
          Image(systemName: "star")
          Text("Favorites")
        }
    }
  }
}
