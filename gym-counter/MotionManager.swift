//
//  MotionManager.swift
//  gym-counter
//

import Foundation // 匯入 Foundation 框架，用於基本功能
import CoreMotion // 匯入 CoreMotion 框架，用於處理運動感應數據
import Observation // 匯入 Observation 框架，用於觀察數據變化

@Observable // 標記為可觀察的類，允許其他視圖監聽數據變化
class MotionManager {
    private let motionManager = CMMotionManager() // 創建 CMMotionManager 實例，用於處理陀螺儀數據
    
    var repCount = 0 // 記錄完成次數的變數
    
    private var isGoingDown = false // 標記是否正在向下運動
    private let threshold: Double = 1.0 // 定義運動檢測的閾值
    
    func startUpdates() { // 開始更新陀螺儀數據的方法
        guard motionManager.isGyroAvailable else { // 檢查陀螺儀是否可用
            print("陀螺儀不可用。請在真實裝置上測試。") // 如果不可用，打印提示信息
            return // 結束方法
        }
        
        repCount = 0 // 初始化完成次數為 0
        isGoingDown = false // 初始化運動狀態為未向下
        
        motionManager.gyroUpdateInterval = 1.0 / 50.0 // 設置陀螺儀更新頻率為每秒 50 次
        motionManager.startGyroUpdates(to: .main) { [weak self] (data, error) in // 開始接收陀螺儀數據
            guard let self = self, let data = data else { return } // 確保數據有效
            
            let rotationRate = data.rotationRate.x // 獲取 x 軸的旋轉速率
            
            if rotationRate < -self.threshold && !self.isGoingDown { // 如果旋轉速率小於負閾值且未向下
                self.isGoingDown = true // 標記為向下運動
            }
            
            if rotationRate > self.threshold && self.isGoingDown { // 如果旋轉速率大於閾值且之前是向下
                self.repCount += 1 // 增加完成次數
                self.isGoingDown = false // 重置運動狀態
            }
        }
    }
    
    func stopUpdates() { // 停止更新陀螺儀數據的方法
        motionManager.stopGyroUpdates() // 停止接收陀螺儀數據
    }
}
