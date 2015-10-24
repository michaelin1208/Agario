//
//  AiPlayerNode.swift
//  Agario
//
//  Created by Michaelin on 15/10/7.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class AiPlayerNode: PlayerNode {
    /* create food node in (0,0) point */
    
    override init() {
        super.init()
        
        self.originalRadius = AIPLAYER_SIZE
        self.radius = AIPLAYER_SIZE
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
        self.physicsBody?.categoryBitMask = aiPlayerCategory
        self.physicsBody?.collisionBitMask = boundaryCategory
        self.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory | foodCategory | obstacleCategory
        let x = CGFloat(arc4random())%(WIDTH-2*(self.radius+10))-WIDTH/2+(self.radius+10)
        let y = CGFloat(arc4random())%(HEIGHT-2*(self.radius+10))-HEIGHT/2+(self.radius+10)
        self.position = CGPoint(x: x,y: y)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAI(){
        let aiAction = SKAction.runBlock({
            self.searchNearFood()
        })
        let sleepAcition = SKAction.waitForDuration(0.2)
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([aiAction,sleepAcition])))
    }
    
    func searchNearFood(){
        if let children = self.parent?.children {
            var moveDirection:CGVector = CGVector(dx: 0,dy: 0)    //in the future have to add random direction here.
            
            if let currentVelocity = self.physicsBody?.velocity {
                if currentVelocity.dx != 0 || currentVelocity.dy != 0 {
                    moveDirection = currentVelocity
                }
            }
            
            var nearestDistance:CGFloat = -1
            
            let speedRate:CGFloat = self.getSpeedRate()
//            print("children \(children.count)")
            for node in children {
                
                if node.isKindOfClass(CircleNode) {
                    let circle = node as! CircleNode
                    let distance = sqrt(pow(circle.position.x-self.position.x, 2) + pow(circle.position.y-self.position.y, 2))
                    if circle.radius * COMPARE_RATE > self.radius || self.physicsBody?.categoryBitMask == obstacleCategory {
                        let relatedDistance = sqrt(pow(circle.position.x-self.position.x, 2) + pow(circle.position.y-self.position.y, 2)) - circle.radius - 2
                        if nearestDistance > relatedDistance || nearestDistance == -1 {
                            nearestDistance = relatedDistance
                            moveDirection = CGVector(dx: -(circle.position.x-self.position.x)/distance * speedRate,dy: -(circle.position.y-self.position.y)/distance * speedRate)
                        }
                    }else if self.radius * COMPARE_RATE > circle.radius {
                        let relatedDistance = sqrt(pow(circle.position.x-self.position.x, 2) + pow(circle.position.y-self.position.y, 2)) - self.radius
                        if nearestDistance > relatedDistance || nearestDistance == -1 {
                            nearestDistance = relatedDistance
                            moveDirection = CGVector(dx: (circle.position.x-self.position.x)/distance * speedRate,dy: (circle.position.y-self.position.y)/distance * speedRate)
                        }
                    }
                }
            }
        
        
            self.physicsBody?.velocity = moveDirection
        }
    }

}