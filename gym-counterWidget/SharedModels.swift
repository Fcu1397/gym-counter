//
//  SharedModels.swift
//  gym-counterWidget
//
//  共享數據模型 - 讓 Widget 可以讀取主應用程式的資料
//

import Foundation // 匯入 Foundation 框架以使用基本功能。
import SwiftData // 匯入 SwiftData 框架以進行資料管理。

// MARK: - ExerciseType (運動類型)

@Model // 標記為 SwiftData 的模型。
final class ExerciseType { // 定義運動類型的數據模型。
    // MARK: - Properties
    
    /// 運動名稱 (唯一識別)
    @Attribute(.unique) var name: String // 運動的名稱，必須唯一。
    
    /// 圖示名稱 (SF Symbols)
    var icon: String // 運動的圖示名稱，使用 SF Symbols。
    
    /// 目標肌群
    var targetMuscle: String // 運動的目標肌群。
    
    /// 創建時間
    var createdAt: Date // 運動類型的創建時間。
    
    /// 是否為自訂運動
    var isCustom: Bool // 是否為使用者自訂的運動類型。
    
    /// 排序順序 (用於列表顯示)
    var sortOrder: Int // 運動類型在列表中的排序順序。
    
    // MARK: - Relationships
    
    /// 關聯的所有運動紀錄 (一對多關係)
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.exerciseType)
    var sessions: [WorkoutSession] // 與此運動類型相關的所有運動紀錄。
    
    // MARK: - Computed Properties
    
    /// 總運動次數
    var totalReps: Int {
        sessions.reduce(0) { $0 + $1.repCount } // 計算所有運動紀錄的總次數。
    }
    
    /// 總運動時長 (秒)
    var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration } // 計算所有運動紀錄的總時長。
    }
    
    /// 最近一次運動時間
    var lastWorkoutDate: Date? {
        sessions.max(by: { $0.startTime < $1.startTime })?.startTime // 獲取最近一次運動的開始時間。
    }
    
    // MARK: - Initialization
    
    init(
        name: String, // 運動名稱。
        icon: String = "figure.mixed.cardio", // 預設圖示名稱。
        targetMuscle: String = "全身", // 預設目標肌群。
        isCustom: Bool = false, // 預設是否為自訂運動。
        sortOrder: Int = 0 // 預設排序順序。
    ) {
        self.name = name
        self.icon = icon
        self.targetMuscle = targetMuscle
        self.createdAt = Date.now // 設定創建時間為當前時間。
        self.isCustom = isCustom
        self.sortOrder = sortOrder
        self.sessions = [] // 初始化運動紀錄為空陣列。
    }
}

// MARK: - WorkoutSession (單次運動紀錄)

@Model // 標記為 SwiftData 的模型。
final class WorkoutSession { // 定義單次運動紀錄的數據模型。
    // MARK: - Properties
    
    /// 運動開始時間
    var startTime: Date // 運動的開始時間。
    
    /// 運動結束時間
    var endTime: Date? // 運動的結束時間，可選。
    
    /// 完成次數
    var repCount: Int // 運動完成的次數。
    
    /// 備註
    var notes: String? // 運動的備註，可選。
    
    /// 是否已完成
    var isCompleted: Bool // 運動是否已完成。
    
    // MARK: - Relationships
    
    /// 關聯的運動類型 (多對一關係)
    var exerciseType: ExerciseType? // 與此運動紀錄相關的運動類型。
    
    // MARK: - Computed Properties
    
    /// 運動時長 (秒)
    var duration: TimeInterval {
        guard let endTime else { return 0 } // 如果沒有結束時間，返回 0。
        return endTime.timeIntervalSince(startTime) // 計算運動的時長。
    }
    
    /// 格式化的運動時長
    var formattedDuration: String {
        let minutes = Int(duration) / 60 // 計算分鐘數。
        let seconds = Int(duration) % 60 // 計算秒數。
        return String(format: "%02d:%02d", minutes, seconds) // 返回格式化的時間字串。
    }
    
    /// 平均每次所需時間 (秒)
    var averageTimePerRep: TimeInterval {
        guard repCount > 0 else { return 0 } // 如果次數為 0，返回 0。
        return duration / Double(repCount) // 計算平均每次所需時間。
    }
    
    /// 運動日期 (去除時間部分)
    var workoutDate: Date {
        Calendar.current.startOfDay(for: startTime) // 返回運動的日期部分。
    }
    
    // MARK: - Initialization
    
    init(
        startTime: Date = Date.now, // 預設開始時間為當前時間。
        repCount: Int = 0, // 預設完成次數為 0。
        notes: String? = nil, // 預設備註為空。
        isCompleted: Bool = false // 預設未完成。
    ) {
        self.startTime = startTime
        self.repCount = repCount
        self.notes = notes
        self.isCompleted = isCompleted
    }
    
    // MARK: - Methods
    
    /// 完成運動
    func complete() {
        endTime = Date.now // 設定結束時間為當前時間。
        isCompleted = true // 標記為已完成。
    }
    
    /// 驗證資料完整性
    func validate() -> Bool {
        guard repCount > 0 else { return false } // 確保次數大於 0。
        guard let endTime, endTime > startTime else { return false } // 確保結束時間晚於開始時間。
        return true // 資料有效。
    }
}
