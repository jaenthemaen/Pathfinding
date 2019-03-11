//
//  ViewController.swift
//  A_Star_Interactive
//
//  Created by Jan Müller on 02.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let btnStep: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Step", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let btnRun: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Run", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let btnStop: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Stop", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let btnClearField: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Clear", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let btnResetAlgorithm: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Reset", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    // UI Elements
    
    var nodeViews = [[NodeView]]()
    
    let margin: CGFloat = 16.0
    let interItemMargin: CGFloat = 0.5
    
    let fieldSize: CGFloat = 60.0
    
    // Maze Data
    
    var columns: Int = 0
    var rows: Int = 0
    
    var maze: Maze? = nil
    var algo: Algorithm? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        for view in [self.btnClearField, self.btnStep, self.btnRun, self.btnStop, self.btnResetAlgorithm] {
            self.view.addSubview(view)
        }
        
        self.btnClearField.addTarget(self, action: #selector(clear), for: .touchUpInside)
        self.btnRun.addTarget(self, action: #selector(run), for: .touchUpInside)
        self.btnStop.addTarget(self, action: #selector(stop), for: .touchUpInside)
        self.btnStep.addTarget(self, action: #selector(step), for: .touchUpInside)
        self.btnResetAlgorithm.addTarget(self, action: #selector(reset), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for view in [self.btnClearField, self.btnStep, self.btnRun, self.btnStop, self.btnResetAlgorithm] {
            view.sizeToFit()
        }
        
        self.btnRun.frame.origin = CGPoint(x: self.margin, y: self.margin)
        self.btnStep.frame.origin = CGPoint(x: self.btnRun.frame.maxX + self.margin * 2.0, y: self.margin)
        self.btnStop.frame.origin = CGPoint(x: self.btnStep.frame.maxX + self.margin * 2.0, y: self.margin)
        self.btnResetAlgorithm.frame.origin = CGPoint(x: self.btnStop.frame.maxX + self.margin * 2.0, y: self.margin)
        self.btnClearField.frame.origin = CGPoint(x: self.btnResetAlgorithm.frame.maxX + self.margin * 2.0, y: self.margin)
        
        self.initializeField()
    }
    
    
    /// MARK: Field Handling
    
    private func initializeField() {
        
        // calc sizes
        let fieldFrame = CGRect(x: self.margin, y: self.btnRun.frame.maxY + self.margin, width: self.view.frame.width - 2.0 * self.margin, height: self.view.frame.height - 2.0 * self.margin - self.btnRun.frame.maxY)
        
        self.columns = Int(floor(fieldFrame.width / self.fieldSize + self.interItemMargin))
        self.rows = Int(floor(fieldFrame.height / (self.fieldSize + self.interItemMargin)))
        
        var origin = fieldFrame.origin
        let viewSize = CGSize(width: self.fieldSize, height: self.fieldSize)
        
        
        // create maze
        self.maze = Maze(width: self.columns, height: self.rows)
        
        // create node views
        var rows: [[NodeView]] = []
        
        for r in (0..<self.rows) {
            var rowViews: [NodeView] = []
            
            for c in (0..<self.columns) {
                origin.x = CGFloat(c) * (self.fieldSize + self.interItemMargin) + self.margin
                let node = self.maze!.nodeAt(x: c, y: r)
                let view = NodeView(node: node!, changeHandler:{ (node: Node) in
                    print("Node at x: \(node.x) y: \(node.y) changed to type: \(node.type)")
                }, permissionChecker: { [weak self] in
                    return self?.algo == nil
                })
                view.frame = CGRect(origin: origin, size: viewSize)
                rowViews.append(view)
                self.view.addSubview(view)
            }
            
            origin.x = self.margin
            origin.y += self.fieldSize + self.interItemMargin
            
            rows.append(rowViews)
        }
        
        // save em
        self.nodeViews = rows
        
    }
    
    @objc private func resetField() {
        
        // reset NodeViews
        for row in self.nodeViews {
            for node in row {
                node.removeFromSuperview()
            }
        }
        
        self.nodeViews = []
        
        // reset maze
        self.maze = nil
        
        self.initializeField()
    }
    
    /// Algorithm Handling
    
    @objc private func reset() {
        print("RESET!")
        self.algo?.stop()
        self.algo = nil
        self.maze?.resetNodeStates()
    }
    
    @objc private func clear() {
        print("CLEAR!")
        self.resetField()
        self.algo?.stop()
        self.algo = nil
    }
    
    @objc private func run() {
        print("RUN!")
        
        if self.algo == nil {
            self.algo = AStarAlgorithm(maze: self.maze!)
        }
        
        self.algo?.run()
    }
    
    @objc private func stop() {
        print("STOP!")
        self.algo?.stop()
    }
    
    @objc private func step() {
        print("STEP!")
        
        if self.algo == nil {
            self.algo = AStarAlgorithm(maze: self.maze!)
        }
        
        self.algo?.step()
    }
    
}

