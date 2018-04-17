//
//  LevelManager.swift
//  EndlessDarkness
//
//  Created by Student on 4/12/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LevelManager {
    var level = [Chunk]()
    
    init(skScene: SKScene) {
        level.append(Chunk(position: CGPoint(x: 0.0, y: 0.0), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: Double(GameData.ChunkSize), y: 0.0), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: Double(GameData.ChunkSize), y: -Double(GameData.ChunkSize)), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: 0.0, y: -Double(GameData.ChunkSize)), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: -Double(GameData.ChunkSize), y: -Double(GameData.ChunkSize)), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: -Double(GameData.ChunkSize), y: 0.0), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: -Double(GameData.ChunkSize), y: Double(GameData.ChunkSize)), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: 0.0, y: Double(GameData.ChunkSize)), skScene: skScene))
        level.append(Chunk(position: CGPoint(x: Double(GameData.ChunkSize), y: Double(GameData.ChunkSize)), skScene: skScene))
    }
    
    func ContainsPoint(point: CGPoint) {
        
    }
}

struct Chunk {
    var position: CGPoint
    var tiles = Array(repeating: Array(repeating: Tile(), count: GameData.TilesPerChunk), count: GameData.TilesPerChunk)
    
    init(position: CGPoint, skScene: SKScene) {
        self.position = position
        let leftSide = Float(position.x) - GameData.ChunkSize / 2
        let bottomSide = Float(position.y) - GameData.ChunkSize / 2
        
        for i in 0...GameData.TilesPerChunk - 1 {
            for j in 0...GameData.TilesPerChunk - 1 {
                let randomInt = arc4random_uniform(_:3)
                var tilePosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
                tilePosition.x = CGFloat(leftSide + (Float(i) * (GameData.ChunkSize / Float(GameData.TilesPerChunk))))
                tilePosition.y = CGFloat(bottomSide + (Float(j) * (GameData.ChunkSize / Float(GameData.TilesPerChunk))))
                self.tiles[i][j] = Tile(type: randomInt, position: tilePosition, skScene: skScene)
            }
        }
    }
}


struct Tile {
    var type: SKSpriteNode
    
    init () {
        self.type = SKSpriteNode(imageNamed: "grass0")
    }
    
    init (type: UInt32, position: CGPoint, skScene: SKScene ) {
        switch type {
        case 0:
            self.type = SKSpriteNode(imageNamed: "grass0")
        case 1:
            self.type = SKSpriteNode(imageNamed: "grass1")
        case 2:
            self.type = SKSpriteNode(imageNamed: "grass2")
        default:
            self.type = SKSpriteNode(imageNamed: "grass0")
        }
        
        self.type.scale(to: CGSize(width: CGFloat(GameData.ChunkSize / Float(GameData.TilesPerChunk)), height: CGFloat(GameData.ChunkSize / Float(GameData.TilesPerChunk))))
        self.type.position = position
        self.type.zPosition = 0.1
        skScene.addChild(self.type)
    }
}
