//
//  GameViewController.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 4/9/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = GameScene(size: view.frame.size)
            
            let skView = view 
            
            skView.presentScene(scene)
            
        }
    }
}

// Define the addition of two CGPoints for the esake of convenience
func +(leftHandSide: CGPoint, rightHandSide: CGPoint) -> CGPoint {
    return CGPoint(x: leftHandSide.x + rightHandSide.x, y: leftHandSide.y + rightHandSide.y)
}

// Define the subtraction of two CGPoints for the esake of convenience
func -(leftHandSide: CGPoint, rightHandSide: CGPoint) -> CGPoint {
    return CGPoint(x: leftHandSide.x - rightHandSide.x, y: leftHandSide.y - rightHandSide.y)
}
