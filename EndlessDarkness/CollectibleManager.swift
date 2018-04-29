//
//  CollectibleManager.swift
//  EndlessDarkness
//
//  Created by Student on 4/19/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CollectibleManager {
    var collectibles: [Collectible]
    
    init() {
        self.collectibles = [Collectible]()
    }
    
    func CreateNewCollectible(type: String, position: CGPoint, skScene: SKScene) {
        collectibles.append(Collectible(type: type, position: position, skScene: skScene, index: collectibles.count))
    }
    
    func CheckCollisions(playerSprite: SKSpriteNode, player: Player) {
        if collectibles.count > 0 {
            for i in 0...collectibles.count - 1 {
                if (playerSprite.intersects(collectibles[i].node!)) {
                    self.CollideWithCollectible(type: collectibles[i].type, player: player, index: i)
                    return
                }
            }
        }
    }
    
    func CollideWithCollectible(type: String, player: Player, index: Int) {
        switch type {
        case "GoldCoin":
            player.money += 1
            RemoveCollectible(removeAtIndex: index)
            
        default:
            return
        }
    }
    
    func RemoveCollectible(removeAtIndex: Int) {
        for i in removeAtIndex + 1...self.collectibles.count - 1 {
            collectibles[i].index -= 1
        }
        
        collectibles[removeAtIndex].node?.removeFromParent()
        collectibles.remove(at: removeAtIndex)
    }
}

struct Collectible {
    var type: String
    var node: SKSpriteNode?
    var animation: Animation?
    var index: Int

    init (type: String, position: CGPoint, skScene: SKScene, index: Int) {
        switch type {
        case "GoldCoin":
            self.type = "GoldCoin"
            self.animation = Animation(animatedAtlasName: "GoldCoinAnimation", position: position, skScene: skScene)
            self.node = (self.animation?.animationNode)!
            self.index = index
            
        default:
            self.type = "Collectible Init Error"
            self.animation = nil
            self.node = nil
            self.index = index
        }
    }
}

