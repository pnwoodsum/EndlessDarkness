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
    var collectibleManager = CollectibleManager()
    let perlinNoiseObject: GKNoise?
    var isUpdating = false
    
    
    init(skScene: SKScene, seed: UInt32) {
        // Create PerlinNoiseObject used to generate chunks for this map
        perlinNoiseObject = GKNoise(GKPerlinNoiseSource(frequency: 0.15, octaveCount: 3, persistence: 2, lacunarity: 0.9, seed: Int32(seed)))
        
        // Load 9 chunks at the start
        level.append(Chunk(position: CGPoint(x: 0.0, y: 0.0), skScene: skScene, collectibleManager: collectibleManager, perlinNoiseObject: perlinNoiseObject!))
        
        let adjacentChunks = GetAdjacentPositions(point: CGPoint(x: 0, y: 0), displacement: Double(GameData.ChunkPixelSize))
        
        for position in adjacentChunks {
            level.append(Chunk(position: position, skScene: skScene, collectibleManager: collectibleManager, perlinNoiseObject: perlinNoiseObject!))
            
        }
    }
    
    // Calls CheckCollisionsInChunk for necesarry chunks
    func CheckPlayerCollisions(player: Player) {
        // Check collisions in current chunk
        let currentChunk: Chunk = ChunkContainsPoint(point: player.position)
        
        CheckCollisionsInChunk(currentChunk: currentChunk, player: player)
        
        // Check collisions in adjecent chunnks (for edge cases)
        let adjacentPoints = GetAdjacentPositions(point: player.position, displacement: Double(GameData.ChunkPixelSize))
        
        for point in adjacentPoints {
            let adjacentChunk = ChunkContainsPoint(point: point)
            
            CheckCollisionsInChunk(currentChunk: adjacentChunk, player: player)

        }
    }

    // Currently checks collisions between player and tiles in given chunk
    func CheckCollisionsInChunk(currentChunk: Chunk, player: Player) {
        for i in 0...GameData.ChunkTileWidth - 1 {
            for j in 0...GameData.ChunkTileWidth - 1 {
                // Is the tile close enough to the player to care about
                let tilePosition = currentChunk.tiles[i][j].tilePosition
                
                let xDifference = Float(tilePosition.x - player.position.x)
                let yDifference = Float(tilePosition.y - player.position.y)
                
                let magnitudeSquared = powf(xDifference, 2) + powf(yDifference, 2)
                
                if magnitudeSquared < powf((GameData.TilePixelSize * 2), 2) {
                    
                    if !currentChunk.tiles[i][j].pathable {
                        // Find the direction towards center of tile and closest distance to the center of the tile
                        // from the closest point on the colliding circle
                        let magnitude = sqrt(magnitudeSquared)
                        
                        let xDirection = (xDifference / magnitude)
                        let yDirection = (yDifference / magnitude)
                        
                        let closestX = CGFloat(xDirection * player.collisionRadius)
                        let closestY = CGFloat(yDirection * player.collisionRadius)
                        
                        let closestPlayerPosition = player.position + CGPoint(x: closestX, y: closestY)
                        let halfTile = CGFloat(GameData.TilePixelSize / 2)
                        
                        // Displace the character depending on relative position to the colliding tile
                        if (closestPlayerPosition.x < tilePosition.x + halfTile &&
                            closestPlayerPosition.x > tilePosition.x - halfTile &&
                            closestPlayerPosition.y < tilePosition.y + halfTile &&
                            closestPlayerPosition.y > tilePosition.y - halfTile) {
                            if abs(closestX) > abs(closestY) {
                                let xDisplacement =  abs(currentChunk.tiles[i][j].tilePosition.x) - abs(closestPlayerPosition.x)
                                let absXDisplacement = CGFloat(GameData.TilePixelSize) / 2 - abs(xDisplacement)
                                player.position.x += absXDisplacement * CGFloat(-xDirection)
                            }
                            else {
                                let yDisplacement = abs(currentChunk.tiles[i][j].tilePosition.y) - abs(closestPlayerPosition.y)
                                let absYDisplacement = CGFloat(GameData.TilePixelSize) / 2 - abs(yDisplacement)
                                player.position.y += absYDisplacement * CGFloat(-yDirection)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Create adjacent chunks if they do not exist and remove extra chunks
    func UpdateLevel(point: CGPoint, skScene: SKScene) {
        let currentChunk: Chunk = ChunkContainsPoint(point: point)
        let adjacentPoints = GetAdjacentPositions(point: currentChunk.position, displacement: Double(GameData.ChunkPixelSize))
        
        // Find the chunks to be removed
        // Remove their node from the scene
        // Remove chunk from level array
        var currentChunkIndex = 0
        for chunk in level {
            if !adjacentPoints.contains(chunk.position) && chunk.position != currentChunk.position {
                chunk.chunkNode.removeFromParent()
                level.remove(at: currentChunkIndex)
            }
            else {
                currentChunkIndex += 1
            }
        }
        
        // Create missing chunks
        for point in adjacentPoints {
            if !ChunkExists(point: point) {
                level.append(Chunk(position: point, skScene: skScene, collectibleManager: collectibleManager, perlinNoiseObject: perlinNoiseObject!))
            }
        }
    }
    
    // Originally tried to remove chunks in the background, but ran into some issues
    // You can ONLY update SKNodes on the main thread
//    func RemoveChunksBackground(chunkTileWidth: Int) {
//    }
    
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
                if point.x > ((tile.tilePosition.x - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.x < (tile.tilePosition.x + CGFloat(GameData.ChunkPixelSize) / 2)) {
                    if point.y > ((tile.tilePosition.y - CGFloat(GameData.ChunkPixelSize) / 2)) && (point.y < (tile.tilePosition.y + CGFloat(GameData.ChunkPixelSize) / 2)) {
                        return tile
                    }
                }
            }
        }
        
        return nil
    }
    
    func GetAdjacentTiles(currentTile: Tile) {
        
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
    
    // Is this given point "near" the center of the given chunk
    func IsDistantFromCurrentChunk(currentChunk: Chunk, position: CGPoint) -> Bool {
        let xDifference = abs(Float(currentChunk.position.x - position.x))
        let yDifference = abs(Float(currentChunk.position.y - position.y))
        
        let MaxDistance = GameData.TilePixelSize * Float(((GameData.ChunkTileWidth / 2) + 4))
        
        if (xDifference > MaxDistance) {
            return true
        }
        
        else if (yDifference > MaxDistance) {
            return true
        }
        
        return false
    }
}

// Chunk that contains tiles based on the number of tiles per chunk
class Chunk {
    let chunkNode: SKNode
    
    var position: CGPoint
    var tiles = Array(repeating: Array(repeating: Tile(), count: GameData.ChunkTileWidth), count: GameData.ChunkTileWidth)
    
    var perlinNoiseMap: GKNoiseMap
    
    var isUpdating: Bool
    
    init(position: CGPoint, skScene: SKScene, collectibleManager: CollectibleManager, perlinNoiseObject: GKNoise) {
        self.position = position
        
        self.chunkNode = SKNode()
        self.chunkNode.position = self.position
        
        let leftSide = Float(position.x) - GameData.ChunkPixelSize / 2
        let bottomSide = Float(position.y) - GameData.ChunkPixelSize / 2
        
        self.perlinNoiseMap = GKNoiseMap(perlinNoiseObject,
                                         size: vector_double2(Double(GameData.ChunkTileWidth), Double(GameData.ChunkTileWidth)),
                                         origin: vector_double2(Double(leftSide / GameData.TilePixelSize), Double(bottomSide / GameData.TilePixelSize)), // Origin is the "bottom left" of the noise map
                                         sampleCount: vector_int2(50, 50),
                                         seamless: true)
        
        for i in 0 ..< GameData.ChunkTileWidth {
            for j in 0 ..< GameData.ChunkTileWidth {
                
                let noiseValue = perlinNoiseMap.value(at: vector_int2(Int32(i), Int32(j)))

                var tilePosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
                tilePosition.x = CGFloat((Float(i) * GameData.TilePixelSize) - (GameData.ChunkPixelSize / 2))
                tilePosition.y = CGFloat((Float(j) * GameData.TilePixelSize) - (GameData.ChunkPixelSize / 2))
                
                self.tiles[i][j] = Tile(chunkParentNode: self.chunkNode, noiseValue: noiseValue, position: tilePosition, collectibleManager: collectibleManager)
            }
        }
        
        skScene.addChild(chunkNode)
        
        self.isUpdating = false
    }
}

// Contains information about each unique tile.
// Information is created when initialized based on the given type.
struct Tile {
    var tileSpriteNode: SKSpriteNode
    var pathable: Bool
    var type: String = "Grass"
    var tilePosition: CGPoint
    
    // Default constructor (used to initialize arrays, etc...)
    init () {
        self.tileSpriteNode = SKSpriteNode(texture: GameData.BackgroundTextures[0])
        self.pathable = true
        self.tilePosition = CGPoint(x: 0, y: 0)
    }
    
    init (chunkParentNode: SKNode, noiseValue: Float, position: CGPoint, collectibleManager: CollectibleManager) {
        // Tile for grass
        if noiseValue < -0.1 {
            self.tileSpriteNode = SKSpriteNode(texture: GameData.BackgroundTextures[0])
            pathable = true
        }
            
        // Tile for grassOne
        else if noiseValue >= -0.1 && noiseValue < 0.35{
            self.tileSpriteNode = SKSpriteNode(texture: GameData.BackgroundTextures[1])
            pathable = true
        }
            
        // Tile for grassTwo
        else if noiseValue >= 0.35 && noiseValue < 0.7 {
            self.tileSpriteNode = SKSpriteNode(texture: GameData.BackgroundTextures[2])
            pathable = true
            
            // Adds collectible gold coin on this tile
            if noiseValue >= 0.55 && noiseValue < 0.6 {
                collectibleManager.CreateNewCollectible(type: "GoldCoin", position: position, parentNode: chunkParentNode)
            }
        }
            
        // Tile for impassable rock tile
        else if noiseValue >= 0.7 {
            self.tileSpriteNode = SKSpriteNode(texture: GameData.RockTextures[0])
            pathable = false
        }
        
        // Default tile is grass
        else {
            self.tileSpriteNode = SKSpriteNode(texture: GameData.BackgroundTextures[0])
            pathable = true
        }
        
        // Initialize node data       
        self.tileSpriteNode.scale(to: CGSize(width: CGFloat(GameData.TilePixelSize), height: CGFloat(GameData.TilePixelSize)))
        self.tileSpriteNode.position = position
        self.tileSpriteNode.zPosition = 0.1
        chunkParentNode.addChild(self.tileSpriteNode)
        
        self.tilePosition = position + chunkParentNode.position
    }
}
