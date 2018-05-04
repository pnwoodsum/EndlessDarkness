//
//  SpellManager.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 5/3/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import UIKit
import SpriteKit

class SpellManager {
    var fireballCharging = false
    
    var fireball: Fireball = Fireball()

    var fireballChargingEmitter: Emitter
    var fireballMovingEmitter: Emitter
    var fireballExplosionEmitter: Emitter
    
    init(skScene: SKScene) {
        fireballChargingEmitter = Emitter(position: CGPoint(x: 0.0, y: 0.0), skScene: skScene)
        fireballMovingEmitter = Emitter(type: "Fire", lifeTime: 0.4, spawnRate: 0.01, maxParticles: 30, position: CGPoint(x: 0.0, y: 0.0), sizeInitial: 1.8, sizeFinal: 2.4, speedInitial: 0.3, speedFinal: 0.14, alphaInitial: 0.8, alphaFinal: 0.1, skScene: skScene)
        fireballExplosionEmitter = Emitter(type: "Fire", lifeTime: 0.2, spawnRate: 0.01, maxParticles: 50, position: CGPoint(x: 0.0, y: 0.0), sizeInitial: 10.0, sizeFinal: 10.0, speedInitial: 7.0, speedFinal: 0.7, alphaInitial: 0.9, alphaFinal: 0.4, skScene: skScene)
    }
    
    func update(deltaTime: Float, position: CGPoint, enemyList: [Enemy]) {
        
        fireball.update(deltaTime: deltaTime, enemyList: enemyList)
        
        fireballChargingEmitter.isEmitting = false
        fireballMovingEmitter.isEmitting = false
        fireballExplosionEmitter.isEmitting = false

        
        if fireballCharging {
            fireballChargingEmitter.isEmitting = true
        }
        if fireball.moving {
            fireballMovingEmitter.isEmitting = true
        }
        else if fireball.exploding {
            fireballExplosionEmitter.isEmitting = true
        }
        
        fireballChargingEmitter.updateEmitter(deltaTime: deltaTime, currentPosition: position)
        fireballMovingEmitter.updateEmitter(deltaTime: deltaTime, currentPosition: fireball.position)
        fireballExplosionEmitter.updateEmitter(deltaTime: deltaTime, currentPosition: fireball.explosionPosition)
    }
    
    func throwFireball(position: CGPoint, direction: CGPoint) {
        fireball.ready = false
        fireball.moving = true
        fireball.direction = direction
        fireball.position = position
    }
}

class Fireball {
    var position: CGPoint
    var speed: Float
    var direction: CGPoint
    var size: Float
    var damage: Float
    var effectRadius: Float
    var moving = false
    var exploding = false
    var ready = true
    var maxRange: Float
    var distanceMoved: Float = 0
    var explosionTimer: Float = 0
    var explosionDuration: Float = 0.6
    var explosionPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    init(position: CGPoint, speed: Float, direction: CGPoint, size: Float, damage: Float, effectRadius: Float, maxRange: Float) {
        self.position = position
        self.speed = speed
        self.direction = direction
        self.size = size
        self.damage = damage
        self.effectRadius = effectRadius * GameData.GlobalScale
        self.size = size * GameData.GlobalScale
        self.speed = speed * GameData.GlobalScale
        self.maxRange = maxRange * GameData.GlobalScale
    }
    
    convenience init() {
        self.init(position: CGPoint(x: 0.0, y: 0.0), speed: 600.0, direction: CGPoint(x: 0.0, y: 0.0), size: 10.0, damage: 50.0, effectRadius: 100.0, maxRange: 300.0)
    }
    
    func update(deltaTime: Float, enemyList: [Enemy]) {
        if moving {
            let magnitude = sqrt(powf(Float(direction.x), 2) + powf(Float(direction.y), 2))
            
            let xDisplacement = (Float(direction.x) / magnitude) * self.speed * deltaTime
            let yDisplacement = (Float(direction.y) / magnitude) * self.speed * deltaTime
            
            self.position.x += CGFloat(xDisplacement)
            self.position.y -= CGFloat(yDisplacement)
            
            distanceMoved += speed * deltaTime
            
            if self.distanceMoved >= self.maxRange {
                self.moving = false
                self.exploding = true
                self.explosionTimer = 0
                self.distanceMoved = 0
                self.explosionPosition = self.position
                // TODO: Apply damage in effect radius now
                for enemy in enemyList {
                    self.direction.x = enemy.position.x - self.position.x
                    self.direction.y = enemy.position.y - self.position.y
                    
                    let magnitude = sqrt(powf(Float(direction.x), 2) + powf(Float(direction.y), 2))
                    
                    if magnitude < (self.effectRadius + enemy.collisionRadius) {
                        enemy.dealDamage(damageAmount: self.damage)
                    }
                }
            }
        }
        else if exploding {
            self.explosionTimer += deltaTime
            if self.explosionTimer >= self.explosionDuration {
                exploding = false
                self.ready = true
            }
        }
    }
}
