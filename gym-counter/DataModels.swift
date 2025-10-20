//
//  DataModels.swift
//  GymCounter
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
    
    // MARK: - Relationships
    
    /// 關聯的所有運動紀錄 (一對多關係)
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.exerciseType)
    var sessions: [WorkoutSession]
    
    // MARK: - Computed Properties
    
    /// 總運動次數
    var totalReps: Int {
        sessions.reduce(0) { $0 + $1.repCount }
    }
    
    /// 總運動時長 (秒)
    var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    /// 最近一次運動時間
    var lastWorkoutDate: Date? {
        sessions.max(by: { $0.startTime < $1.startTime })?.startTime
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
        self.createdAt = Date.now
        self.isCustom = isCustom
        self.sortOrder = sortOrder
        self.sessions = []
    }
}

// MARK: - WorkoutSession (單次運動紀錄)

@Model
final class WorkoutSession {
    // MARK: - Properties
    
    /// 運動開始時間
    var startTime: Date
    
    /// 運動結束時間
    var endTime: Date?
    
    /// 完成次數
    var repCount: Int
    
    /// 備註
    var notes: String?
    
    /// 是否已完成
    var isCompleted: Bool
    
    // MARK: - Relationships
    
    /// 關聯的運動類型 (多對一關係)
    var exerciseType: ExerciseType?
    
    // MARK: - Computed Properties
    
    /// 運動時長 (秒)
    var duration: TimeInterval {
        guard let endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    
    /// 格式化的運動時長
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 平均每次所需時間 (秒)
    var averageTimePerRep: TimeInterval {
        guard repCount > 0 else { return 0 }
        return duration / Double(repCount)
    }
    
    /// 運動日期 (去除時間部分)
    var workoutDate: Date {
        Calendar.current.startOfDay(for: startTime)
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
        endTime = Date.now
        isCompleted = true
    }
    
    /// 驗證資料完整性
    func validate() -> Bool {
        guard repCount > 0 else { return false }
        guard let endTime, endTime > startTime else { return false }
        return true
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
        session.endTime = Date.now
        session.exerciseType = exercise ?? ExerciseType.sample()
        session.isCompleted = true
        return session
    }
}

// MARK: - Extensions for Query and Sorting

extension ExerciseType {
    /// 按排序順序排序
    static var sortedByOrder: SortDescriptor<ExerciseType> {
        SortDescriptor(\.sortOrder)
    }
    
    /// 按名稱排序
    static var sortedByName: SortDescriptor<ExerciseType> {
        SortDescriptor(\.name)
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
