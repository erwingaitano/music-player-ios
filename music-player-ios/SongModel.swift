//
//  SongModel.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

struct SongModel {
    var id: String
    var name: String
    var artist: String?
    var album: String?
    var songCovers: [String]?
    var albumCovers: [String]?
    var artistCovers: [String]?
    var allCovers: [String]
    
    init(id: String, name: String, artist: String?, album: String?, songCovers: [String]?, albumCovers: [String]?, artistCovers: [String]?) {
        self.id = id
        self.name = name
        self.artist = artist
        self.album = album
        self.songCovers = songCovers
        self.albumCovers = albumCovers
        self.artistCovers = artistCovers
        self.allCovers = GeneralHelpers.mergeArrays(songCovers, albumCovers, artistCovers) as! [String]
    }
}
