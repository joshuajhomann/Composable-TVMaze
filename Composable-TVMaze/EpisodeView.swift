//
//  EpisodeView.swift
//  Composable-TVMaze
//
//  Created by Joshua Homann on 5/31/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI
import TVMazeProvider

struct EpisodeState: Equatable {
  var selectedShow: Episode?
  var isSheetPresented: Bool
}

enum EpisodeAction: Equatable  {
  case dismiss
}

struct EpisodeEnvironment { }

let episodeReducer = Reducer<EpisodeState, EpisodeAction, EpisodeEnvironment> { state, action, environment in
  switch action {
  case .dismiss:
    state.isSheetPresented = false
    return .none
  }
}

struct EpisodeView: View {
  let store: Store<EpisodeState, EpisodeAction>
  var body: some View {
    ScrollView {
      WithViewStore(self.store) { viewStore in
        VStack(alignment: .center, spacing: 4) {
          NetworkImage(url: viewStore.selectedShow?.image?.original)
          Text(viewStore.selectedShow?.name ?? "").font(.largeTitle)
          Text("Episode \(viewStore.selectedShow?.number ?? 0)").font(.title)
          Text(viewStore.selectedShow?.summary ?? "").font(.body)
          Button(action: { viewStore.send(.dismiss) }) { Text("Done") }
            .font(.headline)
            .padding(12)
            .background(Color.accentColor)
            .foregroundColor(Color.white)
            .cornerRadius(4)
        }
        .padding()
      }
    }
  }
}
