//
//  PlayerController.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class PlayerController: UIViewController {
    // MARK: - Properties

    private var songs: [SongModel] = []
    private var currentIdxToPlay: Int = 0
    
    private var coverGradientEl: CAGradientLayer!
    private lazy var coverEl: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.backgroundColor = UIColor.hexStringToUIColor(hex: "#aaaaaa")
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        
        self.coverGradientEl = CAGradientLayer()
        self.coverGradientEl.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        self.coverGradientEl.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        v.layer.addSublayer(self.coverGradientEl)
        return v
    }()
    
    private let playEl = UIButton()
    private lazy var corePlayerEl: CorePlayer = {
        let v = CorePlayer(onProgress: self.handleProgress, onSongFinished: self.handleSongFinished)
        return v
    }()
    
    private lazy var sliderProgressEl: Slider = {
        let v = Slider()
        v.addTarget(self, action: #selector(self.handleSliderChange), for: .valueChanged)
        v.addTarget(self, action: #selector(self.handleSliderRelease), for: .touchUpInside)
        v.addTarget(self, action: #selector(self.handleSliderRelease), for: .touchUpOutside)
        return v
    }()
    
    private var songInfoEl: UIView = {
        let v = UIView()
        let labelSongTitleEl = UILabel()
        labelSongTitleEl.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        labelSongTitleEl.textColor = .white
        labelSongTitleEl.textAlignment = .center
        labelSongTitleEl.text = "Name of the Song"
        
        v.addSubview(labelSongTitleEl)
        labelSongTitleEl.topAnchorToEqual(v.topAnchor)
        labelSongTitleEl.leftAnchorToEqual(v.leftAnchor)
        labelSongTitleEl.rightAnchorToEqual(v.rightAnchor)
        
        let labelAlbumEl = UILabel()
        labelAlbumEl.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        labelAlbumEl.textColor = .secondaryUIColor
        labelAlbumEl.textAlignment = .center
        labelAlbumEl.text = "Author - Album"
        
        v.addSubview(labelAlbumEl)
        labelAlbumEl.topAnchorToEqual(labelSongTitleEl.bottomAnchor, constant: 5)
        labelAlbumEl.leftAnchorToEqual(v.leftAnchor)
        labelAlbumEl.rightAnchorToEqual(v.rightAnchor)
        return v
    }()
    
    private lazy var playControlsEl: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .fillEqually
        
        self.playEl.setImage(#imageLiteral(resourceName: "icon - play"), for: .normal)
        self.playEl.heightAnchorToEqual(height: 60)
        self.playEl.addTarget(self, action: #selector(handlePlayBtn), for: .touchUpInside)
        
        let prevEl = UIButton()
        prevEl.setImage(#imageLiteral(resourceName: "icon - fastbackward"), for: .normal)
        prevEl.addTarget(self, action: #selector(prevSong), for: .touchUpInside)
        
        let nextEl = UIButton()
        nextEl.setImage(#imageLiteral(resourceName: "icon - fastforward"), for: .normal)
        nextEl.addTarget(self, action: #selector(nextSong), for: .touchUpInside)
        
        v.addArrangedSubview(prevEl)
        v.addArrangedSubview(self.playEl)
        v.addArrangedSubview(nextEl)
        return v
    }()
    
    private lazy var volumeSliderEl: (view: UIView, slider: Slider) = {
        let v = UIView()
        let sv = Slider()
        sv.maximumValue = 1
        sv.value = self.corePlayerEl.getSystemVolume()
        sv.addTarget(self, action: #selector(self.handleVolumeChange), for: .valueChanged)
        
        let muteIconEl = UIImageView()
        muteIconEl.image = #imageLiteral(resourceName: "icon - nosound")
        muteIconEl.contentMode = .scaleAspectFit
        muteIconEl.widthAnchorToEqual(width: 9)
        muteIconEl.heightAnchorToEqual(height: 14)
        
        v.addSubview(muteIconEl)
        muteIconEl.centerYAnchorToEqual(v.centerYAnchor)
        muteIconEl.leftAnchorToEqual(v.leftAnchor)
        
        let fullsoundIconEl = UIImageView()
        fullsoundIconEl.image = #imageLiteral(resourceName: "icon - sound")
        fullsoundIconEl.contentMode = .scaleAspectFit
        fullsoundIconEl.widthAnchorToEqual(width: 21)
        fullsoundIconEl.heightAnchorToEqual(height: 17)
        
        v.addSubview(fullsoundIconEl)
        fullsoundIconEl.centerYAnchorToEqual(v.centerYAnchor)
        fullsoundIconEl.rightAnchorToEqual(v.rightAnchor)
        
        v.addSubview(sv)
        sv.centerYAnchorToEqual(v.centerYAnchor)
        sv.leftAnchorToEqual(muteIconEl.rightAnchor, constant: 5)
        sv.rightAnchorToEqual(fullsoundIconEl.leftAnchor, constant: -5)
        
        return (v, sv)
    }()
    
    private var labelStart: UILabel = {
        let v = PlayerController.getTimeLabelEl()
        v.text = "0:00"
        v.textAlignment = .left
        return v
    }()
    
    private var labelEnd: UILabel = {
        let v = PlayerController.getTimeLabelEl()
        v.text = "0:00"
        v.textAlignment = .right
        return v
    }()
    
    // MARK: - Inits
    
    init() {
        super.init(nibName: nil, bundle: nil)
        UIApplication.shared.statusBarStyle = .lightContent
        view.backgroundColor = .black
        
        initViews()
        _ = ApiEndpoints.getSongs().promise.then(execute: { songs -> Void in
            self.songs = songs
            self.handleSongUpdate(songs[0])
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        view.addSubview(corePlayerEl.viewEl)
        
        let coverWidth = view.bounds.width * 0.648
        
        view.addSubview(coverEl)
        coverEl.widthAnchorToEqual(width: coverWidth)
        coverEl.heightAnchorToEqual(height: coverWidth)
        coverEl.centerXAnchorToEqual(view.centerXAnchor)
        coverEl.topAnchorToEqual(view.topAnchor, constant: 35)
        
        view.addSubview(sliderProgressEl)
        sliderProgressEl.topAnchorToEqual(coverEl.bottomAnchor, constant: 21)
        sliderProgressEl.leftAnchorToEqual(coverEl.leftAnchor, constant: -23)
        sliderProgressEl.rightAnchorToEqual(coverEl.rightAnchor, constant: 23)
        
        view.addSubview(labelStart)
        labelStart.topAnchorToEqual(sliderProgressEl.bottomAnchor, constant: 1)
        labelStart.leftAnchorToEqual(sliderProgressEl.leftAnchor)
        
        view.addSubview(labelEnd)
        labelEnd.topAnchorToEqual(sliderProgressEl.bottomAnchor, constant: 1)
        labelEnd.rightAnchorToEqual(sliderProgressEl.rightAnchor)
        
        view.addSubview(songInfoEl)
        songInfoEl.heightAnchorToEqual(height: 50)
        songInfoEl.topAnchorToEqual(labelEnd.bottomAnchor, constant: 10)
        songInfoEl.leftAnchorToEqual(coverEl.leftAnchor)
        songInfoEl.rightAnchorToEqual(coverEl.rightAnchor)
        
        view.addSubview(playControlsEl)
        playControlsEl.topAnchorToEqual(songInfoEl.bottomAnchor, constant: 16)
        playControlsEl.leftAnchorToEqual(coverEl.leftAnchor)
        playControlsEl.rightAnchorToEqual(coverEl.rightAnchor)
        
        view.addSubview(volumeSliderEl.view)
        volumeSliderEl.view.heightAnchorToEqual(height: 21)
        volumeSliderEl.view.topAnchorToEqual(playControlsEl.bottomAnchor, constant: 26)
        volumeSliderEl.view.leftAnchorToEqual(coverEl.leftAnchor, constant: -17)
        volumeSliderEl.view.rightAnchorToEqual(coverEl.rightAnchor, constant: 28)
    }
    
    // MARK: - Life Cycles

    override func viewDidLayoutSubviews() {
        coverGradientEl.frame = coverEl.bounds
    }
    
    // MARK: - Private Methods
    
    @objc private func handleSliderRelease() {
        corePlayerEl.setTime(time: Double(sliderProgressEl.value))
    }
    
    @objc private func handleSliderChange() {
        corePlayerEl.cancelProgressTimer()
    }
    
    private func handleProgress(currentTime: Double, duration: Double) {
        if !duration.isNaN {
            sliderProgressEl.maximumValue = Float(duration)
            labelEnd.text = Int(duration).getMinuteSecondFormattedString()
        }
        
        sliderProgressEl.setValue(Float(currentTime), animated: true)
        labelStart.text = Int(currentTime).getMinuteSecondFormattedString()
    }
    
    @objc private func handlePlayBtn() {
        if corePlayerEl.player.rate != 0 && corePlayerEl.player.error == nil {
            playEl.setImage(#imageLiteral(resourceName: "icon - play"), for: .normal)
            pauseSong()
        } else {
            playEl.setImage(#imageLiteral(resourceName: "icon - pause"), for: .normal)
            playSong()
        }
    }
    
    private func playSong() {
        corePlayerEl.playSong()
    }
    
    private func pauseSong() {
        corePlayerEl.pauseSong()
    }
    
    @objc private func prevSong() {
        if currentIdxToPlay == 0 { return }
        currentIdxToPlay -= 1
        handleSongUpdate(songs[currentIdxToPlay])
    }
    
    @objc private func nextSong() {
        if currentIdxToPlay == self.songs.count - 1 { return }
        currentIdxToPlay += 1
        handleSongUpdate(songs[currentIdxToPlay])
    }
    
    @objc private func handleVolumeChange() {
        corePlayerEl.player.volume = volumeSliderEl.slider.value
    }
    
    private func handleSongUpdate(_ song: SongModel) {
        corePlayerEl.updateSong(id: song.id)
        (songInfoEl.subviews[0] as! UILabel).text = song.name
        (songInfoEl.subviews[1] as! UILabel).text = song.album ?? "Album Unknown"
    }
    
    private func handleSongFinished() {
        if (currentIdxToPlay == songs.count - 1) {
            currentIdxToPlay = 0
            handleSongUpdate(songs[currentIdxToPlay])
            return
        }
        
        nextSong()
        playSong()
    }
    
    // MARK: - API Methods
    
    public static func getTimeLabelEl() -> UILabel {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13)
        v.textColor = .white
        return v
    }
}
