//
//  StateSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 10/05/26.
//

import GameplayKit

class StateSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let locomotion = entity?.component(ofType: LocomotionComponent.self),
              let status = entity?.component(ofType: StatusComponent.self)
        else{ return }
        
        locomotion.stateMachine.update(deltaTime: seconds)
        status.stateMachine.update(deltaTime: seconds)
    }
}
