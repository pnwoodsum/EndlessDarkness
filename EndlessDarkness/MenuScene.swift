//
//  MenuScene.swift
//  EndlessDarkness
//
//  Created by Student on 4/25/18.
//  Copyright © 2018 Peter Woodsum (RIT Student). All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var continueButton = SKLabelNode(text: "Continue Game")
    var newButton = SKLabelNode(text: "New Game")
    
    var playButton = SKSpriteNode()
    let playButtonTex = SKTexture(imageNamed: "play")
    
    override func didMove(to view: SKView) {
        continueButton.fontSize = 50
        continueButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        
        newButton.fontSize = 25
        newButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)

        self.addChild(continueButton)
        self.addChild(newButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            let node = self.atPoint(position)
            
            if node == continueButton {
                let transition: SKTransition = SKTransition.fade(withDuration: 1)
                let scene: SKScene = GameScene(size: self.size)
                self.view?.presentScene(scene, transition: transition)
            }
            
            else if node == continueButton {
                let transition: SKTransition = SKTransition.fade(withDuration: 1)
                let scene: SKScene = GameScene(size: self.size)
                self.view?.presentScene(scene, transition: transition)
            }
        }
    }
}
