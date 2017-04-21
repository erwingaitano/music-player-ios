//
//  StringExtensions.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.characters.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }
}

extension Int {
    func getMinuteSecondFormattedString() -> String {
        let minutes = self / 60
        let seconds = String(self % 60).leftPadding(toLength: 2, withPad: "0")
        return "\(minutes):\(seconds)"
    }
}
