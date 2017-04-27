//
//  ListView.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/27/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class ListView: UIView, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Typealiases
    
    typealias OnItemSelected = (_ item: MediaCell.Data) -> Void
    typealias EmptyCallback = () -> Void
    
    // MARK: - Properties
    
    private let cellId = "cellId"
    private var onItemSelected: OnItemSelected?
    private var onCloseClick: EmptyCallback?
    private var data: [MediaCell.Data] = []
    
    private var tableEl: UITableView = {
        let v = UITableView()
        v.backgroundColor = .black
        v.separatorStyle = .none
        return v
    }()
    
    private lazy var closeBtnEl: UIButton = {
        let v = UIButton()
        v.addTarget(self, action: #selector(self.handleCloseClick), for: .touchUpInside)
        
        v.widthAnchorToEqual(width: 25)
        v.heightAnchorToEqual(height: 17)
        v.setImage(#imageLiteral(resourceName: "icon - arrowdown"), for: .normal)
        return v
    }()
    
    private var titleEl: UILabel = {
        let v = UILabel()
        v.font = UIFont.boldSystemFont(ofSize: 30)
        v.text = "-"
        v.textColor = .white
        return v
    }()

    // MARK: - Inits

    init(_ title: String, onItemSelected: OnItemSelected?, onCloseClick: EmptyCallback?) {
        super.init(frame: .zero)
        self.onItemSelected = onItemSelected
        self.onCloseClick = onCloseClick
        self.titleEl.text = title
        tableEl.delegate = self
        tableEl.dataSource = self
        tableEl.register(MediaCell.self, forCellReuseIdentifier: cellId)
        backgroundColor = .black
        
        addSubview(titleEl)
        titleEl.topAnchorToEqual(topAnchor, constant: 30)
        titleEl.leftAnchorToEqual(leftAnchor, constant: 20)
        
        addSubview(closeBtnEl)
        closeBtnEl.centerYAnchorToEqual(titleEl.centerYAnchor)
        closeBtnEl.rightAnchorToEqual(rightAnchor, constant: -19)
        
        addSubview(tableEl)
        tableEl.topAnchorToEqual(titleEl.bottomAnchor, constant: 20)
        tableEl.leftAnchorToEqual(leftAnchor)
        tableEl.rightAnchorToEqual(rightAnchor)
        tableEl.bottomAnchorToEqual(bottomAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    @objc private func handleCloseClick() {
        onCloseClick?()
    }
    
    // MARK: - API Methods
    
    public func updateData(_ data: [MediaCell.Data]) {
        self.data = data
        tableEl.reloadData()
    }
    
    public static func getMediaCellDataArrayFromSongModelArray(_ songs: [SongModel]) -> [MediaCell.Data] {
        return songs.map { song -> MediaCell.Data in
            let imageUrl = song.allCovers.count == 0 ? nil : song.allCovers[0]
            return MediaCell.Data(id: song.id, title: song.name, subtitle: GeneralHelpers.getAlbumArtist(album: song.album, artist: song.artist), imageUrl: imageUrl)
        }
    }
    
    public static func getMediaCellDataArrayFromPlaylistModelArray(_ playlists: [PlaylistModel]) -> [MediaCell.Data] {
        return playlists.map { playlist -> MediaCell.Data in
            MediaCell.Data(id: playlist.id, title: playlist.name, subtitle: "Playlist", imageUrl: nil)
        }
    }
    
    // MARK: - Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MediaCell
        let data = self.data[indexPath.row]
        cell.data = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as! MediaCell).highlight()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as! MediaCell).highlight(false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onItemSelected?(data[indexPath.row])
    }
}
