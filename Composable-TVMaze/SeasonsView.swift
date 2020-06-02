//
//  SeasonView.swift
//  Composable-TVMaze
//
//  Created by Joshua Homann on 5/31/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI
import TVMazeProvider

struct SeasonsState: Equatable {
  var selectedShow: Show?
  var seasons: [Season]
  var selectedEpisode: Episode?
  var isSheetPresented: Bool
  var episodeState: EpisodeState {
    get { .init(selectedShow: selectedEpisode, isSheetPresented: isSheetPresented) }
    set {
      selectedEpisode = newValue.selectedShow
      isSheetPresented = newValue.isSheetPresented
    }
  }
}

enum SeasonsAction: Equatable  {
  case loadSeasons
  case update(seasons: [Season])
  case cancelLoadSeasons
  case select(episode: Episode?)
  case setSheet(isPresented: Bool)
  case episode(EpisodeAction)
}

struct SeasonsEnvironment {
  var tvMazeProvider: TVMazeProvider
  var mainQueue: AnySchedulerOf<DispatchQueue>
  init(
    tvMazeProvider: TVMazeProvider = TVMazeService(),
    mainQueue:AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
  ) {
    self.tvMazeProvider = tvMazeProvider
    self.mainQueue = mainQueue
  }
}

let seasonsReducer = Reducer<SeasonsState, SeasonsAction, SeasonsEnvironment>.combine(
  .init { state, action, environment in
    struct LoadSeasonId: Hashable {}
    switch action {
    case .loadSeasons:
      guard let showId = state.selectedShow?.id else {
        return .init(value: .update(seasons: []))
      }
      return environment
        .tvMazeProvider
        .seasons(forShowId: showId)
        .subscribe(on: environment.mainQueue)
        .map(SeasonsAction.update(seasons:))
        .replaceError(with: SeasonsAction.update(seasons:[]))
        .eraseToEffect()
        .cancellable(id: LoadSeasonId())

    case let .update(seasons):
      state.seasons = seasons
      return .none

    case .cancelLoadSeasons:
      return .cancel(id: LoadSeasonId())

    case let .select(episode):
      state.selectedEpisode = episode
      return .init(value: .setSheet(isPresented: true))

    case let .setSheet(isPresented):
      state.isSheetPresented = isPresented
      return .none
    case .episode:
      return .none
    }
  },
  episodeReducer.pullback(
    state: \.episodeState,
    action: /SeasonsAction.episode,
    environment: { _ in EpisodeEnvironment() }
  )
)


struct SeasonsView: View {
  let store: Store<SeasonsState, SeasonsAction>
  var body: some View {
    WithViewStore (self.store) { viewStore in
      List {
        ForEach(viewStore.seasons) { season in
          Section(header: Text("Season \(season.id)").font(.largeTitle)) {
            ForEach(season.episodes) { episode in
              Button(action: { viewStore.send(.select(episode: episode)) }) {
                HStack(alignment: .top, spacing: 12) {
                  NetworkImage(url: episode.image?.medium)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 128, height: 128)
                    .cornerRadius(12)
                  VStack(alignment: .leading, spacing: 4) {
                    Text(episode.name).font(.title)
                    Text("Episode \(episode.number)").font(.subheadline)
                    Text(episode.summary ?? "").font(.caption)
                  }
                }
              }
            }
          }
        }
      }
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.isSheetPresented },
          send: SeasonsAction.setSheet(isPresented:)
        )
      ) {
        EpisodeView(store: self.store.scope(
            state: { $0.episodeState },
            action: SeasonsAction.episode
          )
        )
      }
      .navigationBarTitle(viewStore.selectedShow?.name ?? "")
      .onAppear { viewStore.send(.loadSeasons) }
      .onDisappear { viewStore.send(.cancelLoadSeasons) }
    }
  }
}


