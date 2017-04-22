//
//  ApiEndpoints.swift
//  Squad
//
//  Created by Erwin GO on 2/23/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Alamofire
import PromiseKit

class ApiEndpoints {
    // MARK: - Typealiases
    
    typealias ResponseJson = (DataResponse<Any>) -> ()
    typealias PromiseEl = (promise: Promise<Any>, canceler: () -> Void)
    
    // MARK: - Properties
    
    private static let apiUrl = "http://localhost:3000"
    
    // MARK: - Private Methods
    
    private static func getPostJson(httpMethod: HTTPMethod, url: String? = nil, qs: [String: String] = [:], options: [String: Bool] = [:], forcedDelay: Double = 0) -> PromiseEl {
        let url = apiUrl
        
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
    
    // MARK: - API Methods
    
    public static func getSongs() -> (promise: Promise<[SongModel]>, canceler: () -> Void) {
        let promiseEl = getJson(url: "/")
        
        let promise = promiseEl.promise.then { response -> [SongModel] in
            guard let songs = response as? [Any] else { return [] }
            return songs.map({ song -> SongModel in
                let name = GeneralHelpers.getJsonValueWithDotNotation(json: song, dotNotation: "name") as! String
                let id = GeneralHelpers.getStringFromJsonDotNotation(json: song, dotNotation: "id")
                return SongModel(id: id, name: name, authors: nil, album: nil)
            })
        }
        
        return (promise, promiseEl.canceler)
    }
}
