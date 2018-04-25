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
    
    var playerViewPosition: CGPoint?
    
    var player = Player()
    var skCamera: SKCameraNode?
    
    let playerSprite = SKSpriteNode(imageNamed: "playerUp.png")
    
    var joyStickNode = SKSpriteNode(imageNamed: "greyCircle.png")
    let positionLabel = SKLabelNode(text: "Position: " )
    let goldLabel = SKLabelNode(text: "Gold: ")
    
    var seed: UInt32 = 3079430158
    
    // Used to initialize node positions, attributes etc...
    override func didMove(to view: SKView) {
        
        self.levelManager = LevelManager(skScene: self)
        
        //seed = arc4random()
        
        // Initialize player sprite and class
        playerSprite.zPosition = 0.9
        playerSprite.position = CGPoint(x: 0.0, y: 0.0)
        player.position = playerSprite.position
        self.addChild(playerSprite)
        
        // Initialize camera
        skCamera = SKCameraNode()
        self.camera = skCamera
        self.addChild(skCamera!)
        
        // Initialize UI elements
        joyStickNode.zPosition = 1.0
        joyStickNode.position = CGPoint(x: 10.0, y: 10.0)
        skCamera?.addChild(joyStickNode)
        joyStickNode.scale(to: CGSize(width: 30, height: 30))
        joyStickNode.isHidden = true
        
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
        

    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let deltaTime: TimeInterval = currentTime - lastUpdateTimeInterval
        
        lastUpdateTimeInterval = currentTime
        
        playerViewPosition = convertPoint(toView: player.position)
        
        playerSprite.position = player.position
        
        skCamera?.position = player.position
        
        if (joystick) {
            joyStickNode.isHidden = false

            joyStickNode.position.x = joyStickInitialPosition.x - (view?.frame.width)! / 2
            joyStickNode.position.y = -1 * (joyStickInitialPosition.y - (view?.frame.height)! / 2)
            
        } else {
            joyStickNode.isHidden = true
        }
        
        positionLabel.position = CGPoint(x: 10 - (view?.frame.width)! / 2, y: -20 + (view?.frame.height)! / 2)
        positionLabel.text = "Position: (\(Int(player.position.x)), \(Int(player.position.y)))"
        
        goldLabel.position = CGPoint(x: 10 - (view?.frame.width)! / 2, y: -100 + (view?.frame.height)! / 2)
        goldLabel.text = "Gold: (\(player.money))"
        
        playerSprite.position = player.position
        
        skCamera?.position = player.position
        
        if joystick {
            let xDirection = Float(joyStickCurrentPosition.x - joyStickInitialPosition.x)
            let yDirection = Float(joyStickCurrentPosition.y - joyStickInitialPosition.y)
            
            playerSprite.zRotation = CGFloat(atan2f(-xDirection, -yDirection))
            
            player.move(xDirection: xDirection, yDirection: yDirection, deltaTime: Float(deltaTime))
            
            levelManager?.CheckPlayerCollisions(player: player)
            
            let tempChunk = levelManager?.ChunkContainsPoint(point: player.position)
            
            player.currentChunk = (tempChunk?.chunkIndex)!
            if player.currentChunk != player.previousChunk {
                levelManager?.UpdateMap(point: player.position, skScene: self)
            }
            player.previousChunk = player.currentChunk
            
        }
        
        self.levelManager?.collectibleManager.CheckCollisions(playerSprite: playerSprite, player: player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches) {
            
            let position = touch.location(in: view)
            
            if (position.x < self.frame.width / 2) {
                joyStickInitialPosition = position
                joyStickCurrentPosition = position
                joystick = true
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick = false
        for touch in (touches) {
            
            let position = touch.location(in: view)
            
            if (position.x < self.frame.width / 2) {
                joystick = true
                
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
