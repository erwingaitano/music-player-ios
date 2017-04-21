//
//  GeneralHelpers.swift
//  Squad
//
//  Created by Erwin GO on 2/24/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

class GeneralHelpers {
    public static func getJsonValueWithDotNotation(json: Any?, dotNotation: String) -> Any? {
        guard let json = json as? [String: Any] else { return nil }
        var lastDic: [String: Any]? = json
        var keys = dotNotation.components(separatedBy: ".")
        let lastKey = keys.popLast()
        for key in keys {
            if let newDic = json[key] as? [String: Any] { lastDic = newDic }
            else {
                lastDic = nil
                break
            }
        }
        
        guard let lastKeyUnwrapped = lastKey else { return nil }
        guard let value = lastDic?[lastKeyUnwrapped] else { return nil }
        return value
    }
    
    public static func getStringFromJsonDotNotation(json: Any?, dotNotation: String) -> String {
        let newInt = getJsonValueWithDotNotation(json: json, dotNotation: dotNotation) as! Int
        return String(newInt)
    }
}
