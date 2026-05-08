//
//  TrapEntity.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit
import SpriteKit

class TrapEntity: GKEntity {
    init(node: SKSpriteNode) {
        super.init()
        
        node.texture?.filteringMode = .nearest
        
        let visualComponent = GKSKNodeComponent(node: node)
        addComponent(visualComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
