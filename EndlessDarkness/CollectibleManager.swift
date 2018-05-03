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
    
    func CreateNewCollectible(type: String, position: CGPoint, parentNode: SKNode) {
        collectibles.append(Collectible(type: type, position: position, parentNode: parentNode, index: collectibles.count))
    }
    
    func CheckCollisions(playerSprite: SKSpriteNode, player: Player) {
        if collectibles.count > 0 {
            for i in 0 ..< collectibles.count {
                let xDifference = Float(collectibles[i].itemPosition.x - player.position.x)
                let yDifference = Float(collectibles[i].itemPosition.y - player.position.y)
                
                let magnitudeSquared = powf(xDifference, 2) + powf(yDifference, 2)
                
                if magnitudeSquared < powf((player.collisionRadius + collectibles[i].collisionRadius), 2) {
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

class Collectible {
    var type: String
    var node: SKSpriteNode?
    var animation: Animation?
    var index: Int
    var collisionRadius: Float
    var itemPosition: CGPoint
    
    init (type: String, position: CGPoint, parentNode: SKNode, index: Int) {
        switch type {
        case "GoldCoin":
            self.type = "GoldCoin"
            self.animation = Animation(animatedAtlasName: "GoldCoinAnimation", position: position, parentNode: parentNode)
            self.node = (self.animation?.animationNode)!
            self.index = index
            collisionRadius = 5 * GameData.GlobalScale
            self.itemPosition = position + parentNode.position
            
        default:
            self.type = "Collectible Init Error"
            self.animation = nil
            self.node = nil
            self.index = index
            self.itemPosition = position + parentNode.position
            collisionRadius = 5 * GameData.GlobalScale
        }
    }
}

