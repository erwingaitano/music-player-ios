//
//  ColorExtensions.swift
//  Squad
//
//  Created by Erwin GO on 4/7/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

extension UIColor {
    private static let redUIColor = UIColor.hexStringToUIColor(hex: "#D0011B")
    static let secondaryUIColor = UIColor.redUIColor
}

extension UIColor {
    public static func hexStringToUIColor (hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
