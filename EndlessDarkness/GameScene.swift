//
//  GameScene.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 4/9/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var lastUpdateTimeInterval: TimeInterval = 0
    
    var levelManager: LevelManager?
    var collectibleManager: CollectibleManager?
    
    var joystick: Bool = false
    var joyStickInitialPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var joyStickCurrentPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var joyStickPreviousPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    var playerViewPosition: CGPoint?
    
    var player = Player()
    var skCamera: SKCameraNode?
    
    let playerSprite = SKSpriteNode(imageNamed: "playerUp.png")
    
    let positionLabel = SKLabelNode(text: "Position: " )
    let goldLabel = SKLabelNode(text: "Gold: ")
    
    var currentSeed: UInt32 = 0
    
    // Used to initialize node positions, attributes etc...
    override func didMove(to view: SKView) {
        
        self.levelManager = LevelManager(skScene: self, seed: currentSeed)
        
        // Initialize player sprite and class
        playerSprite.zPosition = 0.9
        playerSprite.position = CGPoint(x: 0.0, y: 0.0)
        player.position = playerSprite.position
        playerSprite.setScale(CGFloat(GameData.GlobalScale))
        self.addChild(playerSprite)
        
        // Initialize camera
        skCamera = SKCameraNode()
        self.camera = skCamera
        self.addChild(skCamera!)
        
        // Initialize UI elements
        positionLabel.zPosition = 1.0
        positionLabel.position = CGPoint(x: 10.0, y: 20.0)
        positionLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        positionLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        skCamera?.addChild(positionLabel)
        
        goldLabel.zPosition = 1.0
        goldLabel.position = CGPoint(x: 10.0, y: 100.0)
        goldLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        goldLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        skCamera?.addChild(goldLabel)
        
        if let tempChunk = levelManager?.ChunkContainsPoint(point: player.position) {
            player.currentChunk = (tempChunk)
            player.previousChunk = player.currentChunk
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let deltaTime: TimeInterval = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        playerViewPosition = convertPoint(toView: player.position)
        
        playerSprite.position = player.position
        
        skCamera?.position = player.position
        
        positionLabel.position = CGPoint(x: 10 - (view?.frame.width)! / 2, y: -20 + (view?.frame.height)! / 2)
        positionLabel.text = "Position: (\(Int(player.position.x)), \(Int(player.position.y)))"
        
        goldLabel.position = CGPoint(x: 10 - (view?.frame.width)! / 2, y: -100 + (view?.frame.height)! / 2)
        goldLabel.text = "Gold: (\(player.money))"
        
        playerSprite.position = player.position
        
        skCamera?.position = player.position
        
        // Handles movement and collisions
        if joystick {
            let xDifference = Float(joyStickCurrentPosition.x - joyStickInitialPosition.x)
            let yDifference = Float(joyStickCurrentPosition.y - joyStickInitialPosition.y)
            
            let magnitude = sqrt(powf(xDifference, 2) + powf(yDifference, 2))
            
            if magnitude > 20.0 {
                let xDisplacement = CGFloat((xDifference / magnitude) * 20)
                joyStickInitialPosition.x = joyStickCurrentPosition.x - xDisplacement
                let yDisplacement = CGFloat((yDifference / magnitude) * 20)
                joyStickInitialPosition.y = joyStickCurrentPosition.y - yDisplacement
            }
            
            playerSprite.zRotation = CGFloat(atan2f(-xDifference, -yDifference))
            
            player.move(xDirection: xDifference, yDirection: yDifference, deltaTime: Float(deltaTime))
            
            // Check for player collisions with the tiles of the current chunks
            levelManager?.CheckPlayerCollisions(player: player)
            
            // Update the level only when the player has moved far enough from the center of the current chunk
            // The current chunk represents the the previous chunk where update level was called
            if (levelManager?.IsDistantFromCurrentChunk(currentChunk: player.currentChunk, position: player.position))! {
                levelManager?.UpdateLevel(point: player.position, skScene: self)
                
                if let tempChunk = levelManager?.ChunkContainsPoint(point: player.position) {
                    player.previousChunk = player.currentChunk
                    player.currentChunk = (tempChunk)
                }
            }
            
        }
        
        // Check player collisions with collectibles
        self.levelManager?.collectibleManager.CheckCollisions(playerSprite: playerSprite, player: player)
    }
    
    // helper function to generate a new seed
    func generateSeed() {
        currentSeed = UInt32(NSDate().timeIntervalSinceReferenceDate)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches) {
            
            let position = touch.location(in: view)
            
            if (position.x < self.frame.width / 2) {
                joyStickInitialPosition = position
                joyStickPreviousPosition = position
                joyStickCurrentPosition = position
                joystick = true
            }
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in (touches) {
            
            let position = touch.location(in: view)
            
            if (position.x < self.frame.width / 2) {
                joystick = true
                
                joyStickPreviousPosition = joyStickCurrentPosition
                
                joyStickCurrentPosition = position
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches) {
            
            let position = touch.location(in: self)
            
            if (position.x < self.frame.width / 2) {
                joystick = false
            }
        }
    }
}
