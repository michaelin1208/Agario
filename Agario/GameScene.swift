//
//  GameScene.swift
//  Agario
//
//  Created by Michaelin on 15/8/17.
//  Copyright (c) 2015年 Michaelin. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var highestRankNode:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    var currentRankNode:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    var highscoreNode:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    var foodConsumedNode:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    var otherPlayersEatenNode:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    var timeNode:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    
    var background:SKSpriteNode = WorldNode.createWorldBackground(width: CGFloat(WIDTH),height: CGFloat(HEIGHT))
    var currentPlayer:Player?
    var joystickBall = CircleNode.createJoystickBase(20)
    var joystickBase = CircleNode.createJoystickBase(40)
    var splitButton = CircleNode.createJoystickBase(20)
    var shootButton = CircleNode.createJoystickBase(20)
    var currentScale:CGFloat = 1
    var lastScale:CGFloat = 1
    var beginTime:NSTimeInterval = 0
    var lastTime:NSTimeInterval = 0
    var moveTouch:UITouch?
    var splitTouch:UITouch?
    var shootTouch:UITouch?
    var highestRank:Int = -1
    var eatFoodQty:Int = 0
    var eatPlayerQty:Int = 0
    var allPlayers = NSMutableArray()
    var aiPlayers = NSMutableArray()
    var foods = NSMutableArray()
    var contactNodes = NSMutableArray()
    let manager = CMMotionManager()
    var parentViewController:UIViewController?
    
    var originalX:Double?
    var originalY:Double?
//    var originalZ:Double?
    
    var playerName:String = ""
    
    var isMaster = true
    
    var isJoystick = true           //using joystick or Gravity
    var isAIModel = true   //single player game or multi-player game
    override func didMoveToView(view: SKView) {
        
        
        beginTime = NSDate().timeIntervalSince1970
        
        /* set contact delegate */
        self.physicsWorld.contactDelegate = self;
        
        /* Setup your scene here */
        let SCREEN_HEIGHT = self.frame.height
        let SCREEN_WIDTH = self.frame.width
        
        /* set the current player positions in background */
        currentPlayer = Player(name: playerName)
        for node in currentPlayer!.nodes {
            background.addChild(node as! SKNode)
        }
        allPlayers.addObject(currentPlayer!)
        
        /* control the game through joystick or accelerometer */
        if isJoystick {
            
            /* create a virtual stick to control the game */
            joystickBase.position = CGPoint(x: 100, y: 100)
            joystickBase.zPosition = 1  // in order to show it in the top
            self.addChild(joystickBase)
            joystickBall.position = joystickBase.position
            joystickBall.zPosition = 1  // in order to show it in the top
            self.addChild(joystickBall)
        }else{
            if manager.accelerometerAvailable {
                print("startAccelerometerUpdatesToQueue")
                manager.accelerometerUpdateInterval = 0.1
                manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                    data, error in
                    if self.originalX == nil {
                        self.originalX = data?.acceleration.x
                    }
                    if self.originalY == nil {
                        self.originalY = data?.acceleration.y
                    }
//                    if self.originalZ == nil {
//                        self.originalZ = data?.acceleration.z
                    //                    }
                    let changeX = ((data?.acceleration.x)! - self.originalX!) * 360
                    let changeY = ((data?.acceleration.y)! - self.originalY!) * 360
                    let distance = sqrt(pow(changeX, 2) + pow(changeY, 2))
//                    print("changeX \(changeX) changeY \(changeY) distance \(distance) ")
                    var direction = CGVector(dx: changeX, dy: changeY)
                    let maximumDist:Double = 10
                    if distance > maximumDist {
                        direction = CGVector(dx: changeX/distance * maximumDist, dy: changeY / distance * maximumDist)
                    }
                    self.startMoveTo(xDist: direction.dy / CGFloat(maximumDist), yDist: -direction.dx / CGFloat(maximumDist))
//                    print("direction \(direction)")
                }
                
            }
        }
        
        /* create two buttons to split node and shoot node */
        splitButton.position = CGPoint(x: SCREEN_WIDTH-40, y: 80)
        splitButton.zPosition = 10  // in order to show it in the top
        self.addChild(splitButton)
