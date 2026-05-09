//
//  ElectricCoilSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class ElectricCoilSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .electricCoil
        else { return }
        
        if let stateComp = player.component(ofType: StateComponent.self) {
            if let stunned = stateComp.stateMachine.state(forClass: StunnedState.self) {
                stunned.duration = trapData.effectDuration
            }
            
            stateComp.stateMachine.enter(StunnedState.self)
        }
    }
}
