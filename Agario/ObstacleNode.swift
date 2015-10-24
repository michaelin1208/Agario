//
//  ObstacleNode.swift
//  Agario
//
//  Created by Michaelin on 15/10/12.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class ObstacleNode: CircleNode {
    /* create food node in (0,0) point */
    override init() {
        super.init()
        self.originalRadius = OBSTACLE_SIZE
        self.radius = OBSTACLE_SIZE
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, self.radius, CGFloat(0), CGFloat(2 * M_PI), true)
        self.path = path
        self.lineWidth = 1
        let texture:SKTexture = SKTexture(imageNamed: "obstacle")
        self.fillColor = UIColor.whiteColor()
        self.fillTexture = texture
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.physicsBody?.categoryBitMask = obstacleCategory
        self.physicsBody?.collisionBitMask = boundaryCategory
        self.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory
        
        let x = CGFloat(arc4random())%(WIDTH-2*(self.radius+10))-WIDTH/2+(self.radius+10)
        let y = CGFloat(arc4random())%(HEIGHT-2*(self.radius+10))-HEIGHT/2+(self.radius+10)
        self.position = CGPoint(x: x,y: y)
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}