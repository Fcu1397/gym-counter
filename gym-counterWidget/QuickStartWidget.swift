//
//  QuickStartWidget.swift
//  gym-counter
//
//  快速開始運動 Widget
//

import WidgetKit // 匯入 WidgetKit 框架以建立小工具。
import SwiftUI // 匯入 SwiftUI 框架以構建使用者介面。
import SwiftData // 匯入 SwiftData 以進行資料管理。

// MARK: - Quick Start Widget Entry

// 定義快速開始小工具的資料結構。
struct QuickStartEntry: TimelineEntry {
    let date: Date // 條目的日期。
    let recentExerciseName: String? // 最近運動的名稱。
    let recentExerciseIcon: String? // 最近運動的圖示。
}

// MARK: - Quick Start Timeline Provider

// 提供快速開始小工具的時間軸。
struct QuickStartProvider: TimelineProvider {
    
    // 返回小工具的佔位符條目。
    func placeholder(in context: Context) -> QuickStartEntry {
        QuickStartEntry(
            date: Date.now, // 當前日期。
            recentExerciseName: "伏地挺身", // 預設的最近運動名稱。
            recentExerciseIcon: "figure.arms.open" // 預設的最近運動圖示。
        )
    }
    
    // 返回小工具的快照條目。
    func getSnapshot(in context: Context, completion: @escaping (QuickStartEntry) -> Void) {
        Task {
            let entry = await fetchRecentExercise() // 非同步獲取最近的運動資料。
            completion(entry) // 將獲取的資料傳遞給完成處理器。
        }
    }
    
    // 返回小工具的時間軸。
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickStartEntry>) -> Void) {
        Task {
            let entry = await fetchRecentExercise() // 非同步獲取最近的運動資料。
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date.now)! // 設定下一次更新為 1 小時後。
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // 使用獲取的條目建立時間軸。
            completion(timeline) // 將時間軸傳遞給完成處理器。
        }
    }
    
    // 獲取最近的運動資料。
    private func fetchRecentExercise() async -> QuickStartEntry {
        do {
            let container = try createSharedContainer() // 建立共享資料容器。
            let context = ModelContext(container) // 建立資料操作的模型上下文。
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                sortBy: [.init(\.startTime, order: .reverse)] // 按開始時間降序排序運動會話。
            )
            let sessions = try context.fetch(sessionDescriptor) // 獲取所有運動會話。
            
            if let recent = sessions.first, let exerciseType = recent.exerciseType { // 獲取最近的運動類型。
                return QuickStartEntry(
                    date: Date.now, // 當前日期。
                    recentExerciseName: exerciseType.name, // 最近運動的名稱。
                    recentExerciseIcon: exerciseType.icon // 最近運動的圖示。
                )
            }
            
        } catch {
            print("❌ QuickStart Widget 讀取失敗: \(error)") // 日誌錯誤訊息。
        }
        
        return QuickStartEntry(
            date: Date.now, // 當前日期。
            recentExerciseName: nil, // 預設為無最近運動名稱。
            recentExerciseIcon: nil // 預設為無最近運動圖示。
        )
    }
    
    // 建立共享資料容器。
    private func createSharedContainer() throws -> ModelContainer {
        let schema = Schema([
            ExerciseType.self, // 定義架構中的運動類型。
            WorkoutSession.self // 定義架構中的運動會話。
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema, // 設定架構。
            isStoredInMemoryOnly: false, // 持久化儲存資料。
            groupContainer: .identifier("group.com.buildwithashton.gym-counter"), // 設定群組容器識別碼。
            cloudKitDatabase: .none // 禁用 CloudKit 資料庫。
        )
        
        return try ModelContainer(
            for: schema, // 為架構建立模型容器。
            configurations: [modelConfiguration] // 使用指定的配置。
        )
    }
}

// MARK: - Quick Start Widget View

// 定義快速開始小工具的主要視圖。
struct QuickStartWidgetView: View {
    var entry: QuickStartEntry // 小工具的資料條目。
    
    var body: some View {
        VStack(spacing: 12) { // 垂直排列元素，間距為 12。
            Image(systemName: entry.recentExerciseIcon ?? "figure.run") // 顯示最近運動的圖示，預設為跑步圖示。
                .font(.system(size: 40)) // 設定圖示的字體大小。
                .foregroundStyle(.orange) // 設定圖示的顏色。
            
            Text("快速開始") // 顯示標題。
                .font(.headline) // 設定標題的字體樣式。
                .foregroundStyle(.primary) // 設定標題的顏色。
            
            if let name = entry.recentExerciseName { // 如果有最近運動的名稱。
                Text(name) // 顯示最近運動的名稱。
                    .font(.caption) // 設定名稱的字體大小。
                    .foregroundStyle(.secondary) // 設定名稱的顏色。
                    .lineLimit(1) // 限制名稱的行數為 1。
            } else {
                Text("開始運動") // 顯示預設的提示文字。
                    .font(.caption) // 設定提示文字的字體大小。
                    .foregroundStyle(.secondary) // 設定提示文字的顏色。
            }
            
            Image(systemName: "arrow.right.circle.fill") // 顯示箭頭圖示。
                .font(.title3) // 設定箭頭的字體大小。
                .foregroundStyle(.orange.opacity(0.7)) // 設定箭頭的顏色和透明度。
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 設定視圖的最大寬度和高度。
        .containerBackground(.fill.tertiary, for: .widget) // 設定背景樣式。
        .widgetURL(URL(string: "gymcounter://exercise")) // 設定小工具的 URL。
    }
}

// MARK: - Widget Configuration

// 定義快速開始小工具的配置。
struct QuickStartWidget: Widget {
    let kind: String = "QuickStartWidget" // 小工具的識別類型。
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind, // 設定小工具的識別類型。
            provider: QuickStartProvider() // 設定小工具的時間軸提供者。
        ) { entry in
            QuickStartWidgetView(entry: entry) // 設定小工具的視圖。
        }
        .configurationDisplayName("快速開始") // 設定小工具的顯示名稱。
        .description("快速開始你最近的運動") // 設定小工具的描述。
        .supportedFamilies([.systemSmall]) // 設定支援的小工具系列。
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) { // 定義小工具的預覽。
    QuickStartWidget() // 預覽快速開始小工具。
} timeline: {
    QuickStartEntry(
        date: Date.now, // 當前日期。
        recentExerciseName: "伏地挺身", // 預設的最近運動名稱。
        recentExerciseIcon: "figure.arms.open" // 預設的最近運動圖示。
    )
}
