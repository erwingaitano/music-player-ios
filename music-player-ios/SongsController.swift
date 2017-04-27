//
//  SongsController.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/22/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class SongsController: UIViewController {
    // MARK: - Properties
    
    private var listViewEl: ListView!
    private var onItemSelected: ListView.OnItemSelected?
    
    // MARK: - Inits

    init(onItemSelected: ListView.OnItemSelected? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.onItemSelected = onItemSelected
        listViewEl = ListView("All Songs", onItemSelected: handleItemSelected, onCloseClick: handleCloseClick)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSongsUpdate), name: .CustomSongsUpdated, object: nil)
        view = listViewEl
        
        updateData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func handleItemSelected(_ item: MediaCell.Data) {
        onItemSelected?(item)
        dismissView()
    }
    
    private func handleCloseClick() {
        dismissView()
    }

    @objc private func handleSongsUpdate() {
        updateData()
    }
    
    private func updateData() {
        listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(SongsSingleton.songs.items))
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
