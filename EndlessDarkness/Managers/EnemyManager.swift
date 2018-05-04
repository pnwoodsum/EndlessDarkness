//
//  EnemyManager.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 5/3/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import UIKit
import SpriteKit

// Has reference to a list of enemies
class EnemyManager {
    var Enemies = [Enemy]()
    var spawnTimer: Float = 2
    var spawnDelay: Float = 5
    var maxEnemies: Int = 10
    
    func spawnEnemies(deltaTime: Float, playerPosition: CGPoint, skScene: SKScene) {
        spawnTimer += Float(deltaTime)
        
        if spawnTimer >= spawnDelay && Enemies.count <= self.maxEnemies {
            let spawnX = Float(arc4random_uniform(2000)) - Float(1000) * GameData.GlobalScale + Float(playerPosition.x)
            let spawnY = Float(arc4random_uniform(2000)) - Float(1000) * GameData.GlobalScale + Float(playerPosition.y)
            
            let spawnPoint = CGPoint(x: CGFloat(spawnX), y: CGFloat(spawnY))
            
            Enemies.append(Enemy(position: spawnPoint, health: 50, speed: 120, collisionRadius: 15, damage: 5, direction: CGPoint(x: 0, y: 0), size: 3, skScene: skScene))
            spawnTimer = 0
        }
    }
    
    func updateEnemies(playerPosition: CGPoint, deltaTime: Float, otherCollisionRadius: Float) {
        var currentIndex = 0
        for enemy in Enemies {
            enemy.update(playerPosition: playerPosition, deltaTime: deltaTime, otherCollisionRadius: Float(otherCollisionRadius))

            if enemy.isDead {
                Enemies.remove(at: currentIndex)
            }
            else {
                currentIndex += 1
            }
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
    
    var isDead = false
    
    init(position: CGPoint, health: Float, speed: Float, collisionRadius: Float, damage: Float, direction: CGPoint, size: Float, skScene: SKScene) {
        self.enemyNode = SKSpriteNode(texture: GameData.EnemyTexture)
        
        self.particleEmitter = Emitter(type: "EnemyParticle", lifeTime: 0.8, spawnRate: 0.08, maxParticles: 15, position: position, sizeInitial: size, sizeFinal: size, speedInitial: size, speedFinal: 0.1, alphaInitial: 0.8, alphaFinal: 0.1, skScene: skScene)
        self.particleEmitter.isEmitting = true

        self.position = position
        self.health = health
        self.speed = speed * GameData.GlobalScale
        self.collisionRadius = collisionRadius * GameData.GlobalScale * size
        self.damage = damage
        self.direction = direction
        self.size = size * GameData.GlobalScale
        
        self.enemyNode.position = self.position
        self.enemyNode.setScale(CGFloat(self.size))
        self.enemyNode.zPosition = 0.99
        skScene.addChild(self.enemyNode)
    }
    
    func update(playerPosition: CGPoint, deltaTime: Float, otherCollisionRadius: Float) {
        self.direction.x = playerPosition.x - self.position.x
        self.direction.y = playerPosition.y - self.position.y
        
        let magnitude = sqrt(powf(Float(direction.x), 2) + powf(Float(direction.y), 2))
        
        let xDisplacement = (Float(direction.x) / magnitude) * self.speed * deltaTime
        let yDisplacement = (Float(direction.y) / magnitude) * self.speed * deltaTime
            
        position.x += CGFloat(xDisplacement)
        position.y += CGFloat(yDisplacement)
        
        if magnitude < (otherCollisionRadius + self.collisionRadius) {
            self.destroy()
        }
        
        self.enemyNode.zRotation = CGFloat(atan2f(Float(self.direction.y), Float(self.direction.x)) - .pi / 2)
        
        self.enemyNode.position = self.position
        
        self.particleEmitter.updateEmitter(deltaTime: deltaTime, currentPosition: self.position)
    }
    
    func dealDamage(damageAmount: Float) {
        self.health -= damageAmount
        if self.health <= 0 {
            self.destroy()
        }
    }
    
    func destroy() {
        self.particleEmitter.deleteEmitter()
        self.isDead = true
        self.enemyNode.removeFromParent()
    }
}
