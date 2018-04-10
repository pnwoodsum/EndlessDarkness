//
//  Player.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 4/9/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import Foundation
import UIKit

class Player {
    var position: CGPoint
    var currentImage: String
    var speed: Float
    var health: Float
    
    init () {
        self.position = CGPoint.init(x: 0.0, y: 0.0)
        self.currentImage = "playerUp.png"
        self.speed = 5.0
        self.health = 100.0
        
    }
    
    func move(xDirection: Float, yDirection: Float) {
        
        let magnitude = sqrt(powf(xDirection, 2) + powf(yDirection, 2))
        
        let xDisplacement = (xDirection / magnitude) * self.speed
        let yDisplacement = (yDirection / magnitude) * self.speed
        
        position.x += CGFloat(xDisplacement)
        position.y += CGFloat(yDisplacement)
    }
}
