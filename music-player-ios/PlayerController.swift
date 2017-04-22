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
        v.clipsToBounds = true
        
        self.coverGradientEl = CAGradientLayer()
        self.coverGradientEl.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        self.coverGradientEl.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
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
        labelSongTitleEl.text = "-"
        
        v.addSubview(labelSongTitleEl)
        labelSongTitleEl.topAnchorToEqual(v.topAnchor)
        labelSongTitleEl.leftAnchorToEqual(v.leftAnchor)
        labelSongTitleEl.rightAnchorToEqual(v.rightAnchor)
        
        let labelAlbumEl = UILabel()
        labelAlbumEl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        labelAlbumEl.textColor = .secondaryUIColor
        labelAlbumEl.textAlignment = .center
        labelAlbumEl.text = "-"
        
        v.addSubview(labelAlbumEl)
        labelAlbumEl.topAnchorToEqual(labelSongTitleEl.bottomAnchor, constant: 2)
        labelAlbumEl.leftAnchorToEqual(v.leftAnchor)
        labelAlbumEl.rightAnchorToEqual(v.rightAnchor)
        return v
    }()
    
    private lazy var playControlsEl: UIView = {
        let v = UIView()
        let viewHeight: CGFloat = 80
        let controlSep: CGFloat = 20
        let prevNextElWidth: CGFloat = 37
        let prevNextElHeight: CGFloat = 30
        
        self.playEl.setImage(#imageLiteral(resourceName: "icon - play"), for: .normal)
        self.playEl.addTarget(self, action: #selector(handlePlayBtn), for: .touchUpInside)
        
        v.addSubview(self.playEl)
        self.playEl.widthAnchorToEqual(width: viewHeight)
        self.playEl.heightAnchorToEqual(height: viewHeight)
        self.playEl.centerYAnchorToEqual(v.centerYAnchor)
        self.playEl.centerXAnchorToEqual(v.centerXAnchor)
        
        let prevEl = UIButton()
        prevEl.setImage(#imageLiteral(resourceName: "icon - fastbackward"), for: .normal)
        prevEl.addTarget(self, action: #selector(prevSong), for: .touchUpInside)
        
        v.addSubview(prevEl)
        prevEl.widthAnchorToEqual(width: prevNextElWidth)
        prevEl.heightAnchorToEqual(height: prevNextElHeight)
        prevEl.centerYAnchorToEqual(self.playEl.centerYAnchor)
        prevEl.rightAnchorToEqual(self.playEl.leftAnchor, constant: -controlSep)
        
        let nextEl = UIButton()
        nextEl.setImage(#imageLiteral(resourceName: "icon - fastforward"), for: .normal)
        nextEl.addTarget(self, action: #selector(nextSong), for: .touchUpInside)
        
        v.addSubview(nextEl)
        nextEl.widthAnchorToEqual(width: prevNextElWidth)
        nextEl.heightAnchorToEqual(height: prevNextElHeight)
        nextEl.centerYAnchorToEqual(self.playEl.centerYAnchor)
        nextEl.leftAnchorToEqual(self.playEl.rightAnchor, constant: controlSep)
        
        v.heightAnchorToEqual(height: viewHeight)
        
        return v
    }()
    
    private var labelStart: UILabel = {
        let v = PlayerController.getTimeLabelEl()
        v.text = "-:--"
        v.textAlignment = .left
        return v
    }()
    
    private var labelEnd: UILabel = {
        let v = PlayerController.getTimeLabelEl()
        v.text = "-:--"
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
        
        let coverWidth = view.bounds.width * 0.824
        
        view.addSubview(coverEl)
        coverEl.widthAnchorToEqual(width: coverWidth)
        coverEl.heightAnchorToEqual(height: coverWidth)
        coverEl.topAnchorToEqual(view.topAnchor, constant: 30)
        coverEl.centerXAnchorToEqual(view.centerXAnchor)
        
        view.addSubview(sliderProgressEl)
        sliderProgressEl.topAnchorToEqual(coverEl.bottomAnchor, constant: 11)
        sliderProgressEl.leftAnchorToEqual(coverEl.leftAnchor, constant: 40)
        sliderProgressEl.rightAnchorToEqual(coverEl.rightAnchor, constant: -40)
        
        view.addSubview(labelStart)
        labelStart.centerYAnchorToEqual(sliderProgressEl.centerYAnchor)
        labelStart.leftAnchorToEqual(coverEl.leftAnchor)
        
        view.addSubview(labelEnd)
        labelEnd.centerYAnchorToEqual(sliderProgressEl.centerYAnchor)
        labelEnd.rightAnchorToEqual(coverEl.rightAnchor)
        
        view.addSubview(songInfoEl)
        songInfoEl.heightAnchorToEqual(height: 50)
        songInfoEl.topAnchorToEqual(sliderProgressEl.bottomAnchor, constant: 11)
        songInfoEl.leftAnchorToEqual(coverEl.leftAnchor)
        songInfoEl.rightAnchorToEqual(coverEl.rightAnchor)
        
        view.addSubview(playControlsEl)
        playControlsEl.topAnchorToEqual(songInfoEl.bottomAnchor, constant: 7)
        playControlsEl.leftAnchorToEqual(coverEl.leftAnchor)
        playControlsEl.rightAnchorToEqual(coverEl.rightAnchor)
        
        let sectionBtnsWidth: CGFloat = 54
        let songsBtnEl = UIButton()
        songsBtnEl.setImage(#imageLiteral(resourceName: "icon - songs"), for: .normal)
        
        view.addSubview(songsBtnEl)
        songsBtnEl.topAnchorToEqual(playControlsEl.bottomAnchor, constant: 30)
        songsBtnEl.leftAnchorToEqual(coverEl.leftAnchor)
        songsBtnEl.widthAnchorToEqual(width: sectionBtnsWidth)
        songsBtnEl.heightAnchorToEqual(height: sectionBtnsWidth)
        
        let currentPlaylistBtnEl = UIButton()
        currentPlaylistBtnEl.setImage(#imageLiteral(resourceName: "icon - currentplaylist"), for: .normal)
        
        view.addSubview(currentPlaylistBtnEl)
        currentPlaylistBtnEl.topAnchorToEqual(playControlsEl.bottomAnchor, constant: 30)
        currentPlaylistBtnEl.centerXAnchorToEqual(view.centerXAnchor)
        currentPlaylistBtnEl.widthAnchorToEqual(width: sectionBtnsWidth)
        currentPlaylistBtnEl.heightAnchorToEqual(height: sectionBtnsWidth)
        
        let playlistsBtnEl = UIButton()
        playlistsBtnEl.setImage(#imageLiteral(resourceName: "icon - playlists"), for: .normal)
        
        view.addSubview(playlistsBtnEl)
        playlistsBtnEl.topAnchorToEqual(playControlsEl.bottomAnchor, constant: 30)
        playlistsBtnEl.rightAnchorToEqual(coverEl.rightAnchor)
        playlistsBtnEl.widthAnchorToEqual(width: sectionBtnsWidth)
        playlistsBtnEl.heightAnchorToEqual(height: sectionBtnsWidth)
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
