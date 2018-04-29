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
import GameplayKit

class LevelManager {
    var level = [Chunk]()
    var chunksToRemove = [Chunk]()
    var collectibleManager = CollectibleManager()
    let perlinNoiseObject: GKNoise?
    var isUpdating = false
    
    // Load 9 chunks at the start
    init(skScene: SKScene, seed: UInt32) {
        
        perlinNoiseObject = GKNoise(GKPerlinNoiseSource(frequency: 0.15, octaveCount: 3, persistence: 1, lacunarity: 1, seed: Int32(seed)))
        
        level.append(Chunk(position: CGPoint(x: 0.0, y: 0.0), skScene: skScene, collectibleManager: collectibleManager, perlinNoiseObject: perlinNoiseObject!))
        
        let adjacentChunks = GetAdjacentPositions(point: CGPoint(x: 0, y: 0), displacement: Double(GameData.ChunkPixelSize))
        
        for position in adjacentChunks {
            level.append(Chunk(position: position, skScene: skScene, collectibleManager: collectibleManager, perlinNoiseObject: perlinNoiseObject!))
            
        }
    }
    
    func CheckPlayerCollisions(player: Player) {
        let currentChunk: Chunk = ChunkContainsPoint(point: player.position)
        
        CheckCollisionsInChunk(currentChunk: currentChunk, player: player)
        
        
        let adjacentPoints = GetAdjacentPositions(point: player.position, displacement: Double(GameData.ChunkPixelSize))
        
        for point in adjacentPoints {
            let adjacentChunk = ChunkContainsPoint(point: point)
            
            CheckCollisionsInChunk(currentChunk: adjacentChunk, player: player)

        }
    }
    
    func CheckCollisionsInChunk(currentChunk: Chunk, player: Player) {
        for i in 0...GameData.ChunkTileWidth - 1 {
            for j in 0...GameData.ChunkTileWidth - 1 {
                if !currentChunk.tiles[i][j].pathable {
                    let xDifference = Float(currentChunk.tiles[i][j].tileTexture.position.x - player.position.x)
                    let yDifference = Float(currentChunk.tiles[i][j].tileTexture.position.y - player.position.y)
                    
                    let magnitude = sqrt(powf(xDifference, 2) + powf(yDifference, 2))
                    
                    let xDirection = (xDifference / magnitude)
                    let yDirection = (yDifference / magnitude)
                    
                    let closestX = CGFloat(xDirection * player.collisionRadius)
                    let closestY = CGFloat(yDirection * player.collisionRadius)
                    
                    let closestPlayerPosition = player.position + CGPoint(x: closestX, y: closestY)
                    
                    if currentChunk.tiles[i][j].tileTexture.contains(closestPlayerPosition) {
                        if abs(closestX) > abs(closestY) {
                            let xDisplacement =  abs(currentChunk.tiles[i][j].tileTexture.position.x) - abs(closestPlayerPosition.x)
                            let absXDisplacement = CGFloat(GameData.TilePixelSize) / 2 - abs(xDisplacement)
                            player.position.x += absXDisplacement * CGFloat(-xDirection)
                        }
                        else {
                            let yDisplacement = abs(currentChunk.tiles[i][j].tileTexture.position.y) - abs(closestPlayerPosition.y)
                            let absYDisplacement = CGFloat(GameData.TilePixelSize) / 2 - abs(yDisplacement)
                            player.position.y += absYDisplacement * CGFloat(-yDirection)
                        }
                    }
                }
            }
        }
    }
    
    // Create adjacent chunks if they do not exist
    func UpdateLevel(point: CGPoint, skScene: SKScene) {
        let currentChunk: Chunk = ChunkContainsPoint(point: point)
        let adjacentPoints = GetAdjacentPositions(point: currentChunk.position, displacement: Double(GameData.ChunkPixelSize))
            
        var currentChunkIndex = 0
        for chunk in level {
            if !adjacentPoints.contains(chunk.position) && chunk.position != currentChunk.position {
                chunksToRemove.append(chunk)
                level.remove(at: currentChunkIndex)
            }
            else {
                currentChunkIndex += 1
            }
        }
        for point in adjacentPoints {
            if !ChunkExists(point: point) {
                level.append(Chunk(position: point, skScene: skScene, collectibleManager: collectibleManager, perlinNoiseObject: perlinNoiseObject!))
            }
        }
        if (chunksToRemove.count > 0) {
            RemoveChunksBackground()
        }
    }
    
