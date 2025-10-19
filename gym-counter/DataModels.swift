//
//  DataModels.swift
//  gym-counter
//

import Foundation
import SwiftData

// MARK: - ExerciseType (運動類型)

@Model
final class ExerciseType {
    // MARK: - Properties
    
    /// 運動名稱 (唯一識別)
    @Attribute(.unique) var name: String
    
    /// 圖示名稱 (SF Symbols)
    var icon: String
    
    /// 目標肌群
    var targetMuscle: String
    
    /// 創建時間
    var createdAt: Date
    
    /// 是否為自訂運動
    var isCustom: Bool
    
    /// 排序順序 (用於列表顯示)
    var sortOrder: Int
    
    // MARK: - Initialization
    
    init(
        name: String,
        icon: String = "figure.mixed.cardio",
        targetMuscle: String = "全身",
        isCustom: Bool = false,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.icon = icon
        self.targetMuscle = targetMuscle
        self.createdAt = Date.now
        self.isCustom = isCustom
        self.sortOrder = sortOrder
    }
}
