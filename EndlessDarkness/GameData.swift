//
//  GameData.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 4/16/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import Foundation
import SpriteKit

struct GameData {
    static var GlobalScale: Float = 0.65
    
    
    static var TilePixelSize: Float = 64 * GameData.GlobalScale // number of pixels per tile side
    static var ChunkTileWidth: Int = 32 // tiles per chunk along one dimension
    static var ChunkPixelSize: Float = Float(GameData.ChunkTileWidth) * GameData.TilePixelSize // number of pixels per side of chunk
    
    
    static var FireTexture = SKTexture(imageNamed: "fire0.png")
//    static var FireTextures: [SKTexture] = [
//        SKTexture(imageNamed: "fire0.png")
//    ]
    
    static var BackgroundTextures: [SKTexture] = [
        SKTexture(imageNamed: "grass.png"),
        SKTexture(imageNamed: "grassPlantsOne.png"),
        SKTexture(imageNamed: "grassPlantsTwo.png")
    ]
    
    static var RockTextures: [SKTexture] = [
        SKTexture(imageNamed: "rockOne.png")
    ]
}

// Define the addition of two CGPoints for the esake of convenience
func +(leftHandSide: CGPoint, rightHandSide: CGPoint) -> CGPoint {
    return CGPoint(x: leftHandSide.x + rightHandSide.x, y: leftHandSide.y + rightHandSide.y)
}

// Define the subtraction of two CGPoints for the esake of convenience
func -(leftHandSide: CGPoint, rightHandSide: CGPoint) -> CGPoint {
    return CGPoint(x: leftHandSide.x - rightHandSide.x, y: leftHandSide.y - rightHandSide.y)
}
