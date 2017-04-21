//
//  Slider.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class Slider: UISlider {
    // MARK: - Inits
    
    init() {
        super.init(frame: .zero)
        setThumbImage(#imageLiteral(resourceName: "icon - slidercircle"), for: .normal)
        minimumTrackTintColor = .secondaryUIColor
    }    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 2
        return newBounds
    }
}