    func RemoveChunksBackground() {
        if !self.isUpdating {
            self.isUpdating = true
            
            let background = DispatchQueue.global()
            
            background.async { [unowned self] in
                
                // keep track of the indices of the tile that is going to be updated
                for currentChunkIndex in 0 ..< self.chunksToRemove.count {
                    for indexRow in 0 ..< 16 {
                        for indexCol in 0 ..< 16 {
                            // Update the chunk information in the mainthread
                            DispatchQueue.main.async { [unowned self] in
                                self.chunksToRemove[currentChunkIndex].tiles[indexRow][indexCol].tileTexture.removeFromParent()
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async { [unowned self] in
                    self.chunksToRemove.removeAll()
                }
                self.isUpdating = false
            }
            
            
        }
    }
    
    // Remove the chunk reference from the level array
    func RemoveChunk(chunk: Chunk, chunkIndex: Int) {

        
        level.remove(at: chunkIndex)
    }
    
    // Check to see which chunk is at the given point
    func ChunkContainsPoint(point: CGPoint) -> Chunk {
        for chunk in level {
            if point.x > ((chunk.position.x - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.x < (chunk.position.x + CGFloat(GameData.ChunkPixelSize) / 2)) {
                if point.y > ((chunk.position.y - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.y < (chunk.position.y + CGFloat(GameData.ChunkPixelSize) / 2)) {
                    return chunk
                }
            }
        }
        
        return level[0]
    }
    
    // Check to see if a chunk exists at a given point
    func ChunkExists(point: CGPoint) -> Bool {
        for chunk in level {
            if point.x > ((chunk.position.x - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.x < (chunk.position.x + CGFloat(GameData.ChunkPixelSize) / 2)) {
                if point.y > ((chunk.position.y - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.y < (chunk.position.y + CGFloat(GameData.ChunkPixelSize) / 2)) {
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
                if point.x > ((tile.tileTexture.position.x - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.x < (tile.tileTexture.position.x + CGFloat(GameData.ChunkPixelSize) / 2)) {
                    if point.y > ((tile.tileTexture.position.y - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.y < (tile.tileTexture.position.y + CGFloat(GameData.ChunkPixelSize) / 2)) {
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
class Chunk {
    var position: CGPoint
    var tiles = Array(repeating: Array(repeating: Tile(), count: GameData.ChunkTileWidth), count: GameData.ChunkTileWidth)
    
    var perlinNoiseMap: GKNoiseMap
    
    var isUpdating: Bool
    
    init(position: CGPoint, skScene: SKScene, collectibleManager: CollectibleManager, perlinNoiseObject: GKNoise) {
        self.position = position
        
        let leftSide = Float(position.x) - GameData.ChunkPixelSize / 2
        let bottomSide = Float(position.y) - GameData.ChunkPixelSize / 2
        
        self.perlinNoiseMap = GKNoiseMap(perlinNoiseObject,
                                         size: vector_double2(Double(GameData.ChunkTileWidth), Double(GameData.ChunkTileWidth)),
                                         origin: vector_double2(Double(leftSide / GameData.TilePixelSize), Double(bottomSide / GameData.TilePixelSize)), // Origin is the "bottom left" of the noise map
                                         sampleCount: vector_int2(50, 50),
                                         seamless: true)
        
        for i in 0..<GameData.ChunkTileWidth {
            for j in 0..<GameData.ChunkTileWidth {
                
                let noiseValue = perlinNoiseMap.value(at: vector_int2(Int32(i), Int32(j)))

                var tilePosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
                tilePosition.x = CGFloat(leftSide + (Float(i) * (GameData.ChunkPixelSize / Float(GameData.ChunkTileWidth))))
                tilePosition.y = CGFloat(bottomSide + (Float(j) * (GameData.ChunkPixelSize / Float(GameData.ChunkTileWidth))))
                self.tiles[i][j] = Tile(noiseValue: noiseValue, position: tilePosition, skScene: skScene, collectibleManager: collectibleManager)
            }
        }
        
        self.isUpdating = false
    }
}

// Contains information about each unique tile.
// Information is created when initialized based on the given type.
struct Tile {
    var tileTexture: SKSpriteNode
    var pathable: Bool
    var type: String = "Grass"
    
    init () {
        self.tileTexture = SKSpriteNode(texture: GameData.BackgroundTextures[0])
        self.pathable = true
    }
    
    init (noiseValue: Float, position: CGPoint, skScene: SKScene, collectibleManager: CollectibleManager) {
        
        if noiseValue < -0.5 {
            self.tileTexture = SKSpriteNode(texture: GameData.BackgroundTextures[0])
            pathable = true
        }
        else if noiseValue < 0.0 {
            self.tileTexture = SKSpriteNode(texture: GameData.BackgroundTextures[1])
            pathable = true
        }
        else if noiseValue < 0.6 {
            self.tileTexture = SKSpriteNode(texture: GameData.BackgroundTextures[2])
            pathable = true
            
            
            let randomInt = arc4random_uniform(_:20)
            
            // Adds collectible gold coin on this tile
            if randomInt < 2 {
                
                // collectibleManager.CreateNewCollectible(type: "GoldCoin", position: position, skScene: skScene)
            }
        }
        else if noiseValue <= 1.0 {
            self.tileTexture = SKSpriteNode(texture: GameData.RockTextures[0])
            pathable = false
        }
        else {
            self.tileTexture = SKSpriteNode(texture: GameData.BackgroundTextures[0])
            pathable = true
        }
        
        self.tileTexture.scale(to: CGSize(width: CGFloat(GameData.ChunkPixelSize / Float(GameData.ChunkTileWidth)), height: CGFloat(GameData.ChunkPixelSize / Float(GameData.ChunkTileWidth))))
        self.tileTexture.position = position
        self.tileTexture.zPosition = 0.1
        skScene.addChild(self.tileTexture)
    }
}
