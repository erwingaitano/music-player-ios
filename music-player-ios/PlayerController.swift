//
//  PlayerController.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Kingfisher

class PlayerController: UIViewController {
    // MARK: - Properties

    private var songs: [SongModel] = []
    private var currentIdxToPlay: Int = 0
    private var updateSongPromiseEl: ApiEndpoints.PromiseEl?
    private var getPlaylistSongsPromiseEl: ApiEndpoints.SongsPromiseEl?
    
    private lazy var coverEl = PlayerCover()
    
    private let playEl = UIButton()
    private lazy var corePlayerEl: CorePlayer = {
        let v = CorePlayer(onProgress: self.handleSongProgress, onSongFinished: self.handleSongFinished)
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleSongsUpdate), name: .CustomSongsUpdated, object: nil)
        
        initViews()
        initRemoteControlsAndMusicInBackground()
        SongsSingleton.songs.update()
        SongsSingleton.songs.updatePlaylists()
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
        songsBtnEl.addTarget(self, action: #selector(handleSongsBtnElClick), for: .touchUpInside)
        
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
        currentPlaylistBtnEl.addTarget(self, action: #selector(handleCurrentPlaylistBtnElClick), for: .touchUpInside)
        
        let playlistsBtnEl = UIButton()
        playlistsBtnEl.setImage(#imageLiteral(resourceName: "icon - playlists"), for: .normal)
        
        view.addSubview(playlistsBtnEl)
        playlistsBtnEl.topAnchorToEqual(playControlsEl.bottomAnchor, constant: 30)
        playlistsBtnEl.rightAnchorToEqual(coverEl.rightAnchor)
        playlistsBtnEl.widthAnchorToEqual(width: sectionBtnsWidth)
        playlistsBtnEl.heightAnchorToEqual(height: sectionBtnsWidth)
        playlistsBtnEl.addTarget(self, action: #selector(handlePlaylistsBtnElClick), for: .touchUpInside)
    }
    
    private func initRemoteControlsAndMusicInBackground() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        remoteCommandCenter.pauseCommand.addTarget(handler: handleRemotePauseCommand)
        remoteCommandCenter.playCommand.addTarget(handler: handleRemotePlayCommand)
        remoteCommandCenter.nextTrackCommand.addTarget(handler: handleRemoteNextCommand)
        remoteCommandCenter.previousTrackCommand.addTarget(handler: handleRemotePreviousCommand)
        remoteCommandCenter.changePlaybackPositionCommand.addTarget(handler: handleRemoteProgressSliderCommand)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycles

//    override func viewDidLayoutSubviews() {
//        coverGradientEl.frame = coverEl.bounds
//    }
    
    // MARK: - Private Methods
    
    @objc private func handleSongsUpdate() {
        songs = SongsSingleton.songs.items
        startPlaylist(songs, shouldStartPlaying: false)
    }
    
    @objc private func handleSliderRelease() {
        jumpToSongTime(time: Double(sliderProgressEl.value))
    }
    
    @objc private func handleSliderChange() {
        corePlayerEl.cancelProgressTimer()
    }
    
    private func handleSongProgress(currentTime: Double, duration: Double) {
        updateTimeLabels(currentTime: currentTime, duration: duration)
        if !sliderProgressEl.isTracking { updateSlider(currentTime: currentTime, duration: duration) }
    }
    
    @objc private func handlePlayBtn() {
        if corePlayerEl.player.rate != 0 && corePlayerEl.player.error == nil {
            pauseSong()
        } else {
            playSong()
        }
    }
    
    private func updateTimeLabels(currentTime: Double?, duration: Double?) {
        guard let currentTime = currentTime, let duration = duration, !duration.isNaN else {
            labelStart.text = "-:--"
            labelEnd.text = "-:--"
            return
        }
        
        labelEnd.text = Int(duration).getMinuteSecondFormattedString()
        labelStart.text = Int(currentTime).getMinuteSecondFormattedString()
    }
    
    private func updateSlider(currentTime: Double, duration: Double) {
        if !duration.isNaN { sliderProgressEl.maximumValue = Float(duration) }
        sliderProgressEl.setValue(Float(currentTime), animated: true)
    }
    
    private func playSong() {
        playEl.setImage(#imageLiteral(resourceName: "icon - pause"), for: .normal)
        updateRemoteSongInfo(playbackRate: 1)
        corePlayerEl.playSong()
    }
    
    private func pauseSong() {
        playEl.setImage(#imageLiteral(resourceName: "icon - play"), for: .normal)
        updateRemoteSongInfo(playbackRate: 0)
        corePlayerEl.pauseSong()
    }
    
    @objc private func prevSong() {
        if currentIdxToPlay == 0 { return }
        currentIdxToPlay -= 1
        updateSong(songs[currentIdxToPlay])
    }
    
    @objc private func nextSong() {
        if currentIdxToPlay == self.songs.count - 1 { return }
        currentIdxToPlay += 1
        updateSong(songs[currentIdxToPlay])
    }
    
    private func jumpToSongTime(time: Double) {
        corePlayerEl.setTime(time: time)
    }
    
    private func updateSong(_ song: SongModel) {
        let name = song.name
        let albumArtist = GeneralHelpers.getAlbumArtist(album: song.album, artist: song.artist)
        (self.songInfoEl.subviews[0] as! UILabel).text = name
        (self.songInfoEl.subviews[1] as! UILabel).text = albumArtist
        
        coverEl.setCovers(song.allCovers)
        
        updateRemoteSongInfo(name: name, album: albumArtist, currentTime: nil, duration: nil, options: ["resetTimeLabels"])
        updateSlider(currentTime: 0, duration: 0)
        updateTimeLabels(currentTime: nil, duration: nil)
        
        updateSongPromiseEl?.canceler()
        updateSongPromiseEl = corePlayerEl.updateSong(id: song.id)
        _ = updateSongPromiseEl?.promise.then(execute: { _ -> Void in
            let duration = CMTimeGetSeconds(self.corePlayerEl.player.currentItem!.duration)
            
            self.updateTimeLabels(currentTime: 0, duration: duration)
            self.updateSlider(currentTime: 0, duration: duration)
            self.updateRemoteSongInfo(currentTime: 0, duration: duration)
        })
    }
    
    private func handleSongFinished() {
        if (currentIdxToPlay == songs.count - 1) {
            pauseSong()
            currentIdxToPlay = 0
            updateSong(songs[currentIdxToPlay])
            return
        }
        
        nextSong()
        playSong()
    }
    
    private func handleItemForSongSelected(item: MediaCell.Data) {
        startPlaylist(SongsSingleton.songs.items.filter({ $0.id == item.id }))
    }
    
    private func handleItemForCurrentPlaylistItemSelected(item: MediaCell.Data) {
        playSong()
        updateSong(songs.filter({ $0.id == item.id })[0])
    }
    
    private func handleItemForPlaylistSelected(playlist: MediaCell.Data) {
        getPlaylistSongsPromiseEl?.canceler()
        
        getPlaylistSongsPromiseEl = ApiEndpoints.getPlaylistSongs(playlist.id)
        _ = getPlaylistSongsPromiseEl?.promise
        .then { songs -> Void in self.startPlaylist(songs) }
    }
    
    private func startPlaylist(_ songs: [SongModel], shouldStartPlaying: Bool = true) {
        self.songs = songs
        currentIdxToPlay = 0
        updateSong(songs[0])
        
        if shouldStartPlaying { playSong() }
        else { pauseSong() }
    }
    
    @objc private func handleSongsBtnElClick() {
        present(SongsController(onItemSelected: handleItemForSongSelected), animated: true, completion: nil)
    }
    
    @objc private func handleCurrentPlaylistBtnElClick() {
        present(CurrentPlaylistController(songs, onItemSelected: handleItemForCurrentPlaylistItemSelected), animated: true, completion: nil)
    }
    
    @objc private func handlePlaylistsBtnElClick() {
        present(PlaylistsController(onItemSelected: handleItemForPlaylistSelected), animated: true, completion: nil)
    }
    
    private func updateRemoteSongInfo(name: String? = nil, album: String? = nil, currentTime: Double? = nil, duration: Double? = nil, playbackRate: Double? = nil, options: [String] = []) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        let name = name ?? nowPlayingInfo?[MPMediaItemPropertyTitle] ?? ""
        let album = album ?? nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] ?? ""
        let duration = duration ?? nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] ?? 0
        let currentTime = currentTime ?? nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] ?? 0
        let playbackRate = playbackRate ?? nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] ?? 0
        
        var values = [
            MPMediaItemPropertyTitle: name,
            MPMediaItemPropertyAlbumTitle: album,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate
        ]
        if (options.contains("resetTimeLabels")) {
            values.removeValue(forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            values.removeValue(forKey: MPMediaItemPropertyPlaybackDuration)
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = values
    }
    
    private func handleRemotePauseCommand(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        pauseSong()
        return .success
    }
    
    private func handleRemotePlayCommand(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        playSong()
        return .success
    }
    
    private func handleRemoteNextCommand(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        nextSong()
        return .success
    }
    
    private func handleRemotePreviousCommand(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        prevSong()
        return .success
    }
    
    private func handleRemoteProgressSliderCommand(e: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        let e = e as! MPChangePlaybackPositionCommandEvent
        print(e.positionTime)
        return .success
    }
    
    private static func getTimeLabelEl() -> UILabel {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13)
        v.textColor = .white
        return v
    }
}
