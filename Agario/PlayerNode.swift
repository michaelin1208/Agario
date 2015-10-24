//
//  PlayerNode.swift
//  Agario
//
//  Created by Michaelin on 15/10/7.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class PlayerNode: CircleNode {
    var title:String = "Name"
    var mutualVelocity:CGVector = CGVector(dx: 0, dy: 0)
    var bouncesTime:NSTimeInterval = -1
    
    var isLeft:Bool = true
    /* create player node in (0,0) point */
    override init() {
        super.init()
        
        self.originalRadius = PLAYER_SIZE
        self.radius = PLAYER_SIZE
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, self.radius, CGFloat(0), CGFloat(2 * M_PI), true)
        self.path = path
        self.lineWidth = 1
        self.fillColor = UIColor.randomColor()
        self.strokeColor = UIColor.darkGrayColor()
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.physicsBody?.categoryBitMask = playerCategory
        self.physicsBody?.collisionBitMask = playerCategory | boundaryCategory
        self.physicsBody?.contactTestBitMask = aiPlayerCategory | foodCategory | obstacleCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* set the name to the player node, and set the special image by specific name */
    func addName(name: String) {
        self.title = name
        
        // set the special image by specific name
        var texture:SKTexture?
        switch self.title.lowercaseString {
        case "australia":
            texture = SKTexture(imageNamed: "australia")
        case "china":
            texture = SKTexture(imageNamed: "china")
        case "doge":
            texture = SKTexture(imageNamed: "doge")
        case "earth":
            texture = SKTexture(imageNamed: "earth")
        case "moon":
            texture = SKTexture(imageNamed: "moon")
        default:
            break
        }
        if (texture != nil) {
            self.fillColor = UIColor.whiteColor()
            self.fillTexture = texture
        }else{
            // just show name in node for other names
            let text = SKLabelNode(text: title)
            text.fontName = "Chalkduster"
            text.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            text.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            let scale = self.radius*1.9/text.frame.width
            text.setScale(scale)
            self.addChild(text)
        }
    }
}