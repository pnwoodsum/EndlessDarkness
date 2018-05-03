//
//  ParticleManager.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 5/3/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import UIKit
import SpriteKit

class Emitter {
    var type: String
    let lifeTime: Float
    let spawnRate: Float
    let maxParticles: Int
    var position: CGPoint
    var sizeInitial: Float
    var sizeFinal: Float
    var speedInitial: Float
    var speedFinal: Float
    var alphaInitial: Float
    var alphaFinal: Float
    
    var spawnTimer: Float = 0
    var isEmitting: Bool = false
    var particles: [Particle]
    
    var currentParticleIndex: Int = 0
    
    init(type: String,
         lifeTime: Float,
         spawnRate: Float,
         maxParticles: Int,
         position: CGPoint,
         sizeInitial: Float,
         sizeFinal: Float,
         speedInitial: Float,
         speedFinal: Float,
         alphaInitial: Float,
         alphaFinal: Float,
         skScene: SKScene) {
        self.type = type
        self.lifeTime = lifeTime
        self.spawnRate = spawnRate
        self.maxParticles = maxParticles
        self.position = position
        self.sizeInitial = sizeInitial
        self.sizeFinal = sizeFinal
        self.speedInitial = speedInitial
        self.speedFinal = speedFinal
        self.alphaInitial = alphaInitial
        self.alphaFinal = alphaFinal
        
        self.speedInitial *= GameData.GlobalScale
        self.speedFinal *= GameData.GlobalScale
        
        particles = [Particle]()
        for _ in 0 ..< maxParticles {
            let randomDegree = arc4random_uniform(360) + 1
            let xDirection = sin((Float(randomDegree) * .pi) / 180)
            let yDirection = cos((Float(randomDegree) * .pi) / 180)
            let startingDirection = CGPoint(x: CGFloat(xDirection), y: CGFloat(yDirection))
            particles.append(Particle(particleType: "Fire", lifeTime: self.lifeTime, position: self.position, speed: self.speedInitial, direction: startingDirection, sizeInitial: CGFloat(self.sizeInitial), alphaInitial: self.alphaInitial, alphaFinal: self.alphaFinal, skScene: skScene))
        }
    }
    
    convenience init(position: CGPoint, skScene: SKScene) {
        self.init(type: "Circle", lifeTime: 0.8, spawnRate: 0.08, maxParticles: 30, position: position, sizeInitial: 1.0, sizeFinal: 0.8, speedInitial: 0.1, speedFinal: 0.1, alphaInitial: 0.8, alphaFinal: 0.1, skScene: skScene)
    }
    
    func activateParticle(currentPosition: CGPoint) {
        let currentParticle = particles[currentParticleIndex]
        if (currentParticle.isAlive) {
            currentParticle.deactivate()
        }
        currentParticle.activate(position: currentPosition)
        currentParticleIndex += 1
        if currentParticleIndex >= maxParticles {
            currentParticleIndex = 0
        }
    }
    
    func updateEmitter(deltaTime: Float, currentPosition: CGPoint) {
        if isEmitting {
            spawnTimer += deltaTime
            if spawnTimer >= spawnRate {
                activateParticle(currentPosition: currentPosition)
                self.spawnTimer = 0
            }
        }
        for currentParticle in particles {
            if currentParticle.isAlive {
                currentParticle.update(deltaTime: deltaTime)
            }
        }
    }
    
    func startEmitting() {
        isEmitting = true
        spawnTimer = 0
    }
    
    func stopEmitting() {
        isEmitting = false
    }
    
    func deleteEmitter() {
        for currentParticle in particles {
            currentParticle.particleSpriteNode.removeFromParent()
        }
    }
}

class Particle {
    
    var age: Float
    var isAlive: Bool
    
    var lifeTime: Float
    var position: CGPoint
    var speed: Float
    var direction: CGPoint
    var alphaInitial: Float
    var alphaFinal: Float
    var particleSpriteNode: SKSpriteNode

    init(particleType: String, lifeTime: Float, position: CGPoint, speed: Float, direction: CGPoint, sizeInitial: CGFloat, alphaInitial: Float, alphaFinal: Float, skScene: SKScene) {
        
        age = 0
        isAlive = false
        
        self.lifeTime = lifeTime
        self.position = position
        self.speed = speed
        self.direction = direction
        self.alphaInitial = alphaInitial
        self.alphaFinal = alphaFinal
        
        switch particleType {
        case "Fire":
            self.particleSpriteNode = SKSpriteNode(texture: GameData.FireTexture)
            self.particleSpriteNode.zPosition = 1.0
            self.particleSpriteNode.position = self.position
            self.particleSpriteNode.alpha = CGFloat(alphaInitial)
            self.particleSpriteNode.isHidden = true
            self.particleSpriteNode.setScale(sizeInitial * CGFloat(GameData.GlobalScale))
            skScene.addChild(self.particleSpriteNode)
        default:
            self.particleSpriteNode = SKSpriteNode(texture: GameData.FireTexture)
            self.particleSpriteNode.zPosition = 1.0
            self.particleSpriteNode.position = self.position
            self.particleSpriteNode.alpha = CGFloat(alphaInitial)
            self.particleSpriteNode.isHidden = true
            self.particleSpriteNode.setScale(sizeInitial * CGFloat(GameData.GlobalScale))
            skScene.addChild(self.particleSpriteNode)
        }
    }
    
    func activate(position: CGPoint) {
        self.age = 0
        self.position = position
        self.isAlive = true
        self.particleSpriteNode.isHidden = false
    }
    
    func deactivate() {
        self.isAlive = false
        self.particleSpriteNode.isHidden = true
    }
    
    func update(deltaTime: Float) {
        self.age += deltaTime
        if self.age >= self.lifeTime {
            self.deactivate()
            return
        }
        
        self.position.x += CGFloat(self.speed) * direction.x
        self.position.y += CGFloat(self.speed) * direction.y
        
        let currentAlpha = alphaInitial - ((age / lifeTime) * alphaInitial - alphaFinal)
        
        self.particleSpriteNode.position = self.position
        self.particleSpriteNode.alpha = CGFloat(currentAlpha)
    }
}
