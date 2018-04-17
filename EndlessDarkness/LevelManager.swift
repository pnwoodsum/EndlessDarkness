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
    
    // Load 9 chunks at the start
    init(skScene: SKScene) {
        level.append(Chunk(position: CGPoint(x: 0.0, y: 0.0), skScene: skScene))
        
        let adjacentChunks = GetAdjacentPositions(point: CGPoint(x: 0, y: 0), displacement: Double(GameData.ChunkSize))
        
        for position in adjacentChunks {
            level.append(Chunk(position: position, skScene: skScene))
            
        }
        
    }
    
    // Create adjacent chunks if they do not exist
    func UpdateMap(point: CGPoint, skScene: SKScene) {
        if let currentChunk: Chunk = ChunkContainsPoint(point: point) {
            let adjacentPoints = GetAdjacentPositions(point: currentChunk.position, displacement: Double(GameData.ChunkSize))
            
            for point in adjacentPoints {
                if !ChunkExists(point: point) {
                    level.append(Chunk(position: point, skScene: skScene))
                    print(level.count)
                }
            }
        } 
    }
    
    // Check to see which chunk is at the given point
    func ChunkContainsPoint(point: CGPoint) -> Chunk? {
        for chunk in level {
            if point.x > ((chunk.position.x - CGFloat(GameData.ChunkSize) / 2)) && (point.x < (chunk.position.x + CGFloat(GameData.ChunkSize) / 2)) {
                if point.y > ((chunk.position.y - CGFloat(GameData.ChunkSize) / 2)) && (point.y < (chunk.position.y + CGFloat(GameData.ChunkSize) / 2)) {
                    return chunk
                }
            }
        }
        
        return nil
    }
    
    // Check to see if a chunk exists at a given point
    func ChunkExists(point: CGPoint) -> Bool {
        for chunk in level {
            if point.x > ((chunk.position.x - CGFloat(GameData.ChunkSize) / 2)) && (point.x < (chunk.position.x + CGFloat(GameData.ChunkSize) / 2)) {
                if point.y > ((chunk.position.y - CGFloat(GameData.ChunkSize) / 2)) && (point.y < (chunk.position.y + CGFloat(GameData.ChunkSize) / 2)) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // Check to see which tile contains the given point
    func TileContainsPoint(chunk: Chunk, point: CGPoint) -> Tile? {
        for tileRows in chunk.tiles {
            for tile in tileRows {
                if point.x > ((tile.type.position.x - CGFloat(GameData.ChunkSize) / 2)) && (point.x < (tile.type.position.x + CGFloat(GameData.ChunkSize) / 2)) {
                    if point.y > ((tile.type.position.y - CGFloat(GameData.ChunkSize) / 2)) && (point.y < (tile.type.position.y + CGFloat(GameData.ChunkSize) / 2)) {
                        return tile
                    }
                }
            }
        }
        
        return nil
    }
    
    // Return array of points of adjects positions
    func GetAdjacentPositions(point: CGPoint, displacement: Double) -> [CGPoint] {
        var adjacentPoints = [CGPoint]()
        
        adjacentPoints.append(point + CGPoint(x: displacement, y: 0.0))
        adjacentPoints.append(point + CGPoint(x: displacement, y: -displacement))
        adjacentPoints.append(point + CGPoint(x: 0.0, y: -displacement))
        adjacentPoints.append(point + CGPoint(x: -displacement, y: -displacement))
        adjacentPoints.append(point + CGPoint(x: -displacement, y: 0.0))
        adjacentPoints.append(point + CGPoint(x: -displacement, y: displacement))
        adjacentPoints.append(point + CGPoint(x: 0.0, y: displacement))
        adjacentPoints.append(point + CGPoint(x: displacement, y: displacement))

        return adjacentPoints
    }
}

// Chunk that contains tiles based on the number of tiles per chunk
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

// Contains information about each unique tile.
// Information is created when initialized based on the given type.
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
