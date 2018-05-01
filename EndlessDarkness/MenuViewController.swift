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

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = MenuScene(size: view.frame.size)
            
            let skView = view
            
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            skView.presentScene(scene)
            
        }
    }
}
