//
//  MotionManager.swift
//  gym-counter
//

import Foundation
import CoreMotion
import Observation

@Observable
class MotionManager {
    private let motionManager = CMMotionManager()
    
    var repCount = 0
    
    private var isGoingDown = false
    private let threshold: Double = 1.0
    
    func startUpdates() {
        guard motionManager.isGyroAvailable else {
            print("陀螺儀不可用。請在真實裝置上測試。")
            return
        }
        
        repCount = 0
        isGoingDown = false
        
        motionManager.gyroUpdateInterval = 1.0 / 50.0
        motionManager.startGyroUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            let rotationRate = data.rotationRate.x
            
            if rotationRate < -self.threshold && !self.isGoingDown {
                self.isGoingDown = true
            }
            
            if rotationRate > self.threshold && self.isGoingDown {
                self.repCount += 1
                self.isGoingDown = false
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopGyroUpdates()
    }
}
