//
//  DataModels.swift
//  TVMazeService
//
//  Created by Joshua Homann on 5/31/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Foundation

// MARK: - ShowResults
public struct ShowResults: Codable {
  public var score: Double
  public var show: Show
}

// MARK: - ShowClass
public struct Show: Codable, Hashable, Identifiable {
  public var id: Int
  public var name: String

  public enum CodingKeys: String, CodingKey {
    case id, name
  }
}

public struct Season: Hashable, Identifiable {
  public var id: Int
  public var episodes: [Episode]
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  public static func == (lhs: Season, rhs: Season) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Episode
public struct Episode: Codable, Hashable, Identifiable {
  public var id: Int
  public var url: URL
  public var name: String
  public var season, number: Int
  public var airdate: String
  public var runtime: Int
  public var image: Image?
  public var summary: String?

  public enum CodingKeys: String, CodingKey {
    case id, url, name, season, number, airdate, runtime, image, summary
  }

  public struct Image: Codable {
    public var medium, original: URL
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  public static func == (lhs: Episode, rhs: Episode) -> Bool {
    lhs.id == rhs.id
  }
}