//        shootButton.position = CGPoint(x: SCREEN_WIDTH-80, y: 40)
//        shootButton.zPosition = 10  // in order to show it in the top
//        self.addChild(shootButton)
        
        /* test to set the scale to show more node */
        background.setScale(currentScale)
        
        /* add foods */
        if isMaster {
            for _ in 1...FOOD_QTY {
                createFood()
            }
        }
        
        /* add obstacles */
        if isMaster {
            for _ in 1...OBSTACLE_QTY {
                createObstacle()
            }
        }
        
        /* set the postion of the background in the frame */
        background.position = CGPoint(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT/2)
        background.zPosition = -1
        self.addChild(background)
//        aiPlayer.startAI()
        
        
        // add game status including score, rank, time and others.
//        let currentRank = allPlayers.indexOfObject(currentPlayer)
//        highestRank = currentRank
        highestRankNode.text = "Highest Rank: \(highestRank)"
        highestRankNode.fontColor = UIColor.blackColor()
        highestRankNode.fontSize = 16
        highestRankNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        highestRankNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        highestRankNode.position = CGPoint(x: 0, y: SCREEN_HEIGHT)
        self.addChild(highestRankNode)
        currentRankNode.text = "Current Rank: \(highestRank)"
        currentRankNode.fontColor = UIColor.blackColor()
        currentRankNode.fontSize = 16
        currentRankNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        currentRankNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        currentRankNode.position = CGPoint(x: 0, y: highestRankNode.position.y-highestRankNode.frame.height)
        self.addChild(currentRankNode)
        highscoreNode.text = "Score: \(highscore(self.currentPlayer!))"
        highscoreNode.fontColor = UIColor.blackColor()
        highscoreNode.fontSize = 16
        highscoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        highscoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        highscoreNode.position = CGPoint(x: 0, y: currentRankNode.position.y-currentRankNode.frame.height)
        self.addChild(highscoreNode)
        foodConsumedNode.text = "Food: \(eatFoodQty)"
        foodConsumedNode.fontColor = UIColor.blackColor()
        foodConsumedNode.fontSize = 16
        foodConsumedNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        foodConsumedNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        foodConsumedNode.position = CGPoint(x: 0, y: highscoreNode.position.y-highscoreNode.frame.height)
        self.addChild(foodConsumedNode)
        otherPlayersEatenNode.text = "Player: \(eatPlayerQty)"
        otherPlayersEatenNode.fontColor = UIColor.blackColor()
        otherPlayersEatenNode.fontSize = 16
        otherPlayersEatenNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        otherPlayersEatenNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        otherPlayersEatenNode.position = CGPoint(x: 0, y: foodConsumedNode.position.y-foodConsumedNode.frame.height)
        self.addChild(otherPlayersEatenNode)
        timeNode.text = "Time: \(transferTimeInterval(NSDate().timeIntervalSince1970 - beginTime))"
        timeNode.fontColor = UIColor.blackColor()
        timeNode.fontSize = 16
        timeNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        timeNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        timeNode.position = CGPoint(x: 0, y: otherPlayersEatenNode.position.y-otherPlayersEatenNode.frame.height)
        self.addChild(timeNode)
        
        
        //set the background color according to the lightness
        NSNotificationCenter.defaultCenter().addObserverForName(UIScreenBrightnessDidChangeNotification, object: nil, queue: nil, usingBlock:checkLightness)
        
    }
    
    func highscore(player:Player)->Int {
        var score:Int = 0
        for node in player.nodes {
            score += Int(pow((node as! PlayerNode).radius,2)/100)
        }
        return score
    }
    
    func sortAllPlayers() {
        allPlayers.sortUsingComparator({(s1:AnyObject!,s2:AnyObject!)->NSComparisonResult in
            let p1 = s1 as! Player
            let p2 = s2 as! Player
            let size1 = p1.currentSize()
            let size2 = p2.currentSize()
            if size1 > size2 {
                return NSComparisonResult.OrderedAscending
            }else if size1 < size2 {
                return NSComparisonResult.OrderedDescending
            }else{
                if p1.nodes == self.currentPlayer!.nodes {
                    return NSComparisonResult.OrderedDescending
                }
                if p2.nodes == self.currentPlayer!.nodes {
                    return NSComparisonResult.OrderedAscending
                }
                return NSComparisonResult.OrderedSame
            }
        })
    }
    
    func transferTimeInterval(time:NSTimeInterval)->NSString {
        let timeInt = Int(time)
        var second:NSString = "\(timeInt%60)"
        var minute:NSString = "\((timeInt/60)%60)"
        if second.length == 1 {
            second = "0\(second)"
        }
        if minute.length == 1 {
            minute = "0\(minute)"
        }
        return "\(timeInt/3600):\(minute):\(second)"
    }
    
    // screen touches delegate
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if (CGRectContainsPoint(joystickBase.frame, location)){
                /* Make sure the touch is in the range of virtual game stick */
                moveTouch = touch as? UITouch   //record the moveTouch to prevent it affected by other touches.
                joystickBallMove(touch) //move the virtual game stick
                prepareMove()   //move the player's ball, meanwhile the view is upon it
            }
            if (CGRectContainsPoint(splitButton.frame, location)){
                /* Make sure the touch is in the range of splitButton */
                splitTouch = touch as? UITouch   //record the splitTouch to prevent it affected by other touches.
            }
            if (CGRectContainsPoint(shootButton.frame, location)){
                /* Make sure the touch is in the range of shootButton */
                shootTouch = touch as? UITouch   //record the shootTouch to prevent it affected by other touches.
            }
        }
    }
    
    // screen touches delegate
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            if(touch as? UITouch == moveTouch){
                joystickBallMove(touch) //move the virtual game stick
                prepareMove()   //move the player's ball, meanwhile the view is upon it
            }
        }
    }
    
    // screen touches delegate
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            if(touch as? UITouch == moveTouch){
                moveTouch = nil
                joystickBallRecover()   //move the virtual stick ball back to the center of stick base
            }
            if(touch as? UITouch == splitTouch){
                let location = touch.locationInNode(self)
                if (CGRectContainsPoint(splitButton.frame, location)){
                    /* Make sure the touch is in the range of splitButton */
                    splitButtonTouched()
                }
                splitTouch = nil
            }
            if(touch as? UITouch == shootTouch){
                let location = touch.locationInNode(self)
                if (CGRectContainsPoint(shootButton.frame, location)){
                    /* Make sure the touch is in the range of shootButton */
                    shootButtonTouched()
                }
                shootTouch = nil
            }
        }
    }
    
    // screen touches delegate
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        /* not all end touches call the touchesEndes, someones will call touches cancelled */
        for touch: AnyObject in touches! {
            if(touch as? UITouch == moveTouch){
                moveTouch = nil
                joystickBallRecover()   //move the virtual stick ball back to the center of stick base
            }
            if(touch as? UITouch == splitTouch){
                let location = touch.locationInNode(self)
                if (CGRectContainsPoint(splitButton.frame, location)){
                    /* Make sure the touch is in the range of splitButton */
                    splitButtonTouched()
                }
                splitTouch = nil
            }
            if(touch as? UITouch == shootTouch){
                let location = touch.locationInNode(self)
                if (CGRectContainsPoint(shootButton.frame, location)){
                    /* Make sure the touch is in the range of shootButton */
                    shootButtonTouched()
                }
                shootTouch = nil
            }
        }
    }
    
    func splitButtonTouched() {
        self.currentPlayer!.split()
        
    }
    
    func shootButtonTouched() {
    }
    
    override func didFinishUpdate() {
        let currentTime = NSDate().timeIntervalSince1970
        
        /* check whether it is the time to merge the nodes of a player */
        for object in allPlayers {
            let player = object as! Player
            if player.lastSplitTime != -1 && currentTime - player.lastSplitTime > MERGE_TIME {
                player.lastSplitTime = -1
                player.mergeNodes()
            }
        }
        
        
        
        /* Move the camera according to the current player's position */
        let duration:NSTimeInterval = currentTime - lastTime
        var scale = currentScale
        if duration < 0.5 {
            scale = (currentScale - lastScale)/0.5 * CGFloat(duration)+lastScale
//            print("scale \(scale)")
        }
        self.background.setScale(scale)
        
        if allPlayers.containsObject(currentPlayer!) {
            let SCREEN_HEIGHT = self.frame.height
            let SCREEN_WIDTH = self.frame.width
            let position = self.currentPlayer!.position()
//            print("position \(position)")
            self.background.position = CGPoint(x: SCREEN_WIDTH / 2 - scale * position.x, y: SCREEN_HEIGHT / 2 - scale * position.y)
        }
        
        /* if it is in aiModel, the game have to guarantee there are enough ai players in the game */
        if(isAIModel){
            if(aiPlayers.count == 0) {
                for _ in 0...AIPLAYER_QTY-1 {
                    createAIPlayer()
                }
            }else if(aiPlayers.count<AIPLAYER_QTY){
                createAIPlayer()
            }
        }
        
        /* if current player is master, create food when food is less */
        if(isMaster){
            if foods.count <= FOOD_QTY {
                createFood()
            }
        }
        
        checkAllContactNodes()  //find out eating actions in the game
        
        /* update all status of the game */
        updateGameStatus()
        
        // if currentPlayer has more than 1 node, keep velocity 
        currentPlayer!.moveVelocity()
    }
    
    /* update all status of the game */
    func updateGameStatus(){
        if highestRank == -1 {
            highestRank = allPlayers.count
        }
        var currentRank = highestRank
        if allPlayers.containsObject(currentPlayer!){
            currentRank = allPlayers.indexOfObject(currentPlayer!)+1
            if currentRank < highestRank {
                highestRank = currentRank
            }
        }
        highestRankNode.text = "Highest Rank: \(highestRank)"
        currentRankNode.text = "Current Rank: \(currentRank)"
        highscoreNode.text = "Score: \(highscore(self.currentPlayer!))"
        foodConsumedNode.text = "Food: \(eatFoodQty)"
        otherPlayersEatenNode.text = "Player: \(eatPlayerQty)"
        timeNode.text = "Time: \(transferTimeInterval(NSDate().timeIntervalSince1970 - beginTime))"
    }
    
