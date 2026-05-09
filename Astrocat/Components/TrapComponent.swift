//
//  TrapComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit
import SpriteKit

class TrapComponent: GKComponent {
    let type: TrapType
    var pullRadius: CGFloat = 300.0
    var pullForce: CGFloat = 1000.0
    
    init(type: TrapType) {
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard type == .blackHole else { return }
        
        // 1. Get the Trap's node
        guard let trapNode = entity?.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        // 2. Find the Player in the scene
        guard let scene = trapNode.scene as? GameScene,
              let playerNode = scene.player?.component(ofType: GKSKNodeComponent.self)?.node,
              let playerPhysics = playerNode.physicsBody else { return }
        
        // 3. Calculate distance and vector
        let dx = trapNode.position.x - playerNode.position.x
        let dy = trapNode.position.y - playerNode.position.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // 4. Apply Force if within range
        if distance < pullRadius {
            // Normalize the vector and multiply by force
            let forceVector = CGVector(dx: (dx / distance) * pullForce,
                                       dy: (dy / distance) * pullForce)
            
            playerPhysics.applyForce(forceVector)
            
            scene.player?.component(ofType: StatusComponent.self)?.applyEffect(.suckedIn, duration: 2)
        }
    }
}
