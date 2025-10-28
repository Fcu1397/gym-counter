//
//  DailyGoalWidget.swift
//  gym-counter
//

import WidgetKit // 匯入 WidgetKit 框架，用於構建小工具
import SwiftUI // 匯入 SwiftUI 框架，用於構建用戶界面
import SwiftData // 匯入 SwiftData 框架，用於數據管理

// MARK: - Daily Goal Widget Entry

struct DailyGoalEntry: TimelineEntry { // 定義每日目標的時間軸條目
    let date: Date // 條目包含的日期
    let todayReps: Int // 今日完成的次數
    let goalReps: Int // 每日目標次數
    let completionPercentage: Double // 完成百分比
}

// MARK: - Daily Goal Timeline Provider

struct DailyGoalProvider: TimelineProvider { // 定義時間軸提供者
    
    func placeholder(in context: Context) -> DailyGoalEntry { // 提供佔位符條目
        DailyGoalEntry( // 返回佔位符條目
            date: Date.now, // 當前日期
            todayReps: 50, // 預設今日完成次數
            goalReps: 100, // 預設每日目標次數
            completionPercentage: 0.5 // 預設完成百分比
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailyGoalEntry) -> Void) { // 提供快照條目
        Task { // 使用異步任務
            let entry = await fetchDailyGoal() // 獲取每日目標條目
            completion(entry) // 返回條目
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyGoalEntry>) -> Void) { // 提供時間軸條目
        Task { // 使用異步任務
            let entry = await fetchDailyGoal() // 獲取每日目標條目
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date.now)! // 設置下一次更新時間為 30 分鐘後
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // 創建時間軸，包含條目和更新策略
            completion(timeline) // 返回時間軸
        }
    }
    
    private func fetchDailyGoal() async -> DailyGoalEntry { // 獲取每日目標條目
        do {
            let container = try createSharedContainer() // 創建共享數據容器
            let context = ModelContext(container) // 創建數據上下文
            
            let todayStart = Calendar.current.startOfDay(for: Date.now) // 獲取今天的開始時間
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>( // 定義查詢描述符
                sortBy: [.init(\.startTime, order: .reverse)] // 按開始時間倒序排列
            )
            let allSessions = try context.fetch(sessionDescriptor) // 查詢所有運動紀錄
            
            let todaySessions = allSessions.filter { $0.startTime >= todayStart } // 過濾出今天的運動紀錄
            let todayReps = todaySessions.reduce(0) { $0 + $1.repCount } // 計算今日完成次數
            
            let goalReps = 100 // 設定每日目標次數
            let percentage = min(Double(todayReps) / Double(goalReps), 1.0) // 計算完成百分比
            
            return DailyGoalEntry( // 返回每日目標條目
                date: Date.now, // 當前日期
                todayReps: todayReps, // 今日完成次數
                goalReps: goalReps, // 每日目標次數
                completionPercentage: percentage // 完成百分比
            )
            
        } catch {
            print("❌ DailyGoal Widget 讀取失敗: \(error)") // 打印錯誤信息
        }
        
        return DailyGoalEntry( // 返回默認條目
            date: Date.now, // 當前日期
            todayReps: 0, // 默認今日完成次數
            goalReps: 100, // 默認每日目標次數
            completionPercentage: 0 // 默認完成百分比
        )
    }
    
    private func createSharedContainer() throws -> ModelContainer { // 創建共享數據容器
        let schema = Schema([ // 定義數據模型結構
            ExerciseType.self, // 包括運動類型模型
            WorkoutSession.self // 包括運動紀錄模型
        ])
        
        let modelConfiguration = ModelConfiguration( // 配置數據容器
            schema: schema, // 使用定義的數據結構
            isStoredInMemoryOnly: false, // 是否僅存儲在內存中
            groupContainer: .identifier("group.com.buildwithashton.gym-counter"), // 使用 App Group 共享容器
            cloudKitDatabase: .none // 不使用 CloudKit
        )
        
        return try ModelContainer( // 嘗試創建數據容器
            for: schema, // 使用定義的數據結構
            configurations: [modelConfiguration] // 使用配置
        )
    }
}

// MARK: - Daily Goal Widget View

struct DailyGoalWidgetView: View { // 定義每日目標小工具的視圖
    var entry: DailyGoalEntry // 條目數據
    
    var body: some View { // 視圖內容
        VStack(spacing: 10) { // 使用垂直堆疊排列內容，間距為 10
            Text("今日目標") // 顯示標題文字
                .font(.caption) // 設置字體為標題樣式
                .foregroundStyle(.secondary) // 設置文字顏色為次要顏色
            
            ZStack { // 使用 ZStack 疊加視圖
                Circle() // 繪製背景圓形
                    .stroke(lineWidth: 8) // 設置圓形邊框寬度
                    .opacity(0.3) // 設置透明度
                    .foregroundStyle(.blue) // 設置顏色為藍色
                
                Circle() // 繪製進度圓形
                    .trim(from: 0.0, to: entry.completionPercentage) // 設置進度範圍
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round)) // 設置邊框樣式
                    .foregroundStyle(.blue) // 設置顏色為藍色
                    .rotationEffect(Angle(degrees: -90)) // 旋轉進度圓形
                    .animation(.easeInOut, value: entry.completionPercentage) // 添加動畫效果
                
                VStack(spacing: 2) { // 使用垂直堆疊顯示數據
                    Text("\(entry.todayReps)") // 顯示今日完成次數
                        .font(.system(size: 28, weight: .bold, design: .rounded)) // 設置字體樣式
                    Text("/ \(entry.goalReps)") // 顯示每日目標次數
                        .font(.caption2) // 設置字體為說明樣式
                        .foregroundStyle(.secondary) // 設置文字顏色為次要顏色
                }
            }
            .frame(width: 100, height: 100) // 設置視圖大小
            
            Text("\(Int(entry.completionPercentage * 100))% 完成") // 顯示完成百分比
                .font(.caption2) // 設置字體為說明樣式
                .foregroundStyle(.secondary) // 設置文字顏色為次要顏色
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 設置視圖填滿可用空間
        .containerBackground(.fill.tertiary, for: .widget) // 設置背景顏色為三級填充
        .widgetURL(URL(string: "gymcounter://stats")) // 設置小工具的深層鏈接 URL
    }
}

// MARK: - Widget Configuration

struct DailyGoalWidget: Widget { // 定義每日目標小工具
    let kind: String = "DailyGoalWidget" // 小工具的唯一標識符
    
    var body: some WidgetConfiguration { // 配置小工具
        StaticConfiguration( // 使用靜態配置
            kind: kind, // 設置標識符
            provider: DailyGoalProvider() // 設置時間軸提供者
        ) { entry in
            DailyGoalWidgetView(entry: entry) // 設置小工具的視圖
        }
        .configurationDisplayName("今日目標") // 設置小工具的顯示名稱
        .description("追蹤你的每日運動目標進度") // 設置小工具的描述
        .supportedFamilies([.systemSmall]) // 支援的小工具尺寸類型
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) { // 預覽小工具，尺寸為小
    DailyGoalWidget() // 預覽每日目標小工具
} timeline: {
    DailyGoalEntry( // 預覽使用的條目數據
        date: Date.now, // 當前日期
        todayReps: 75, // 預設今日完成次數
        goalReps: 100, // 預設每日目標次數
        completionPercentage: 0.75 // 預設完成百分比
    )
}
