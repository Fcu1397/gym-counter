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
    @Attribute(.unique) var name: String // 運動的名稱，必須唯一
    
    /// 圖示名稱 (SF Symbols)
    var icon: String // 運動的圖示名稱，使用 SF Symbols
    
    /// 目標肌群
    var targetMuscle: String // 運動的目標肌群描述
    
    /// 創建時間
    var createdAt: Date // 運動的創建時間
    
    /// 是否為自訂運動
    var isCustom: Bool // 是否為用戶自定義的運動
    
    /// 排序順序 (用於列表顯示)
    var sortOrder: Int // 運動的排序順序，用於顯示
    
    // MARK: - Relationships
    
    /// 關聯的所有運動紀錄 (一對多關係)
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.exerciseType)
    var sessions: [WorkoutSession] // 與運動紀錄的關聯
    
    // MARK: - Computed Properties
    
    /// 總運動次數
    var totalReps: Int {
        sessions.reduce(0) { $0 + $1.repCount } // 計算所有紀錄的總次數
    }
    
    /// 總運動時長 (秒)
    var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration } // 計算所有紀錄的總時長
    }
    
    /// 最近一次運動時間
    var lastWorkoutDate: Date? {
        sessions.max(by: { $0.startTime < $1.startTime })?.startTime // 找到最近的運動時間
    }
    
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
        self.createdAt = Date.now // 設置創建時間為當前時間
        self.isCustom = isCustom
        self.sortOrder = sortOrder
        self.sessions = [] // 初始化關聯的運動紀錄為空陣列
    }
}

// MARK: - WorkoutSession (單次運動紀錄)

@Model
final class WorkoutSession {
    // MARK: - Properties
    
    /// 運動開始時間
    var startTime: Date // 運動的開始時間
    
    /// 運動結束時間
    var endTime: Date? // 運動的結束時間，可選
    
    /// 完成次數
    var repCount: Int // 運動完成的次數
    
    /// 備註
    var notes: String? // 運動的備註信息
    
    /// 是否已完成
    var isCompleted: Bool // 運動是否已完成
    
    // MARK: - Relationships
    
    /// 關聯的運動類型 (多對一關係)
    var exerciseType: ExerciseType? // 與運動類型的關聯
    
    // MARK: - Computed Properties
    
    /// 運動時長 (秒)
    var duration: TimeInterval {
        guard let endTime else { return 0 } // 如果結束時間為空，返回 0
        return endTime.timeIntervalSince(startTime) // 計算運動時長
    }
    
    /// 格式化的運動時長
    var formattedDuration: String {
        let minutes = Int(duration) / 60 // 計算分鐘數
        let seconds = Int(duration) % 60 // 計算秒數
        return String(format: "%02d:%02d", minutes, seconds) // 返回格式化的時間
    }
    
    /// 平均每次所需時間 (秒)
    var averageTimePerRep: TimeInterval {
        guard repCount > 0 else { return 0 } // 如果次數為 0，返回 0
        return duration / Double(repCount) // 計算平均每次所需時間
    }
    
    /// 運動日期 (去除時間部分)
    var workoutDate: Date {
        Calendar.current.startOfDay(for: startTime) // 返回運動的日期部分
    }
    
    // MARK: - Initialization
    
    init(
        startTime: Date = Date.now,
        repCount: Int = 0,
        notes: String? = nil,
        isCompleted: Bool = false
    ) {
        self.startTime = startTime
        self.repCount = repCount
        self.notes = notes
        self.isCompleted = isCompleted
    }
    
    // MARK: - Methods
    
    /// 完成運動
    func complete() {
        endTime = Date.now // 設置結束時間為當前時間
        isCompleted = true // 設置為已完成
    }
    
    /// 驗證資料完整性
    func validate() -> Bool {
        guard repCount > 0 else { return false } // 確保次數大於 0
        guard let endTime, endTime > startTime else { return false } // 確保結束時間有效
        return true // 返回驗證結果
    }
}

// MARK: - Sample Data (用於 Preview 和測試)

extension ExerciseType {
    /// 預設運動類型範例
    static var sampleExercises: [ExerciseType] {
        [
            ExerciseType(name: "伏地挺身", icon: "figure.arms.open", targetMuscle: "胸肌、三頭肌", sortOrder: 1),
            ExerciseType(name: "深蹲", icon: "figure.flexibility", targetMuscle: "腿部、臀部", sortOrder: 2),
            ExerciseType(name: "仰臥起坐", icon: "figure.core.training", targetMuscle: "腹肌", sortOrder: 3),
            ExerciseType(name: "引體向上", icon: "figure.climbing", targetMuscle: "背肌、二頭肌", sortOrder: 4),
            ExerciseType(name: "平板支撐", icon: "figure.mind.and.body", targetMuscle: "核心肌群", sortOrder: 5)
        ]
    }
    
    /// 創建範例實例
    static func sample(name: String = "伏地挺身") -> ExerciseType {
        ExerciseType(name: name, icon: "figure.arms.open", targetMuscle: "胸肌")
    }
}

extension WorkoutSession {
    /// 創建範例實例
    static func sample(repCount: Int = 20, exercise: ExerciseType? = nil) -> WorkoutSession {
        let session = WorkoutSession(
            startTime: Date.now.addingTimeInterval(-600), // 10 分鐘前
            repCount: repCount
        )
        session.endTime = Date.now // 設置結束時間為當前時間
        session.exerciseType = exercise ?? ExerciseType.sample() // 設置關聯的運動類型
        session.isCompleted = true // 設置為已完成
        return session
    }
}

// MARK: - Extensions for Query and Sorting

extension ExerciseType {
    /// 按排序順序排序
    static var sortedByOrder: SortDescriptor<ExerciseType> {
        SortDescriptor(\.sortOrder) // 返回按排序順序的描述符
    }
    
    /// 按名稱排序
    static var sortedByName: SortDescriptor<ExerciseType> {
        SortDescriptor(\.name) // 返回按名稱排序的描述符
    }
    
    /// 按創建時間排序
    static var sortedByCreatedDate: SortDescriptor<ExerciseType> {
        SortDescriptor(\.createdAt, order: .reverse)
    }
}

extension WorkoutSession {
    /// 按時間排序 (最新優先)
    static var sortedByDate: SortDescriptor<WorkoutSession> {
        SortDescriptor(\.startTime, order: .reverse)
    }
    
    /// 按次數排序 (最多優先)
    static var sortedByReps: SortDescriptor<WorkoutSession> {
        SortDescriptor(\.repCount, order: .reverse)
    }
}
