//
//  FoodNode.swift
//  Agario
//
//  Created by Michaelin on 15/10/5.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class FoodNode: CircleNode {
    /* create food node in (0,0) point */
    override init() {
        super.init()
        self.originalRadius = FOOD_SIZE
        self.radius = FOOD_SIZE
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
        self.physicsBody?.categoryBitMask = foodCategory
        self.physicsBody?.collisionBitMask = boundaryCategory
        self.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory | foodCategory
        
        let x = CGFloat(arc4random())%(WIDTH-2*(self.radius+10))-WIDTH/2+(self.radius+10)
        let y = CGFloat(arc4random())%(HEIGHT-2*(self.radius+10))-HEIGHT/2+(self.radius+10)
        self.position = CGPoint(x: x,y: y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
