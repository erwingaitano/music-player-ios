//
//  MediaCell.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/22/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

class MediaCell: UITableViewCell {
    // MARK: - Structs
    
    struct Data {
        var id: String
        var title: String
        var subtitle: String
        var imageUrl: String?
    }
    
    // MARK: - Properties
    
    public var data: Data! {
        didSet {
            titleEl.text = data.title
            subtitleEl.text = data.subtitle
            setImage(data.imageUrl)
        }
    }
    
    private var containerEl: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()
    
    private var imageEl: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor.hexStringToUIColor(hex: "#D8D8D8")
        return v
    }()
    
    private var titleEl: UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 15)
        v.text = "..."
        return v
    }()
    
    private var subtitleEl: UILabel = {
        let v = UILabel()
        v.textColor = .secondaryUIColor
        v.font = UIFont.systemFont(ofSize: 14)
        v.text = "..."
        return v
    }()
    
    private var separatorEl: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.hexStringToUIColor(hex: "#2f2f2f")
        v.heightAnchorToEqual(height: 1)
        return v
    }()
    
    // MARK: - Inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        contentView.addSubview(containerEl)
        containerEl.allEdgeAnchorsToEqual(contentView)
        
        contentView.addSubview(separatorEl)
        separatorEl.bottomAnchorToEqual(containerEl.bottomAnchor)
        separatorEl.leftAnchorToEqual(containerEl.leftAnchor)
        separatorEl.rightAnchorToEqual(containerEl.rightAnchor)
        
        contentView.addSubview(imageEl)
        imageEl.widthAnchorToEqual(width: 42)
        imageEl.heightAnchorToEqual(height: 42)
        imageEl.centerYAnchorToEqual(containerEl.centerYAnchor)
        imageEl.leftAnchorToEqual(containerEl.leftAnchor, constant: 8)
        
        contentView.addSubview(titleEl)
        titleEl.heightAnchorToEqual(height: 18)
        titleEl.topAnchorToEqual(imageEl.topAnchor, constant: 4)
        titleEl.leftAnchorToEqual(imageEl.rightAnchor, constant: 8)
        
        contentView.addSubview(subtitleEl)
        subtitleEl.heightAnchorToEqual(height: 18)
        subtitleEl.topAnchorToEqual(titleEl.bottomAnchor, constant: 4)
        subtitleEl.leftAnchorToEqual(titleEl.leftAnchor)
    }
    
    // MARK: - Private Methods

    private func setImage(_ imageUrl: String?) {
        if let imageUrl = imageUrl {
            imageEl.kf.setImage(with: URL(string: GeneralHelpers.getCoverUrl(imageUrl)))
        } else {
            imageEl.image = nil
        }
    }
}
