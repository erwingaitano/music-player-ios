//
//  CurrentPlaylistController.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/22/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class CurrentPlaylistController: UIViewController {
    // MARK: - Properties
    
    private var listViewEl: ListView!
    
    // MARK: - Inits
    
    init(_ songs: [SongModel], onItemSelected: ListView.OnItemSelected? = nil) {
        super.init(nibName: nil, bundle: nil)
        listViewEl = ListView("Current Playlist", onItemSelected: onItemSelected, onCloseClick: handleCloseClick)
        view = listViewEl
        listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(songs))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func handleCloseClick() {
        dismissView()
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
