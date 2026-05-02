//
//  MoveComponent.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import GameplayKit
import SpriteKit

class MoveComponent: GKComponent {
    let speed: CGFloat = 200
    let jumpImpulse: CGFloat = 100
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let input = entity?.component(ofType: InputComponent.self) else {
            return
        }
        
        let direction = input.joystickDirection
        
        node.physicsBody?.velocity.dx = direction * speed
        
        if input.wantsToJump && abs(node.physicsBody?.velocity.dy ?? 0) < 0.1 {
            node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
        }
        
        if direction > 0 {
            node.xScale = abs(node.xScale)
        } else if direction < 0 {
            node.xScale = -abs(node.xScale)
        }
    }
}
