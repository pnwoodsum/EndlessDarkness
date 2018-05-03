//
//  AnimationManager.swift
//  EndlessDarkness
//
//  Created by Student on 4/19/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import Foundation
import SpriteKit

class Animation {
    var animationNode: SKSpriteNode
    var animationFrames: [SKTexture] = []
    
    init (animatedAtlasName: String, position: CGPoint, parentNode: SKNode) {
        
        let animatedAtlas = SKTextureAtlas(named: animatedAtlasName)
        
        let numberOfImages = animatedAtlas.textureNames.count
        
        for i in 1...numberOfImages {
            let currentTextureName = "goldCoin\(i)"
            self.animationFrames.append(animatedAtlas.textureNamed(currentTextureName))
        }
        
        let firstFrameTexture = self.animationFrames[0]
        
        self.animationNode = SKSpriteNode(texture: firstFrameTexture)
        self.animationNode.setScale(CGFloat(GameData.GlobalScale))
        self.animationNode.position = position
        self.animationNode.zPosition = 0.7
        parentNode.addChild(self.animationNode)
        
        self.animate()
    }
    
    func animate() {
        animationNode.run(SKAction.repeatForever(SKAction.animate(with: self.animationFrames, timePerFrame: 0.1, resize: false, restore: true)))
    }
}
