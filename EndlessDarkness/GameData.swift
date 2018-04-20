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
    static var ChunkSize: Float = 1024 // number of pixels per side
    static var TileSize: Float = 64 // number of pixels per tile side
    static var TilesPerChunk: Int = 16 // tiles per chunk along one dimension
    
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
