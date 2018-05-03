//
//  EnemyManager.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 5/3/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import UIKit
import SpriteKit

class EnemyManager {
    var Enemies = [Enemy]()
    var spawnTimer: Float = 0
    var spawnDelay: Float = 5
    
    func spawnEnemies(deltaTime: Float, playerPosition: CGPoint, skScene: SKScene) {
        spawnTimer += Float(deltaTime)
        let spawnX = Float(arc4random_uniform(2000)) - Float(4000) * GameData.GlobalScale + Float(playerPosition.x)
        let spawnY = Float(arc4random_uniform(2000)) - Float(4000) * GameData.GlobalScale + Float(playerPosition.y)
        
        let spawnPoint = CGPoint(x: CGFloat(spawnX), y: CGFloat(spawnY))
        
        if spawnTimer >= spawnDelay {
            Enemies.append(Enemy(position: spawnPoint, health: 50, speed: 100, collisionRadius: 10, damage: 5, direction: CGPoint(x: 0, y: 0), size: 50, skScene: skScene))
        }
    }
    
    
    func updateEnemies(playerPosition: CGPoint, deltaTime: Float, otherCollisionRadius: Float) {
        for enemy in Enemies {
            enemy.update(playerPosition: playerPosition, deltaTime: deltaTime, otherCollisionRadius: Float(otherCollisionRadius))
        }
    }
}

class Enemy {
    var enemyNode: SKSpriteNode
    
    var particleEmitter: Emitter
    
    var position: CGPoint
    var health: Float
    var speed: Float
    var collisionRadius: Float
    var damage: Float
    var direction: CGPoint
    var size: Float
    
    init(position: CGPoint, health: Float, speed: Float, collisionRadius: Float, damage: Float, direction: CGPoint, size: Float, skScene: SKScene) {
        self.enemyNode = SKSpriteNode(texture: GameData.EnemyTexture)
        
        self.particleEmitter = Emitter(type: "EnemyParticle", lifeTime: 0.8, spawnRate: 0.08, maxParticles: 30, position: position, sizeInitial: 1.0, sizeFinal: 0.8, speedInitial: 0.1, speedFinal: 0.1, alphaInitial: 0.8, alphaFinal: 0.1, skScene: skScene)
        self.position = position
        self.health = health
        self.speed = speed * GameData.GlobalScale
        self.collisionRadius = collisionRadius * GameData.GlobalScale
        self.damage = damage
        self.direction = direction
        self.size = size * GameData.GlobalScale
        
        self.enemyNode.position = self.position
        self.enemyNode.setScale(CGFloat(self.size))
    }
    
    func update(playerPosition: CGPoint, deltaTime: Float, otherCollisionRadius: Float) {
        self.direction.x = playerPosition.x - self.position.x
        self.direction.y = playerPosition.y - self.position.y
        
        let magnitude = sqrt(powf(Float(direction.x), 2) + powf(Float(direction.y), 2))
        
        
        let xDisplacement = (Float(direction.x) / magnitude) * self.speed * deltaTime
        let yDisplacement = (Float(direction.y) / magnitude) * self.speed * deltaTime
            
        position.x += CGFloat(xDisplacement)
        position.y -= CGFloat(yDisplacement)
        
        if magnitude < (otherCollisionRadius + self.collisionRadius) {
            self.destroy()
        }
        
    }
    
    func dealDamage(damageAmount: Float) {
        self.health -= damageAmount
        if self.health <= 0 {
            self.destroy()
        }
    }
    
    func destroy() {
        self.particleEmitter.deleteEmitter()
    }
}
