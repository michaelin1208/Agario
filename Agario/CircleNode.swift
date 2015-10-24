//
//  CircleNode.swift
//  Agario
//
//  Created by Michaelin on 15/9/6.
//  Copyright (c) 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class CircleNode: SKShapeNode {
    var originalRadius:CGFloat = 10.0
    var radius:CGFloat = 10.0
    var defaultSpeed:CGFloat = 150.0
    var isEaten = false
//    var times:CGFloat = 1
    
    /* create circle node in customized point */
    class func createJoystickBase(radius:CGFloat)->CircleNode{
        let circle = CircleNode()
        circle.originalRadius = radius
        circle.radius = radius
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, circle.radius, CGFloat(0), CGFloat(2 * M_PI), true)
        circle.path = path
        circle.lineWidth = 2
        circle.strokeColor = UIColor.darkGrayColor()
//        circle.physicsBody = SKPhysicsBody(rectangleOfSize: circle.frame.size)
//        circle.physicsBody?.affectedByGravity = false
        return circle
    }
    
    /* get the speed according to the size of the circle */
    func getSpeedRate()->CGFloat {
        var speed = defaultSpeed - (radius - originalRadius)/4
        if speed < 10{
            speed = 10
        }
        return speed
    }
}


/* extent the UIColor class to provide random color function */
extension UIColor{
    class func randomColor()->UIColor{
        let red:CGFloat = CGFloat(arc4random())%1001/1000
        let green:CGFloat = CGFloat(arc4random())%1001/1000
        let blue:CGFloat = CGFloat(arc4random())%1001/1000
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}