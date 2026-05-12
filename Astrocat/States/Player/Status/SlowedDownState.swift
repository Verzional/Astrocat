//
//  SlowedDownState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 12/05/26.
//

import GameplayKit

class SlowedDownState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0
    var duration: TimeInterval = 0
    var modifier: CGFloat = 0
    var isActive: Bool = false
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        print("Start Slowed Down Animation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            isActive = false
            self.stateMachine?.enter(NormalState.self)
        }
    }
}
