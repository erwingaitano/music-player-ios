//
//  SongsSingleton.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/22/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

protocol SongsSingletonDataDelegate {
    func erwin()
}

class SongsSingleton {
    // MARK: - Properties

    public static let songs = SongsSingleton()
    public private(set) var items: [SongModel] = []
    
    // MARK: - API Methods

    public func update() {
        _ = ApiEndpoints.getSongs().promise.then(execute: { songs -> Void in
            self.items = songs
            NotificationCenter.default.post(name: .CustomSongsUpdated, object: nil)
        })
    }
    
    public static func getSongUrl(id: String) -> URL? {
        return URL(string: "\(AppSingleton.app.apiUrl)/songs/\(id)/file")
    }
}
