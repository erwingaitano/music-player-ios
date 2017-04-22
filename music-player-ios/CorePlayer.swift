//
//  CorePlayer.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit
import AVFoundation

class CorePlayer: UIView {
    // MARK: - Typealiases
    
    typealias OnProgress = (_ currentTime: Double, _ duration: Double) -> Void
    typealias OnSongFinished = () -> Void
    
    // MARK: - Properties
    
    private var onProgress: OnProgress?
    public let viewEl = UIView()
    private var progressTimer: Timer?
    private var onSongFinished: OnSongFinished?
    public let player = AVPlayer(playerItem: nil)
    
    // MARK: - Inits
    
    init(onProgress: OnProgress? = nil, onSongFinished: OnSongFinished? = nil) {
        super.init(frame: .zero)
        self.onProgress = onProgress
        self.onSongFinished = onSongFinished

        let avPlayerLayer = AVPlayerLayer(player: player)
        viewEl.layer.addSublayer(avPlayerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEndOfSong), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func handleSongProgress(_: Timer) {
        guard let currentItem = player.currentItem else { return }
        let duration = CMTimeGetSeconds(currentItem.duration)
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        onProgress?(currentTime, duration)
    }
    
    private func startProgressTimer() {
        if progressTimer == nil {
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: handleSongProgress)
        }
    }
    
    private func getSongUrl(id: String) -> URL? {
        return URL(string: "http://localhost:3000/song-files/\(id)")
    }
    
    @objc private func handleEndOfSong() {
        onSongFinished?()
    }
    
    // MARK: - API Methods
    
    public func setTime(time: Double) {
        guard let currentItem = player.currentItem else { return }
        currentItem.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        startProgressTimer()
    }
    
    public func playSong() {
        startProgressTimer()
        player.play()
    }
    
    public func pauseSong() {
        cancelProgressTimer()
        player.pause()
    }
    
    public func cancelProgressTimer() {
        if progressTimer != nil {
            progressTimer!.invalidate()
            progressTimer = nil
        }
    }
    
    public func updateSong(id: String) {
        guard let url = getSongUrl(id: id) else { return }

        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        setTime(time: 0)
    }
    
    public func getSystemVolume() -> Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
}
