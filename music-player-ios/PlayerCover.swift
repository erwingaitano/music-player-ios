//
//  PlayerCover.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/27/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class PlayerCover: UIView {
    // MARK: - Properties

    private var coversToRotate: Int!
    private var coverUrls: [String]!
    private var coverToRotateIdx: Int!
    private let coverGradientEl = CAGradientLayer()
    private var coverRotationTimer: Timer?
    private lazy var imageViewEl: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.backgroundColor = UIColor.hexStringToUIColor(hex: "#aaaaaa")
        v.clipsToBounds = true
        
        self.coverGradientEl.colors = [UIColor.black.withAlphaComponent(0.9).cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        self.coverGradientEl.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        v.layer.addSublayer(self.coverGradientEl)
        return v
    }()
    
    // MARK: - Inits

    init() {
        super.init(frame: .zero)
        
        addSubview(imageViewEl)
        imageViewEl.allEdgeAnchorsToEqual(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeCoverRotationTimer()
    }
    
    // MARK: - Private Methods
    
    private func changeCover(shouldRemoveCover: Bool = false) {
        imageViewEl.kf.cancelDownloadTask()
        
        if shouldRemoveCover {
            self.imageViewEl.layer.addSublayer(self.coverGradientEl)
            self.imageViewEl.image = nil
            return
        }
        
        imageViewEl.kf.setImage(with: URL(string: GeneralHelpers.getCoverUrl(coverUrls[coverToRotateIdx])), placeholder: self.imageViewEl.image, completionHandler: { (image, error, _, _) in
            if image != nil && error == nil {
                self.coverGradientEl.removeFromSuperlayer()
            } else {
                self.imageViewEl.layer.addSublayer(self.coverGradientEl)
            }
        })
    }

    private func handleCoverTimer(_: Timer) {
        coverToRotateIdx = coverToRotateIdx + 1
        if coverToRotateIdx >= coversToRotate { coverToRotateIdx = 0 }
        changeCover()
    }
    
    private func removeCoverRotationTimer() {
        coverRotationTimer?.invalidate()
        coverRotationTimer = nil
    }

    // MARK: - API Methods
    
    public func setCovers(_ coverUrls: [String]) {
        self.coverUrls = coverUrls
        coversToRotate = coverUrls.count
        coverToRotateIdx = 0
        removeCoverRotationTimer()
        
        if coversToRotate == 0 {
            changeCover(shouldRemoveCover: true)
            return
        }
        
        changeCover()
        coverRotationTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: handleCoverTimer)
    }
}
