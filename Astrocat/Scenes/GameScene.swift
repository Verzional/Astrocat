//
//  GameScene.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//  test

import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime: TimeInterval = 0
    private let mainCamera = SKCameraNode()
    
    // Player Systems
    var player: PlayerEntity?
    var movementSystem = GKComponentSystem(componentClass: MovementSystem.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    var stateSystem = GKComponentSystem(componentClass: StateSystem.self)
    
    // Trap Systems
    var blackHoleSystem = GKComponentSystem(componentClass: BlackHoleSystem.self)
    var electricCoilSystem = GKComponentSystem(componentClass: ElectricCoilSystem.self)
    var purpleSlimeSystem = GKComponentSystem(componentClass: PurpleSlimeSystem.self)
    var forceFieldSystem = GKComponentSystem(componentClass: ForceFieldSystem.self)
    
    // Multiplayer Systems
    var remotePlayers: [String: RemotePlayerEntity] = [:]
    var matchSystem: MatchSystem?
    var onGameFinished: (([RaceResult]) -> Void)?
    
    private func setupMultiplayer() {
        guard let matchSystem = matchSystem else { return }
        
        matchSystem.onPlayerUpdateReceived = { [weak self] message in
            guard let self = self,
                  let id = message.senderID,
                  let x = message.playerX,
                  let y = message.playerY else { return }
            
            if self.remotePlayers[id] == nil {
                let remoteEntity = RemotePlayerEntity(scene: self)
                self.remotePlayers[id] = remoteEntity
            }
            let dx = message.playerDX ?? 0
            self.remotePlayers[id]?.updatePosition(x: x, y: y, dx: dx)

        }
        
        matchSystem.onPlayerDisconnected = { [weak self] id in
            self?.remotePlayers[id]?.removeFromScene()
            self?.remotePlayers.removeValue(forKey: id)
        }
        
        matchSystem.onFinalResultsReceived = { [weak self] results in
            guard let self = self else { return }
            self.isPaused = true
            self.onGameFinished?(results)
        }
    }
    
    private func broadcastLocalPosition() {
        guard let matchSystem = matchSystem,
              matchSystem.matchState == .inGame,
              let node = player?.component(ofType: GKSKNodeComponent.self)?.node,
              let body = node.physicsBody else { return }
        
        let localID = GKLocalPlayer.local.gamePlayerID
        let msg = GameMessage.playerUpdate(
            senderID: localID,
            playerX: node.position.x,
            playerY: node.position.y,
            playerDX: body.velocity.dx,
            playerDY: body.velocity.dy
        )
        matchSystem.sendPlayerUpdate(msg)
    }
    
    var playerInput: InputComponent? {
        return player?.component(ofType: InputComponent.self)
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
        
        let overlay = SKSpriteNode(imageNamed: "Overlay")
        overlay.name = "DustOverlay"
        overlay.alpha = 0
        overlay.zPosition = 3
        overlay.setScale(8.5)
        overlay.texture?.filteringMode = .nearest
        mainCamera.addChild(overlay)
    }
    
    private func setupUI() {
        let marginX = frame.width / 2 - 200
        let marginY = frame.height / 2 - 200
        
        let joystick = JoystickNode()
        let jumpButton = JumpNode(iconName: "chevron.up.2")
        
        joystick.position = CGPoint(x: -marginX, y: -marginY)
        joystick.zPosition = 4
        
        jumpButton.position = CGPoint(x: marginX, y: -marginY)
        jumpButton.zPosition = 4
        
        joystick.onDirectionChange = { [weak self] direction in
            self?.playerInput?.joystickDirection = direction
        }
        
        jumpButton.onTap = { [weak self] in
            self?.playerInput?.wantsToJump = true
        }
        
        mainCamera.addChild(joystick)
        mainCamera.addChild(jumpButton)
    }
    
    private func setupTraps() {
        enumerateChildNodes(withName: "//BlackHole") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .blackHole)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "BlackHole",
                                   prefix: "BH",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
                
                self.blackHoleSystem.addComponent(foundIn: trapEntity)
            }
        }
        enumerateChildNodes(withName: "//ElectricCoil") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .electricCoil)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "ElectricCoil",
                                   prefix: "EC",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
        enumerateChildNodes(withName: "//PurpleSlime") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .purpleSlime)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "PurpleSlime",
                                   prefix: "PS",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
        enumerateChildNodes(withName: "//ForceField") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .forceField)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "ForceField",
                                   prefix: "FF",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
        enumerateChildNodes(withName: "//CometDust") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .cometDust)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "CometDust",
                                   prefix: "CD",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
    }
    
    private func setupPlayer() {
        if let node = childNode(withName: "//Player") as? SKSpriteNode {
            let playerEntity = PlayerEntity(node: node, camera: mainCamera)
            self.player = playerEntity
            
            movementSystem.addComponent(foundIn: playerEntity)
            cameraSystem.addComponent(foundIn: playerEntity)
            stateSystem.addComponent(foundIn: playerEntity)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        setupCamera()
        setupUI()
        setupTraps()
        setupPlayer()
        setupMultiplayer()
    }
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        
        blackHoleSystem.update(deltaTime: dt)
        movementSystem.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)
        stateSystem.update(deltaTime: dt)
        
        broadcastLocalPosition()
        
        lastUpdateTime = currentTime
    }
}

extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (PhysicsCategory.player | PhysicsCategory.trap) {
            let playerNode = (contact.bodyA.categoryBitMask == PhysicsCategory.player) ? contact.bodyA.node : contact.bodyB.node
            let trapNode = (contact.bodyA.categoryBitMask == PhysicsCategory.trap) ? contact.bodyA.node : contact.bodyB.node
            
            handleContact(playerNode: playerNode, trapNode: trapNode)
        }
    }
    
    private func handleContact(playerNode: SKNode?, trapNode: SKNode?) {
        guard let playerEntity = playerNode?.entity as? PlayerEntity,
              let trapEntity = trapNode?.entity as? TrapEntity else
        { return }
        
        for component in trapEntity.components {
            if let interactionHandler = component as? TrapProtocol {
                interactionHandler.didContact(player: playerEntity)
            }
        }
    }
    
    private func animateSprite(sprite: SKSpriteNode, atlasName: String, prefix: String, duration: TimeInterval = 0.1) {
        let atlas = SKTextureAtlas(named: atlasName)
        var frames: [SKTexture] = []
        
        let textureNames = atlas.textureNames.sorted()
        
        for i in 1...textureNames.count {
            let textureName = "\(prefix)-Frame-\(i)"
            frames.append(atlas.textureNamed(textureName))
        }
        
        let animation = SKAction.animate(with: frames, timePerFrame: duration)
        sprite.run(SKAction.repeatForever(animation))
    }
}
