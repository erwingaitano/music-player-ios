//
//  SongsSingleton.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/22/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class SongsSingleton {
    // MARK: - Properties

    public static let songs = SongsSingleton()
    public private(set) var items: [SongModel] = []
    public private(set) var playlists: [PlaylistModel] = []
    
    // MARK: - API Methods

    public func update() {
        _ = ApiEndpoints.getSongs().promise.then(execute: { songs -> Void in
            self.items = songs
            NotificationCenter.default.post(name: .CustomSongsUpdated, object: nil)
        })
    }
    
    public func updatePlaylists() {
        _ = ApiEndpoints.getPlaylists().promise.then(execute: { playlists -> Void in
            self.playlists = playlists
            NotificationCenter.default.post(name: .CustomPlaylistsUpdated, object: nil)
        })
    }
}
