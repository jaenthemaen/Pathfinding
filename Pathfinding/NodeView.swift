//
//  NodeView.swift
//  A_Star_Interactive
//
//  Created by Jan Müller on 02.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation
import UIKit

typealias NodeChangePermissionChecker = () -> (Bool)
typealias NodeTypeChangedHandler = (_ node: Node) -> ()

class NodeView: UIView {
    
    private var node: Node
    private var stateObservation: NSKeyValueObservation?
    let lblTitle: UILabel
    let lblGCost: UILabel
    let lblHCost: UILabel
    let lblTotalCost: UILabel
    let changeHandler: NodeTypeChangedHandler
    let permissionChecker: NodeChangePermissionChecker
    
    deinit {
        for rec in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(rec)
        }
    }
    
    init(node: Node, changeHandler: @escaping NodeTypeChangedHandler, permissionChecker: @escaping NodeChangePermissionChecker) {
        self.node = node
        self.lblTitle = UILabel(frame: .zero)
        self.lblTitle.font = UIFont.systemFont(ofSize: 20.0)
        self.lblTitle.textAlignment = .center
        self.lblTitle.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        let lblGenerator: () -> UILabel = {
            let lbl = UILabel(frame: .zero)
            lbl.font = UIFont.systemFont(ofSize: 12.0)
            lbl.textColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
            return lbl
        }
        self.lblGCost = lblGenerator()
        self.lblGCost.textAlignment = .left
        self.lblHCost = lblGenerator()
        self.lblHCost.textAlignment = .right
        self.lblTotalCost = lblGenerator()
        self.lblTotalCost.textAlignment = .left
        
        self.changeHandler = changeHandler
        self.permissionChecker = permissionChecker
        
        super.init(frame: .zero)
        
        self.stateObservation = self.node.observe(\Node.state, options: [.new]) { [weak self] (node, change) in
            self?.setNeedsLayout()
        }
        
        for view in [self.lblTitle, self.lblGCost, self.lblHCost, self.lblTotalCost] {
            self.addSubview(view)
        }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchTypeToNext)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.handleCostLabels()
        
        self.lblTitle.frame = self.bounds
        
        for view in [self.self.lblGCost, self.lblHCost, self.lblTotalCost] {
            view.sizeToFit()
        }
        
        self.lblTotalCost.frame.origin = self.bounds.origin.applying(CGAffineTransform(translationX: 1.0, y: 1.0))
        self.lblGCost.frame.origin = CGPoint(x: 0, y: self.bounds.maxY - self.lblGCost.frame.height).applying(CGAffineTransform(translationX: 1.0, y: -1.0))
        self.lblHCost.frame.origin = CGPoint(x: self.bounds.maxX - self.lblHCost.frame.width, y: self.bounds.maxY - self.lblHCost.frame.height).applying(CGAffineTransform(translationX: -1.0, y: -1.0))
        
        switch self.node.type {
        case .start:
            self.backgroundColor = .orange
            self.lblTitle.text = "🚩"
        case .free:
            self.backgroundColor = .lightGray
            self.lblTitle.text = nil
        case .wall:
            self.backgroundColor = .black
            self.lblTitle.text = nil
        case .goal:
            self.backgroundColor = .purple
            self.lblTitle.text = "🏁"
        case .unknown:
            self.backgroundColor = .lightGray
            self.lblTitle.text = "❔"
        }
        
        let activeNodeStates: [NodeState] = [.open, .closed, .path]
        self.layer.borderWidth = activeNodeStates.contains(self.node.state) ? 3.0 : 1.0
        
        self.layer.borderColor = { [weak self] in
            switch self?.node.state ?? .unchecked {
            case .unchecked:
                return UIColor.darkGray.cgColor
            case .open:
                return UIColor.blue.cgColor
            case .closed:
                return UIColor.brown.cgColor
            case .path:
                return UIColor.green.cgColor
            }
        }()
    }
    
    private func handleCostLabels() {
        switch self.node.state {
        case .unchecked:
            self.clearCostLabels()
        case .open:
            fallthrough
        case .closed:
            fallthrough
        case .path:
            self.fillCostLabels()
        }
    }
    
    private func clearCostLabels() {
        for lbl in [self.lblTotalCost, self.lblHCost, self.lblGCost] {
            lbl.text = nil
        }
    }
    
    private func fillCostLabels() {
        self.lblTotalCost.text = String(Int(self.node.totalCost))
        self.lblGCost.text = String(Int(self.node.gCost))
        self.lblHCost.text = String(Int(self.node.hCost))
    }
    
    @objc public func switchTypeToNext() {
        if self.permissionChecker() {
            self.node.type.next()
            self.setNeedsLayout()
            self.changeHandler(node)
        } else {
            print("Unable to change node at the moment. Algorithm running?")
        }
    }
    
    @objc public func switchTypeToWall() {
        if self.permissionChecker() {
            self.node.type = .wall
            self.setNeedsLayout()
            self.changeHandler(node)
//            UIView.animate(withDuration: 0.3, delay: 0.1, options: [.beginFromCurrentState], animations: { [weak self] in
//                self.frame = self?.frame.applying(CGAffin)
//            }, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        } else {
            print("Unable to change node at the moment. Algorithm running?")
        }
    }
    
}
