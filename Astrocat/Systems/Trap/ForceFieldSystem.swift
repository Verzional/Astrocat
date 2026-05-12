//
//  ForceFieldSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class ForceFieldSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .forceField
        else { return }
        
        if let status = player.component(ofType: StatusComponent.self) {
//            status.impulseForce = trapData.impulseForce
//            status.status = .repelled
        }
    }
}
