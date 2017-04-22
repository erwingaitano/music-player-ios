//
//  SongsController.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/22/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class SongsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties

    private let cellId = "cellId"
    private var titleEl: UILabel = {
        let v = UILabel()
        v.font = UIFont.boldSystemFont(ofSize: 36)
        v.text = "Songs"
        v.textColor = .white
        return v
    }()
    
    private var tableEl: UITableView = {
        let v = UITableView()
        v.backgroundColor = .blue
        v.separatorStyle = .none
        return v
    }()
    
    private var dummyData = [
        SongModel(id: "1", name: "Somewhere only we know", authors: nil, album: nil),
        SongModel(id: "2", name: "Somewhere only we know", authors: nil, album: nil)
    ]
    
    // MARK: - Inits

    init() {
        super.init(nibName: nil, bundle: nil)
        tableEl.delegate = self
        tableEl.dataSource = self
        tableEl.register(MediaCell.self, forCellReuseIdentifier: cellId)
        view.backgroundColor = .red
        
        view.addSubview(titleEl)
        titleEl.topAnchorToEqual(view.topAnchor, constant: 20)
        titleEl.leftAnchorToEqual(view.leftAnchor, constant: 20)
        
        view.addSubview(tableEl)
        tableEl.topAnchorToEqual(titleEl.bottomAnchor, constant: 20)
        tableEl.leftAnchorToEqual(view.leftAnchor)
        tableEl.rightAnchorToEqual(view.rightAnchor)
        tableEl.bottomAnchorToEqual(view.bottomAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MediaCell
        let data = dummyData[indexPath.row]
        cell.data = MediaCell.Data(title: data.name, subtitle: data.album ?? "-")
        
        return cell
    }
}
