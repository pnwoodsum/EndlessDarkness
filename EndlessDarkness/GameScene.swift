//
//  GameScene.swift
//  EndlessDarkness
//
//  Created by Peter Woodsum (RIT Student) on 4/9/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var joystick: Bool = false
    var joyStickInitialPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var joyStickCurrentPosition: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    var player = Player()
    var skCamera: SKCameraNode?
    
    let map = SKSpriteNode(imageNamed: "map.png")
    let playerSprite = SKSpriteNode(imageNamed: "playerUp.png")
    
    let positionLabel = SKLabelNode(text: "Position: " )
    
    // Used to initialize node positions, attributes etc...
    override func didMove(to view: SKView) {
        
        map.zPosition = 0.1
        map.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        addChild(map)
        
        playerSprite.zPosition = 0.9
        playerSprite.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        player.position = playerSprite.position
        addChild(playerSprite)
        
        positionLabel.zPosition = 1.0
        positionLabel.position = CGPoint(x: 10.0, y: 10.0)
        addChild(positionLabel)
        
        skCamera = SKCameraNode()
        self.camera = skCamera
        self.addChild(skCamera!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        positionLabel.text = "Position: \(player.position)"
        
        playerSprite.position = player.position
        
        skCamera?.position = player.position
        
        if joystick {
            let xDirection = Float(joyStickCurrentPosition.x - joyStickInitialPosition.x)
            let yDirection = Float(joyStickCurrentPosition.y - joyStickInitialPosition.y)
            
            player.move(xDirection: xDirection, yDirection: yDirection)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches) {
            
            let position = touch.location(in: self)
            
            if (position.x < self.frame.width / 2) {
                joyStickInitialPosition = position
                joystick = true
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick = false
        for touch in (touches) {
            
            let position = touch.location(in: self)
            
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
                
                print("touch ended")
                print(position.x)
                print(position.y)
            }
            
        }
    }
    
}