//    // set scale according to the size of player
//    func setWorldScale(){
//        currentScale = CGFloat((sqrtf(Float(currentPlayer!.originalSize() / currentPlayer!.currentSize())) + 0.2)/1.2)
//        print("currentScale \(currentScale)")
//        self.background.setScale(currentScale)
//    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    /* change the background according to the lightness */
    func checkLightness(notification:NSNotification){
        if UIScreen.mainScreen().brightness > 0.5 {
            self.background.color = UIColor.whiteColor()
            self.joystickBall.strokeColor = UIColor.darkGrayColor()
            self.joystickBase.strokeColor = UIColor.darkGrayColor()
            self.splitButton.strokeColor = UIColor.darkGrayColor()
            self.shootButton.strokeColor = UIColor.darkGrayColor()
            
        }
        if UIScreen.mainScreen().brightness <= 0.5 {
            self.background.color = UIColor.darkGrayColor()
            self.joystickBall.strokeColor = UIColor.whiteColor()
            self.joystickBase.strokeColor = UIColor.whiteColor()
            self.splitButton.strokeColor = UIColor.whiteColor()
            self.shootButton.strokeColor = UIColor.whiteColor()
        }
    }
    
    func createFood(){
        let food = FoodNode()
        background.addChild(food)
        foods.addObject(food)
    }
    
    func createObstacle(){
        let obstacle = ObstacleNode()
        background.addChild(obstacle)
    }
    
    /* create ai player and put it into the game, then record it in aiPlayers*/
    func createAIPlayer(){
        let aiPlayer = AiPlayer(name:"AI Player")
        for node in aiPlayer.nodes {
            let aiPlayerNode = node as! AiPlayerNode
            background.addChild(aiPlayerNode)
            aiPlayerNode.startAI()
        }
        allPlayers.addObject(aiPlayer)
        sortAllPlayers()
        aiPlayers.addObject(aiPlayer)
    }
    
    /* check each pair of contact node whether a node eat another one */
    func checkAllContactNodes() {
        let newContactNodes = NSMutableArray()
        for contact in contactNodes {
            if let firstNode = contact.bodyA.node as? CircleNode,secondNode = contact.bodyB.node as? CircleNode{
                let distX2 = pow(firstNode.position.x - secondNode.position.x, 2)
                let distY2 = pow(firstNode.position.y - secondNode.position.y, 2)
                let distance = sqrt(distX2 + distY2)
                if firstNode.physicsBody?.categoryBitMask == obstacleCategory && secondNode.physicsBody?.categoryBitMask == obstacleCategory {
                    secondNode.removeFromParent()
                    createObstacle()
                }else if firstNode.physicsBody?.categoryBitMask == obstacleCategory {
                    if distance < secondNode.radius && secondNode.radius - firstNode.radius > firstNode.radius * (1 - COMPARE_RATE) {
                        destroy(secondNode)
                    }else{
                        newContactNodes.addObject(contact)
                    }
                }else if secondNode.physicsBody?.categoryBitMask == obstacleCategory {
                    if distance < firstNode.radius && firstNode.radius - secondNode.radius > secondNode.radius * (1 - COMPARE_RATE) {
                        destroy(firstNode)
                    }else{
                        newContactNodes.addObject(contact)
                    }
                }else if distance < firstNode.radius && firstNode.radius - secondNode.radius > secondNode.radius * (1 - COMPARE_RATE) {
                    eatFood(player: firstNode, eat: secondNode)
                }else if distance < secondNode.radius && secondNode.radius - firstNode.radius > firstNode.radius * (1 - COMPARE_RATE) {
                    eatFood(player: secondNode, eat: firstNode)
                }else{
                    newContactNodes.addObject(contact)
                }
            }
        }
        contactNodes = newContactNodes
    }
    
    /* SKPhysicsContactDelegate */
    func didBeginContact(contact: SKPhysicsContact) {
        
        //￼Disk bounces off properly with animation from the edges of the game world and static linear objects in the world
        if contact.bodyA.node?.physicsBody?.categoryBitMask == boundaryCategory {
            if let playerNode = contact.bodyB.node as? PlayerNode {
                if playerNode.isLeft || NSDate().timeIntervalSince1970 - playerNode.bouncesTime > 0.1 {
                    playerNode.bouncesTime = NSDate().timeIntervalSince1970
                    playerNode.isLeft = false
                    for p in allPlayers {
                        let currentPlayer = p as! Player
                        if currentPlayer.nodes.containsObject(playerNode) {
                            if playerNode.position.x <= -WIDTH/2 + playerNode.frame.width/2 + 1 || playerNode.position.x >= WIDTH/2 - playerNode.frame.width/2 - 1 {
                                currentPlayer.moveVelocity(CGVector(dx: -currentPlayer.velocity.dx, dy: currentPlayer.velocity.dy))
                            }
                            if playerNode.position.y <= -HEIGHT/2 + playerNode.frame.height/2 + 1 || playerNode.position.y >= HEIGHT/2 - playerNode.frame.height/2 - 1 {
                                currentPlayer.moveVelocity(CGVector(dx: currentPlayer.velocity.dx, dy: -currentPlayer.velocity.dy))
                            }
                            if playerNode.position.x > -playerNode.frame.width/2 - 1 + 100 && playerNode.position.x <  playerNode.frame.width/2 + 1 + 100 && playerNode.position.y >= -100 && playerNode.position.y <= 100 {
                                currentPlayer.moveVelocity(CGVector(dx: -currentPlayer.velocity.dx, dy: currentPlayer.velocity.dy))
                            }
                            if playerNode.position.x > -playerNode.frame.width/2 - 1 - 100 && playerNode.position.x <  playerNode.frame.width/2 + 1 - 100 && playerNode.position.y >= -100 && playerNode.position.y <= 100 {
                                currentPlayer.moveVelocity(CGVector(dx: -currentPlayer.velocity.dx, dy: currentPlayer.velocity.dy))
                            }
                            break
                        }
                    }
                }
            }
        }else if contact.bodyB.node?.physicsBody?.categoryBitMask == boundaryCategory {
            if let playerNode = contact.bodyA.node as? PlayerNode {
                if playerNode.isLeft || NSDate().timeIntervalSince1970 - playerNode.bouncesTime > 0.1 {
                    playerNode.bouncesTime = NSDate().timeIntervalSince1970
                    playerNode.isLeft = false
                    for p in allPlayers {
                        let currentPlayer = p as! Player
                        if currentPlayer.nodes.containsObject(playerNode) {
                            if playerNode.position.x <= -WIDTH/2 + playerNode.frame.width/2 + 1 || playerNode.position.x >= WIDTH/2 - playerNode.frame.width/2 - 1 {
                                currentPlayer.moveVelocity(CGVector(dx: -currentPlayer.velocity.dx, dy: currentPlayer.velocity.dy))
                            }
                            if playerNode.position.y <= -HEIGHT/2 + playerNode.frame.height/2 + 1 || playerNode.position.y >= HEIGHT/2 - playerNode.frame.height/2 - 1 {
                                currentPlayer.moveVelocity(CGVector(dx: currentPlayer.velocity.dx, dy: -currentPlayer.velocity.dy))
                            }
                            if playerNode.position.x > -playerNode.frame.width/2 - 1 + 100 && playerNode.position.x <  playerNode.frame.width/2 + 1 + 100 && playerNode.position.y >= -100 && playerNode.position.y <= 100 {
                                currentPlayer.moveVelocity(CGVector(dx: -currentPlayer.velocity.dx, dy: currentPlayer.velocity.dy))
                            }
                            if playerNode.position.x > -playerNode.frame.width/2 - 1 - 100 && playerNode.position.x <  playerNode.frame.width/2 + 1 - 100 && playerNode.position.y >= -100 && playerNode.position.y <= 100 {
                                currentPlayer.moveVelocity(CGVector(dx: -currentPlayer.velocity.dx, dy: currentPlayer.velocity.dy))
                            }
                            break
                        }
                    }
                }
            }
        }else if !contactNodes.containsObject(contact) {
            if let firstNode = contact.bodyA.node as? CircleNode,secondNode = contact.bodyB.node as? CircleNode{
                if firstNode.radius >= secondNode.radius {
                    firstNode.zPosition = 1
                    secondNode.zPosition = 0
                }else{
                    secondNode.zPosition = 1
                    firstNode.zPosition = 0
                }
            }
            contactNodes.addObject(contact)
        }
    }
    
    /* SKPhysicsContactDelegate */
    func didEndContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.physicsBody?.categoryBitMask == boundaryCategory {
            if let playerNode = contact.bodyB.node as? PlayerNode {
                playerNode.isLeft = true
            }
        }else if contact.bodyB.node?.physicsBody?.categoryBitMask == boundaryCategory {
            if let playerNode = contact.bodyA.node as? PlayerNode {
                playerNode.isLeft = true
            }
        }
        if contactNodes.containsObject(contact) {
            if let firstNode = contact.bodyA.node as? CircleNode,secondNode = contact.bodyB.node as? CircleNode{
                firstNode.zPosition = 0
                secondNode.zPosition = 0
            }
            contactNodes.removeObject(contact)
        }
    }
    
    /* player eats food method */
    func eatFood(player player: CircleNode, eat food: CircleNode){
        if !food.isEaten {
            food.isEaten = true
            player.radius = sqrt(pow(player.radius,2) + pow(food.radius,2))
            let scale = player.radius/player.originalRadius
            let scaleUp = SKAction.scaleTo(scale, duration: 0.1)
            player.runAction(scaleUp)
            
            // delete eaten player
            let newAllPlayers = NSMutableArray()
            let newAiPlayers = NSMutableArray()
            for player in allPlayers {
                let p = player as! Player
                if p.nodes.containsObject(food) {
                    p.nodes.removeObject(food)
                    if currentPlayer!.nodes.count == 0 {
                        print("GameOver")
                        let alert = UIAlertController(title: "GameOver", message: "You are died! ", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(actionSheetController) -> Void in
                            self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        alert.addAction(UIAlertAction(title: "TryAgain", style: UIAlertActionStyle.Default, handler: {(actionSheetController) -> Void in
                            self.restartGame()
                        }))
                        self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                if p.nodes.count > 0 {
                    newAllPlayers.addObject(player)
                    if p.nodes.objectAtIndex(0).physicsBody?!.categoryBitMask == aiPlayerCategory {
                        newAiPlayers.addObject(player)
                    }
                }
            }
            allPlayers = newAllPlayers
            aiPlayers = newAiPlayers
            
            if food.physicsBody?.categoryBitMask == foodCategory {
                foods.removeObject(food)
            }
            
            if currentPlayer!.nodes.containsObject(player) {
                lastTime = NSDate().timeIntervalSince1970
                lastScale = currentScale
                currentScale = (sqrt(currentPlayer!.originalSize()/currentPlayer!.currentSize()) + 0.5)/1.5
    //            let backgroundScaleDown = SKAction.scaleTo(currentScale, duration: 0.5)
    //            background.runAction(backgroundScaleDown)
                
                if food.physicsBody?.categoryBitMask == aiPlayerCategory||food.physicsBody?.categoryBitMask == playerCategory {
                    eatPlayerQty++
                }
                if food.physicsBody?.categoryBitMask == foodCategory {
                    eatFoodQty++
                }
                
            }
            
            let scaleDown = SKAction.scaleTo(0, duration: 0.1)
            let disappear = SKAction.removeFromParent()
            food.runAction(SKAction.sequence([scaleDown,disappear]))
            
            sortAllPlayers()
        }
    }
    
    /* destroy the node into small node */
    func destroy(node: CircleNode){
        for object in allPlayers {
            let player = object as! Player
            if player.nodes.containsObject(node) {
                if node.physicsBody?.categoryBitMask == aiPlayerCategory {
                    let actions = SKAction.sequence([SKAction.scaleTo(0, duration: 0.1), SKAction.removeFromParent()])
                    node.runAction(actions)
                    player.nodes.removeObject(node)
                }else{
                    player.lastSplitTime = NSDate().timeIntervalSince1970
                    let t = Int(pow(node.radius/node.originalRadius,2))
                    let targetRadius = sqrt(pow(node.radius, 2)/CGFloat(t))
                    node.radius = targetRadius
                    let scale = targetRadius/node.originalRadius
                    let scaleAction = SKAction.scaleTo(scale, duration: 0.1)
                    node.runAction(scaleAction)
                    
                    print("t \(t)")
                    for _ in 1...t-1 {
                        let newPlayerNode = PlayerNode()
                        if node.physicsBody?.categoryBitMask == aiPlayerCategory {
                            newPlayerNode.physicsBody?.categoryBitMask = aiPlayerCategory
                            newPlayerNode.physicsBody?.collisionBitMask = boundaryCategory
                            newPlayerNode.physicsBody?.contactTestBitMask = aiPlayerCategory | playerCategory | foodCategory | obstacleCategory
                        }
    //                    print("\(node.position) \(player.getRandomBornPosition(node as! PlayerNode))")
                        let bornPosition = player.getRandomBornPosition(node as! PlayerNode)
                        newPlayerNode.position = bornPosition
                        newPlayerNode.fillColor = node.fillColor
                        newPlayerNode.addName(player.name)
                        player.nodes.addObject(newPlayerNode)
                        newPlayerNode.setScale(0)
                        newPlayerNode.radius = targetRadius
                        node.parent?.addChild(newPlayerNode)
                        newPlayerNode.runAction(scaleAction)
                    }
                }
                
//                player.nodes.removeObject(node)
                
                
            }
        }
    }
    
    /* move joystickBall back to its base's center */
    func joystickBallRecover(){
        let move:SKAction = SKAction.moveTo(joystickBase.position, duration: 0.2)
        move.timingMode = .EaseOut
        joystickBall.runAction(move)
    }
    
    /* move joystickBall according to the location of touch */
    func joystickBallMove(touch:AnyObject){
        let location = touch.locationInNode(self)
        let v = CGVector(dx: location.x - joystickBase.position.x, dy: location.y - joystickBase.position.y)
        let angel = atan2(v.dy, v.dx)
        
        /* calculate the joystickBall's moving range */
        let xDist:CGFloat = sin(angel - 1.57079633)*joystickBase.radius
        let yDist:CGFloat = cos(angel - 1.57079633)*joystickBase.radius
        
        if (CGRectContainsPoint(joystickBase.frame, location)){
            /* If the location is in base, put the ball in the location. */
            joystickBall.position = location
        }else{
            /* otherwise the distance between the ball and base center should be less than the length */
            joystickBall.position = CGPoint(x: joystickBase.position.x - xDist, y: joystickBase.position.y + yDist)
        }
    }
    
    /* process the move action of node in GameScene */
    func prepareMove(){
        let xDist:CGFloat = (self.joystickBall.position.x - self.joystickBase.position.x)/(self.joystickBase.radius)
        let yDist:CGFloat = (self.joystickBall.position.y - self.joystickBase.position.y)/(self.joystickBase.radius)
    
        /* if the point is in the center, any calculation is useless and dangerous */
        if(xDist != 0 || yDist != 0){
            /*  move the node by velocity of physics body */
            startMoveTo(xDist:xDist, yDist:yDist)
        }else{
            stopMove()
        }
    }
    
    func startMoveTo(xDist xDist:CGFloat, yDist:CGFloat){
        /* The move actions of background and the current player's ball,
        ensure the view is upen the player's ball */
        
//        let speedRate:CGFloat = currentPlayer.getSpeedRate()  //get speed according to the size of the ball.
////        print("player speedRate \(speedRate)")
//        let xSpeed = speedRate * xDist
//        let ySpeed = speedRate * yDist
        
        self.currentPlayer!.moveVelocity(CGVector(dx: xDist, dy: yDist))
        
//        println("angel \(moveAngel)")
    }
    
    func stopMove(){
        /* Stop the current node's moving */
        self.currentPlayer!.moveVelocity(CGVector(dx: 0, dy: 0))
    }
    
    /* restart the game */
    func restartGame(){
        currentScale = 1
        lastScale = 1
        background.setScale(currentScale)
        beginTime = NSDate().timeIntervalSince1970
        highestRank = -1
        eatFoodQty = 0
        eatPlayerQty = 0
        
        
        currentPlayer = Player(name: playerName)
        for node in currentPlayer!.nodes {
            background.addChild(node as! SKNode)
        }
        allPlayers.addObject(currentPlayer!)
        sortAllPlayers()
        
        let SCREEN_HEIGHT = self.frame.height
        let SCREEN_WIDTH = self.frame.width
        let position = self.currentPlayer!.position()
        self.background.position = CGPoint(x: SCREEN_WIDTH/2 - currentScale*position.x, y: SCREEN_HEIGHT/2 - currentScale*position.y)
    }
}

