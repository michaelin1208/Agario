//
//  Player.swift
//  Agario
//
//  Created by Michaelin on 15/10/9.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

//
//  PlayerNode.swift
//  Agario
//
//  Created by Michaelin on 15/10/7.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class Player {
    var nodes:NSMutableArray = NSMutableArray()
    var name:String = ""
    var velocity:CGVector = CGVector(dx: 0, dy: 0)
    var lastSplitTime:NSTimeInterval = -1
    /* create player in (0,0) point */
    init(name:String) {
        self.name = name
        
        nodes.removeAllObjects()
        let newPlayerNode = PlayerNode()
        newPlayerNode.position = CGPoint(x: 0, y: 0)
        newPlayerNode.addName(name)
        nodes.addObject(newPlayerNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* return the original size of player */
    func originalSize()->CGFloat {
        let firstNode:PlayerNode = nodes.objectAtIndex(0) as! PlayerNode
        return pow(firstNode.originalRadius,2)
    }
    
    /* return the current size of player */
    func currentSize()->CGFloat {
        var size:CGFloat = 0
        for node in nodes {
            let playerNode = node as! PlayerNode
            size += pow(playerNode.radius,2)
        }
        return size
    }
    
    /* return the center of all nodes */
    func position()->CGPoint {
        var sumX:CGFloat = 0
        var sumY:CGFloat = 0
        for node in nodes {
            let playerNode:PlayerNode = node as! PlayerNode
            sumX += playerNode.position.x
            sumY += playerNode.position.y
        }
        return CGPoint(x: sumX/CGFloat(nodes.count), y: sumY/CGFloat(nodes.count))
    }
    
    /* move each node of a player */
    func moveVelocity(velocity:CGVector) {
        self.velocity = velocity
        calculateMutualVelocity()
        for node in nodes {
            let playNode = node as! PlayerNode
            let speedRate:CGFloat = playNode.getSpeedRate()
            playNode.physicsBody?.velocity = CGVector(dx: (velocity.dx + playNode.mutualVelocity.dx) * speedRate, dy: (velocity.dy + playNode.mutualVelocity.dy) * speedRate)
        }
    }
    
    /* keep move with setted velocity */
    func moveVelocity() {
        calculateMutualVelocity()
        for node in nodes {
            let playNode = node as! PlayerNode
            let speedRate:CGFloat = playNode.getSpeedRate()
            playNode.physicsBody?.velocity = CGVector(dx: (velocity.dx + playNode.mutualVelocity.dx) * speedRate, dy: (velocity.dy + playNode.mutualVelocity.dy) * speedRate)
        }
    }
    
    /* calculate mutual velocity between different node */
    func calculateMutualVelocity() {
        let centerPoint = position()
        for node in nodes {
            let playNode = node as! PlayerNode
            playNode.mutualVelocity = velocityFromPoint(playNode.position, toPoint: centerPoint)
        }
    }
    
    /* calculate velocity between two points */
    func velocityFromPoint(point1:CGPoint, toPoint point2:CGPoint)->CGVector {
        if point1 == point2 {
            return CGVector(dx: 0, dy: 0)
        }else{
            let xDist = point2.x - point1.x
            let yDist = point2.y - point1.y
            let normalization = sqrt(pow(xDist, 2) + pow(yDist, 2))
            return CGVector(dx: xDist/normalization/6, dy: yDist/normalization/6)
        }
    }
    
    /* split self */
    func split() {
        let splitableNodes = checkSplitable()
        if splitableNodes.count > 0 {
            lastSplitTime = NSDate().timeIntervalSince1970
            for node in splitableNodes {
                let playerNode = node as! PlayerNode
                let totalSize = pow(playerNode.radius, 2)
                let childNodeRadius = sqrt(totalSize/2)
                playerNode.radius = childNodeRadius
                let childNodeScale = childNodeRadius/playerNode.originalRadius
                let scaleAction = SKAction.scaleTo(childNodeScale, duration: 0.1)
                playerNode.runAction(scaleAction)
                
                let newPlayerNode = PlayerNode()
                let bornPosition = getBornPosition(playerNode)
                newPlayerNode.position = bornPosition
                newPlayerNode.fillColor = playerNode.fillColor
                newPlayerNode.addName(name)
                nodes.addObject(newPlayerNode)
                newPlayerNode.setScale(0)
                newPlayerNode.radius = childNodeRadius
                playerNode.parent?.addChild(newPlayerNode)
                
                let leaveAction = SKAction.moveBy(CGVector(dx: 5 * (bornPosition.x - playerNode.position.x), dy: 5 * (bornPosition.y - playerNode.position.y)), duration: 0.4)
                let endAction = SKAction.runBlock({
                    self.moveVelocity(self.velocity)
                })
                let sequence = SKAction.sequence([scaleAction, leaveAction, endAction])
                newPlayerNode.runAction(sequence)
            }
            
        }
        
    }
    
    /* merge nodes of this player */
    func mergeNodes() {
        lastSplitTime = -1
        let scale = sqrt(currentSize()/originalSize())
        let scaleUpAction = SKAction.scaleTo(scale, duration: 0.1)
        let scaleDownAction = SKAction.sequence([SKAction.scaleTo(0, duration: 0.1), SKAction.removeFromParent()])
        if nodes.count > 0 {
            for i in 0...nodes.count-1 {
                if i == 0 {
                    let playerNode = nodes.objectAtIndex(0) as! PlayerNode
                    playerNode.runAction(scaleUpAction)
                    playerNode.radius = playerNode.originalRadius * scale
                }else{
                    let playerNode = nodes.objectAtIndex(1) as! PlayerNode
                    playerNode.runAction(scaleDownAction)
                    nodes.removeObject(playerNode)
                }
            }
        }
        print("nodes.count \(nodes.count)")
    }
    
    /* calculate the position for new node */
    func getBornPosition(playerNode:PlayerNode)->CGPoint {
        if self.velocity != CGVector(dx: 0, dy: 0) {
            let velocityLength = sqrt(pow(velocity.dx, 2) + pow(velocity.dy, 2))
            let timesOfVelocity = playerNode.radius / velocityLength
            return CGPoint(x: playerNode.position.x + velocity.dx * timesOfVelocity, y: playerNode.position.y + velocity.dy * timesOfVelocity)
        }
        return CGPoint(x: playerNode.position.x + playerNode.radius, y: playerNode.position.y)
    }
    
    /* calculate the random position for new node */
    func getRandomBornPosition(playerNode:PlayerNode)->CGPoint {
        let randomAngel:CGFloat = CGFloat(arc4random())%3.1415926 - 1.57079633
        return CGPoint(x: playerNode.position.x + cos(randomAngel) * playerNode.radius, y: playerNode.position.y + sin(randomAngel) * playerNode.radius)
    }
    
    /* check whether there is at least one node can be splited */
    func checkSplitable()->NSMutableArray {
        let splitableNodes = NSMutableArray()
        for node in self.nodes {
            let playerNode = node as! PlayerNode
            if pow(playerNode.radius, 2) >= pow(PLAYER_SIZE, 2) * 2 {
                splitableNodes.addObject(playerNode)
            }
        }
        return splitableNodes
    }
}
