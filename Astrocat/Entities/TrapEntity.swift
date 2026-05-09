//
//  TrapEntity.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit
import SpriteKit

enum TrapType {
    case blackHole
    case forceField
    case purpleSlime
    case electricCoil
    case cometDust
}

class TrapEntity: GKEntity {
    let trapType: TrapType
    
    init(node: SKSpriteNode, type: TrapType) {
        self.trapType = type
        
        super.init()
        
        node.texture?.filteringMode = .nearest
        
        let visualComponent = GKSKNodeComponent(node: node)
        addComponent(visualComponent)
        
        let trapComponent = TrapComponent(type: type)
        addComponent(trapComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
