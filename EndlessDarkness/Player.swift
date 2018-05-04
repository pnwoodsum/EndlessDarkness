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
    var name: String
    var position: CGPoint
    var currentImage: String
    var speed: Float
    var health: Float
    var experience: Float
    var level: Int
    var fireLevel: Int
    var money: Int
    var previousChunk: Chunk!
    var currentChunk: Chunk!
    var currentTile: Tile?
    var collisionRadius: Float
    
    init () {
        self.name = "Wizard"
        self.position = CGPoint.init(x: 0.0, y: 0.0)
        self.currentImage = "playerUp.png"
        self.speed = 250.0 * GameData.GlobalScale
        self.health = 100.0
        self.money = 0
        self.collisionRadius = 15.0 * GameData.GlobalScale
        self.experience = 0
        self.level = 0
        self.fireLevel = 0
    }
    
    func move(xDirection: Float, yDirection: Float, deltaTime: Float) {
        
        let magnitude = sqrt(powf(xDirection, 2) + powf(yDirection, 2))
        
        if (magnitude > 5.0) {
        
            let xDisplacement = (xDirection / magnitude) * self.speed * deltaTime
            let yDisplacement = (yDirection / magnitude) * self.speed * deltaTime
            
            position.x += CGFloat(xDisplacement)
            position.y -= CGFloat(yDisplacement)
        }
    }
}
