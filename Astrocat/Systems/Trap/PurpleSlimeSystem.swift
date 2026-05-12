//
//  PurpleSlimeSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class PurpleSlimeSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .purpleSlime
        else { return }
        
        if let stateComp = player.component(ofType: StatusComponent.self) {
            if stateComp.stateMachine.currentState is SlowedDownState {
                if let slowedDown = stateComp.stateMachine.currentState as? SlowedDownState {
                    slowedDown.elapsed = 0
                }
                return
            }
            
            if let slowedDown = stateComp.stateMachine.state(forClass: SlowedDownState.self) {
                slowedDown.duration = trapData.effectDuration
                slowedDown.modifier = trapData.speedMofidier
            }
            
            stateComp.stateMachine.enter(SlowedDownState.self)
        }
    }
}
