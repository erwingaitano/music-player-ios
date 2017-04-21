//
//  IndexController.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class IndexController: UIViewController {
    // MARK: - Properties

    private var songIds = [57, 58]
    private let playEl = UIButton()
    private lazy var controlsEl: CorePlayer = {
        let v = CorePlayer(onProgress: self.handleProgress)
        return v
    }()
    
    private lazy var sliderEl: UISlider = {
        let v = UISlider()
        v.addTarget(self, action: #selector(self.handleSliderChange), for: .valueChanged)
        v.addTarget(self, action: #selector(self.handleSliderRelease), for: .touchUpInside)
        v.addTarget(self, action: #selector(self.handleSliderRelease), for: .touchUpOutside)
        return v
    }()
    
    // MARK: - Inits
    
    init() {
        super.init(nibName: nil, bundle: nil)
        UIApplication.shared.statusBarStyle = .lightContent
        view.backgroundColor = .white
        
        initViews()
        
        controlsEl.updateSong(id: "57")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        view.addSubview(controlsEl.viewEl)
        controlsEl.viewEl.heightAnchorToEqual(height: 200)
        controlsEl.viewEl.topAnchorToEqual(view.topAnchor)
        controlsEl.viewEl.leftAnchorToEqual(view.leftAnchor)
        controlsEl.viewEl.rightAnchorToEqual(view.rightAnchor)
        
        playEl.setTitle("play", for: .normal)
        playEl.addTarget(self, action: #selector(handlePlayBtn), for: .touchUpInside)
        playEl.backgroundColor = .red
        
        let nextEl = UIButton()
        nextEl.setTitle("next", for: .normal)
        nextEl.addTarget(self, action: #selector(nextSong), for: .touchUpInside)
        nextEl.backgroundColor = .blue
        
        let prevEl = UIButton()
        prevEl.setTitle("prev", for: .normal)
        prevEl.addTarget(self, action: #selector(prevSong), for: .touchUpInside)
        prevEl.backgroundColor = .blue
        
        let stackViewEl = UIStackView()
        stackViewEl.axis = .horizontal
        stackViewEl.distribution = .fillEqually
        stackViewEl.addArrangedSubview(prevEl)
        stackViewEl.addArrangedSubview(playEl)
        stackViewEl.addArrangedSubview(nextEl)
        
        view.addSubview(stackViewEl)
        stackViewEl.topAnchorToEqual(controlsEl.viewEl.bottomAnchor, constant: 10)
        stackViewEl.leftAnchorToEqual(view.leftAnchor)
        stackViewEl.rightAnchorToEqual(view.rightAnchor)
        
        view.addSubview(sliderEl)
        sliderEl.topAnchorToEqual(stackViewEl.bottomAnchor, constant: 10)
        sliderEl.leftAnchorToEqual(view.leftAnchor, constant: 30)
        sliderEl.rightAnchorToEqual(view.rightAnchor, constant: -30)
    }
    
    // MARK: - Private Methods
    
    @objc private func handleSliderRelease() {
        controlsEl.setTime(time: Double(sliderEl.value))
    }
    
    @objc private func handleSliderChange() {
        controlsEl.cancelProgressTimer()
    }
    
    private func handleProgress(currentTime: Double, duration: Double) {
        if !duration.isNaN { sliderEl.maximumValue = Float(duration) }
        sliderEl.setValue(Float(currentTime), animated: true)
    }
    
    @objc private func handlePlayBtn() {
        if controlsEl.player.rate != 0 && controlsEl.player.error == nil {
            pauseSong()
            playEl.setTitle("play", for: .normal)
        } else {
            playSong()
            playEl.setTitle("pause", for: .normal)
        }
    }
    
    private func playSong() {
        controlsEl.playSong()
    }
    
    private func pauseSong() {
        controlsEl.pauseSong()
    }
    
    @objc private func prevSong() {
        controlsEl.updateSong(id: "57")
    }
    
    @objc private func nextSong() {
        controlsEl.updateSong(id: "58")
    }
}
