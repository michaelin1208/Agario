//
//  WorldNode.swift
//  Agario
//
//  Created by Michaelin on 15/8/27.
//  Copyright (c) 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class WorldNode : SKSpriteNode {
    
    /* create the world node to hold the players and foods */
    class func createWorldBackground(width width: CGFloat,height: CGFloat)->WorldNode{
        let background = WorldNode(color: UIColor.whiteColor(), size: CGSize(width: width,height: height))
        let backgroundGrid = SKShapeNode()
        backgroundGrid.path = background.getCurrentGridPath(width: width, height: height)
        backgroundGrid.lineWidth = 1
        backgroundGrid.fillColor = UIColor.grayColor()
        backgroundGrid.strokeColor = UIColor.grayColor()
        background.addChild(backgroundGrid)
        let boundary = background.getBoundary(width:width, height:height)
        background.addChild(boundary)
        let leftStaticLine = background.getLeftStaticLine()
        background.addChild(leftStaticLine)
        let rightStaticLine = background.getRightStaticLine()
        background.addChild(rightStaticLine)
//        background.physicsBody = SKPhysicsBody(rectangleOfSize: background.frame.size)
//        background.physicsBody?.affectedByGravity = false
        return background
    }
    
    /* put the grid path into the background, it is good to show the player's moving */
    func getCurrentGridPath(width width:CGFloat, height:CGFloat)->CGMutablePath{
        let path = CGPathCreateMutable()
        let tempX = width/2
        let tempY = height/2
        for var i = -tempX; i <= tempX; i+=100 {
            CGPathMoveToPoint(path, nil, CGFloat(i), CGFloat(-tempY))
            CGPathAddLineToPoint(path, nil, CGFloat(i), CGFloat(tempY))
        }
        for var i = -tempY; i <= tempY; i+=100 {
            CGPathMoveToPoint(path, nil, CGFloat(-tempX), CGFloat(i))
            CGPathAddLineToPoint(path, nil, CGFloat(tempX), CGFloat(i))
        }
        CGPathGetCurrentPoint(path)
        return path
    }
    
    /* Create the boundary into the background */
    func getBoundary(width width: CGFloat,height: CGFloat)-> SKNode {
        let bounds = SKNode()
        bounds.physicsBody = SKPhysicsBody(edgeLoopFromRect:
            CGRect(x: -width/2, y: -height/2, width: width, height: height))
        bounds.physicsBody?.restitution = 1.0
        bounds.physicsBody?.friction = 0
        bounds.physicsBody?.categoryBitMask = boundaryCategory
        bounds.physicsBody?.collisionBitMask = aiPlayerCategory | playerCategory | foodCategory
        bounds.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory | foodCategory
        return bounds
    }
    
    func getLeftStaticLine()->SKNode{
        let staticLine = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 100, 100)
        CGPathAddLineToPoint(path, nil, 100, -100)
        staticLine.path = path
        staticLine.lineWidth = 2
        staticLine.strokeColor = UIColor.redColor()
        staticLine.fillColor = UIColor.redColor()
        staticLine.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 100, y: 100), toPoint: CGPoint(x: 100, y: -100))
        staticLine.physicsBody?.affectedByGravity = false
        staticLine.physicsBody?.restitution = 1
        staticLine.physicsBody?.friction = 0
        staticLine.zPosition = 0
        staticLine.physicsBody?.categoryBitMask = boundaryCategory
        staticLine.physicsBody?.collisionBitMask = aiPlayerCategory | playerCategory | foodCategory
        staticLine.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory | foodCategory
        return staticLine
    }
    func getRightStaticLine()->SKNode{
        let staticLine = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, -100, 100)
        CGPathAddLineToPoint(path, nil, -100, -100)
        staticLine.path = path
        staticLine.lineWidth = 2
        staticLine.strokeColor = UIColor.redColor()
        staticLine.fillColor = UIColor.redColor()
        staticLine.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: -100, y: 100), toPoint: CGPoint(x: -100, y: -100))
        staticLine.physicsBody?.affectedByGravity = false
        staticLine.physicsBody?.restitution = 1
        staticLine.physicsBody?.friction = 0
        staticLine.zPosition = 0
        staticLine.physicsBody?.categoryBitMask = boundaryCategory
        staticLine.physicsBody?.collisionBitMask = aiPlayerCategory | playerCategory | foodCategory
        staticLine.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory | foodCategory
        return staticLine
    }
}