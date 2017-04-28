//
//  ApiEndpointsHelpers.swift
//  music-player
//
//  Created by Erwin GO on 2/23/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Alamofire
import PromiseKit

class ApiEndpointsHelpers {
    // MARK: - Typealiases
    
    typealias ResponseJson = (DataResponse<Any>) -> ()
    typealias PromiseEl = (promise: Promise<Any>, canceler: () -> Void)
    typealias SongsPromiseEl = (promise: Promise<[SongModel]>, canceler: () -> Void)
    
    // MARK: - Private Methods
    
    private static func getPostJson(httpMethod: HTTPMethod, url: String? = nil, qs: [String: String] = [:], options: [String: Bool] = [:], forcedDelay: Double = 0) -> PromiseEl {
        let url = AppSingleton.app.apiUrl + (url ?? "")
        
        // This cookie header is to avoid Alamofire from sending a cookie session id so making DJango servers to
        // require a valid csrftoken!
        let headers: [String: String] = ["Cookie": ""]
        
        let (promise, fulfill, reject) = Promise<Any>.pending()
        
        // This is just for testing purposes
        _ = PromiseKit.after(interval: forcedDelay)
            .then(execute: { _ -> Void in
                Alamofire.request(url, method: httpMethod, parameters: qs, headers: headers)
                    .validate()
                    .responseJSON()
                    .then(execute: fulfill)
                    .catch(execute: reject)
            })
        
        return (promise, { reject(NSError.cancelledError()) })
    }
    
    private static func getJson(url: String? = nil, qs: [String: String] = [:], options: [String: Bool] = [:], forcedDelay: Double = 0) -> PromiseEl {
        return getPostJson(httpMethod: .get, url: url, qs: qs, options: options, forcedDelay: forcedDelay)
    }
    
    private static func postJson(url: String? = nil, qs: [String: String] = [:], options: [String: Bool] = [:], forcedDelay: Double = 0) -> PromiseEl {
        return getPostJson(httpMethod: .post, url: url, qs: qs, options: options, forcedDelay: forcedDelay)
    }
    
    private static func getSongPromise(promiseEl: PromiseEl) -> Promise<[SongModel]> {
        return promiseEl.promise.then { response -> [SongModel] in
            guard let songs = response as? [Any] else { return [] }
            return songs.map({ song -> SongModel in
                let id = GeneralHelpers.getStringFromJsonDotNotation(json: song, dotNotation: "song_id")
                let name = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "song_name") as! String
                let album = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "album_name") as? String
                let artist = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "artist_name") as? String
                let songCovers = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "song_covers") as? [String]
                let albumCovers = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "album_covers") as? [String]
                let artistCovers = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "artist_covers") as? [String]
                return SongModel(id: id, name: name, artist: artist, album: album, songCovers: songCovers, albumCovers: albumCovers, artistCovers: artistCovers)
            })
        }
    }
    
    // MARK: - API Methods
    
    public static func getSongs() -> SongsPromiseEl {
        let promiseEl = getJson(url: "/songs", forcedDelay: 2)
        let promise = getSongPromise(promiseEl: promiseEl)
        return (promise, promiseEl.canceler)
    }
    
    public static func getPlaylistSongs(_ playlistId: String) -> SongsPromiseEl {
        let promiseEl = getJson(url: "/playlists/\(playlistId)/songs", forcedDelay: 2)
        let promise = getSongPromise(promiseEl: promiseEl)
        return (promise, promiseEl.canceler)
    }
    
    public static func getPlaylists() -> (promise: Promise<[PlaylistModel]>, canceler: () -> Void) {
        let promiseEl = getJson(url: "/playlists", forcedDelay: 2)
        
        let promise = promiseEl.promise.then { response -> [PlaylistModel] in
            guard let playlists = response as? [Any] else { return [] }
            return playlists.map({ playlist -> PlaylistModel in
                let id = GeneralHelpers.getStringFromJsonDotNotation(json: playlist, dotNotation: "id")
                let name = GeneralHelpers.getJsonValueWithDotNotation(json: playlist, dotNotation: "name") as! String
                return PlaylistModel(id: id, name: name)
            })
        }
        
        return (promise, promiseEl.canceler)
    }
}
