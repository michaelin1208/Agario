//
//  AiPlayer.swift
//  Agario
//
//  Created by Michaelin on 15/10/9.
//  Copyright © 2015年 Michaelin. All rights reserved.
//

import SpriteKit

class AiPlayer: Player {
    /* create player in (0,0) point */
    override init(name:String) {
        super.init(name: name)
        nodes.removeAllObjects()
        let newPlayerNode = AiPlayerNode()
//        newPlayerNode.position = CGPoint(x: 0, y: 0)
//        newPlayerNode.addName(name)
        
        newPlayerNode.addName(name)
        nodes.addObject(newPlayerNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func startAI(){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            self.searchNearFood()
//        })
//    }
//    
//    func searchNearFood(){
//        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//        while(nodes.count>0) {
//            let firstNode = nodes.objectAtIndex(0) as! CircleNode
//            if let children = firstNode.parent?.children {
//                var moveDirection:CGVector = CGVector(dx: 0,dy: 0)    //in the future have to add random direction here.
//                if self.velocity.dx != 0 || self.velocity.dy != 0 {
//                    moveDirection = self.velocity
//                }
//                
//                var nearestDistance:CGFloat = -1
//                
//                for node1 in children {
//                    
//                    for node2 in self.nodes {
//                        if node1.isKindOfClass(CircleNode) && node2.isKindOfClass(CircleNode){
//                            
//                            let circle = node1 as! CircleNode
//                            let selfNode = node2 as! CircleNode
//                            let distance = sqrt(pow(circle.position.x-selfNode.position.x, 2) + pow(circle.position.y-selfNode.position.y, 2))
//                            if circle.radius * COMPARE_RATE > selfNode.radius || node1.physicsBody?.categoryBitMask == obstacleCategory {
//                                let relatedDistance = sqrt(pow(circle.position.x-selfNode.position.x, 2) + pow(circle.position.y-selfNode.position.y, 2)) - circle.radius - 2
//                                if nearestDistance > relatedDistance || nearestDistance == -1 {
//                                    nearestDistance = relatedDistance
//                                    moveDirection = CGVector(dx: -(circle.position.x-selfNode.position.x)/distance,dy: -(circle.position.y-selfNode.position.y)/distance)
//                                }
//                            }else if selfNode.radius * COMPARE_RATE > circle.radius {
//                                let relatedDistance = sqrt(pow(circle.position.x-selfNode.position.x, 2) + pow(circle.position.y-selfNode.position.y, 2)) - selfNode.radius
//                                if nearestDistance > relatedDistance || nearestDistance == -1 {
//                                    nearestDistance = relatedDistance
//                                    moveDirection = CGVector(dx: (circle.position.x-selfNode.position.x)/distance,dy: (circle.position.y-selfNode.position.y)/distance)
//                                }
//                            }
//                            
////                            let distance = sqrt(pow(circle.position.x-selfNode.position.x, 2) + pow(circle.position.y-selfNode.position.y, 2))
////                            
////                            if nearestDistance > distance || nearestDistance == -1 {
////                                if circle.radius * COMPARE_RATE > selfNode.radius || node1.physicsBody?.categoryBitMask == obstacleCategory {
////                                    nearestDistance = distance
////                                    moveDirection = CGVector(dx: -(circle.position.x-selfNode.position.x)/distance,dy: -(circle.position.y-selfNode.position.y)/distance)
////                                }else if selfNode.radius * COMPARE_RATE > circle.radius {
////                                    nearestDistance = distance
////                                    moveDirection = CGVector(dx: (circle.position.x-selfNode.position.x)/distance,dy: (circle.position.y-selfNode.position.y)/distance)
////                                }
////                            }
//                        }
//                        
//                    }
//                }
//                
//                
//                self.moveVelocity(moveDirection)
//            }
//            
//            NSThread.sleepForTimeInterval(0.2)
//        }
//        //        }
//    }
}