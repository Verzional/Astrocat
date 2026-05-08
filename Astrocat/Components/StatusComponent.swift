//
//  StatusComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit

enum StatusEffect {
    case suckedIn
    case repelled
    case slowed
    case stunned
    case dusty
}

class StatusComponent: GKComponent {
    private var activeEffects: [StatusEffect: TimeInterval] = [:]
    
    var isStunned: Bool { activeEffects[.stunned] != nil }
    var isSlowed: Bool { activeEffects[.slowed] != nil }
    var isDusty: Bool { activeEffects[.dusty] != nil }
    var isSuckedIn: Bool { activeEffects[.suckedIn] != nil }
    
    func applyEffect(_ effect: StatusEffect, duration: TimeInterval) {
        let currentRemaining = activeEffects[effect] ?? 0
        activeEffects[effect] = max(currentRemaining, duration)
        
        print("Applied \(effect) for \(duration)s")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        for (effect, timeLeft) in activeEffects {
            let newTime = timeLeft - seconds
            if newTime <= 0 {
                activeEffects.removeValue(forKey: effect)
                print("Effect \(effect) expired")
            } else {
                activeEffects[effect] = newTime
            }
        }
    }
}
