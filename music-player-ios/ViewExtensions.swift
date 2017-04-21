//
//  ViewExtensions.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import UIKit

typealias allCardinalPointsLayoutConstraints = (top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint)

extension UIView {
    func addConstraintsWithFormat(format: String, views: [UIView]) {
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: format,
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: views.enumerated().reduce([String: UIView]()) { (accumulate, el) in
                let view = el.1
                var newAccumulate = accumulate
                
                view.translatesAutoresizingMaskIntoConstraints = false
                newAccumulate["v\(el.0)"] = view
                return newAccumulate
            }
        ))
    }
    
    func customAnchorToEqual(view: UIView, anchor: NSLayoutAttribute, toAnchor: NSLayoutAttribute, constant: CGFloat = 0) {
        NSLayoutConstraint(
            item: self,
            attribute: anchor,
            relatedBy: .equal,
            toItem: view,
            attribute: toAnchor,
            multiplier: 1,
            constant: constant
            ).isActive = true
    }
    
    func heightAnchorToEqual(height: CGFloat? = nil, anchor: NSLayoutDimension? = nil, multiplier: CGFloat = 1) {
        _ = heightAnchorToEqualGet(height: height, anchor: anchor, multiplier: multiplier)
    }
    
    func heightAnchorToEqualGet(height: CGFloat? = nil, anchor: NSLayoutDimension? = nil, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint
        
        if let height = height {
            constraint = self.heightAnchor.constraint(equalToConstant: height)
        } else {
            constraint = self.heightAnchor.constraint(equalTo: anchor!, multiplier: multiplier)
        }
        
        constraint.isActive = true
        return constraint
    }
    
    func widthAnchorToEqual(width: CGFloat? = nil, anchor: NSLayoutDimension? = nil, multiplier: CGFloat = 1) {
        _ = self.widthAnchorToEqualGet(width: width, anchor: anchor, multiplier: multiplier)
    }
    
    func widthAnchorToEqualGet(width: CGFloat? = nil, anchor: NSLayoutDimension? = nil, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint
        
        if let width = width {
            constraint = self.widthAnchor.constraint(equalToConstant: width)
        } else {
            constraint = self.widthAnchor.constraint(equalTo: anchor!, multiplier: multiplier)
        }
        
        constraint.isActive = true
        return constraint
    }
    
    func bottomAnchorToEqual(_ anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bottomAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func topAnchorToEqual(_ anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) {
        _ = self.topAnchorToEqualGet(anchor, constant: constant)
    }
    
    func topAnchorToEqualGet(_ anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.topAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func leftAnchorToEqual(_ anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) {
        _ = self.leftAnchorToEqualGet(anchor, constant: constant)
    }
    
    func leftAnchorToEqualGet(_ anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.leftAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func rightAnchorToEqual(_ anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0, _ options: [String: Any] = [:]) {
        _ = self.rightAnchorToEqualGet(anchor, constant: constant, options)
    }
    
    func rightAnchorToEqualGet(_ anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0, _ options: [String: Any] = [:]) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.rightAnchor.constraint(equalTo: anchor, constant: constant)
        if let priority = options["priority"] {
            constraint.priority = UILayoutPriority(priority as! Int)
            
        }
        constraint.isActive = true
        return constraint
    }
    
    func centerXAnchorToEqual(_ anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) {
        _ = self.centerXAnchorToEqualGet(anchor, constant: constant)
    }
    
    func centerXAnchorToEqualGet(_ anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.centerXAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func centerYAnchorToEqual(_ anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) {
        _ = self.centerYAnchorToEqualGet(anchor, constant: constant)
    }
    
    func centerYAnchorToEqualGet(_ anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.centerYAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func allEdgeAnchorsExceptBottomToEqual(_ view: UIView, constants: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: constants.top)
            .isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: constants.left)
            .isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: constants.right)
            .isActive = true
    }
    
    func allEdgeAnchorsExceptTopToEqual(_ view: UIView, constants: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constants.bottom)
            .isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: constants.left)
            .isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: constants.right)
            .isActive = true
    }
    
    func allEdgeAnchorsToEqual(_ view: UIView, constants: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)) {
        _ = self.allEdgeAnchorsToEqualGet(view, constants: constants)
    }
    
    func allEdgeAnchorsToEqualGet(_ view: UIView, constants: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)) -> allCardinalPointsLayoutConstraints {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constants.bottom)
        bottomConstraint.isActive = true
        
        let topConstraint = self.topAnchor.constraint(equalTo: view.topAnchor, constant: constants.top)
        topConstraint.isActive = true
        
        let leftConstraint = self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: constants.left)
        leftConstraint.isActive = true
        
        let rightConstraint = self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: constants.right)
        rightConstraint.isActive = true
        
        return (top: topConstraint, left: leftConstraint, bottom: bottomConstraint, right: rightConstraint)
    }
    
    static func disableAllCardinalConstraints(cardinalConstraints: allCardinalPointsLayoutConstraints) {
        cardinalConstraints.top.isActive = false
        cardinalConstraints.bottom.isActive = false
        cardinalConstraints.left.isActive = false
        cardinalConstraints.right.isActive = false
    }
}
