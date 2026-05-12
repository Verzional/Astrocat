//
//  IdleState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit

class IdleState: GKState {
    unowned let locomotionComponent: LocomotionComponent
    
    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == JumpingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Start Idle Animation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {

    }
}
