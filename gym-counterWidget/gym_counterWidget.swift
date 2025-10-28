//
//  GymCounterWidget.swift
//  gym-counter
//
//  這個檔案定義了 Gym Counter 應用程式的小工具，包括其資料模型、時間軸提供者和視圖。

import WidgetKit // 匯入 WidgetKit 框架以建立小工具。
import SwiftUI // 匯入 SwiftUI 框架以構建使用者介面。
import SwiftData // 匯入 SwiftData 以進行資料管理。
import Charts // 匯入 Charts 以建立資料視覺化。

// MARK: - Widget Entry

// 表示小工具條目的資料結構。
struct WorkoutEntry: TimelineEntry {
    let date: Date // 條目的日期。
    let totalWorkouts: Int // 完成的總運動次數。
    let todayWorkouts: Int // 今天完成的運動次數。
    let totalReps: Int // 完成的總重複次數。
    let recentExercise: ExerciseType? // 最近的運動類型。
    let dailyRepsForChart: [(day: String, reps: Int)] // 用於顯示每日重複次數的圖表資料。
}

// MARK: - Timeline Provider

// 提供小工具的時間軸。
struct WorkoutTimelineProvider: TimelineProvider {
    
    // 返回小工具的佔位符條目。
    func placeholder(in context: Context) -> WorkoutEntry {
        WorkoutEntry(
            date: Date.now, // 當前日期。
            totalWorkouts: 0, // 佔位符的總運動次數。
            todayWorkouts: 0, // 佔位符的今天運動次數。
            totalReps: 0, // 佔位符的總重複次數。
            recentExercise: nil, // 佔位符中沒有最近的運動。
            dailyRepsForChart: [] // 空的圖表資料。
        )
    }
    
    // 返回小工具的快照條目。
    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> Void) {
        Task {
            let entry = await fetchWorkoutData() // 非同步獲取運動資料。
            completion(entry) // 將獲取的資料傳遞給完成處理器。
        }
    }
    
    // 返回小工具的時間軸。
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutEntry>) -> Void) {
        Task {
            let entry = await fetchWorkoutData() // 非同步獲取運動資料。
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date.now)! // 設定下一次更新為 15 分鐘後。
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // 使用獲取的條目建立時間軸。
            
            completion(timeline) // 將時間軸傳遞給完成處理器。
        }
    }
    
    // 獲取小工具的運動資料。
    private func fetchWorkoutData() async -> WorkoutEntry {
        do {
            let container = try createSharedContainer() // 建立共享資料容器。
            let context = ModelContext(container) // 建立資料操作的模型上下文。
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                sortBy: [.init(\.startTime, order: .reverse)] // 按開始時間降序排序運動會話。
            )
            let allSessions = try context.fetch(sessionDescriptor) // 獲取所有運動會話。
            
            let todayStart = Calendar.current.startOfDay(for: Date.now) // 獲取今天的開始時間。
            let todaySessions = allSessions.filter { $0.startTime >= todayStart } // 篩選今天的會話。
            let totalReps = allSessions.reduce(0) { $0 + $1.repCount } // 計算總重複次數。
            let recentExercise = allSessions.first?.exerciseType // 獲取最近的運動類型。
            
            let dailyReps = calculateDailyReps(for: allSessions) // 計算圖表的每日重複次數。
            
            print("✅ Widget 資料讀取成功: \(allSessions.count) 筆紀錄") // 日誌成功訊息。
            
            return WorkoutEntry(
                date: Date.now, // 當前日期。
                totalWorkouts: allSessions.count, // 總運動次數。
                todayWorkouts: todaySessions.count, // 今天的運動次數。
                totalReps: totalReps, // 總重複次數。
                recentExercise: recentExercise, // 最近的運動類型。
                dailyRepsForChart: dailyReps // 圖表的資料。
            )
            
        } catch {
            print("❌ Widget 讀取資料失敗: \(error)") // 日誌錯誤訊息。
            return WorkoutEntry(
                date: Date.now, // 當前日期。
                totalWorkouts: 0, // 預設的總運動次數。
                todayWorkouts: 0, // 預設的今天運動次數。
                totalReps: 0, // 預設的總重複次數。
                recentExercise: nil, // 沒有最近的運動。
                dailyRepsForChart: [] // 空的圖表資料。
            )
        }
    }
    
    // 計算圖表的每日重複次數。
    private func calculateDailyReps(for sessions: [WorkoutSession]) -> [(day: String, reps: Int)] {
        let calendar = Calendar.current // 獲取當前日曆。
        let today = calendar.startOfDay(for: Date.now) // 獲取今天的開始時間。
        var dailyData: [Date: Int] = [:] // 初始化每日資料的字典。
        
        for i in 0..<7 { // 遍歷最近 7 天。
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dailyData[date] = 0 // 初始化每日資料為零重複次數。
            }
        }
        
        for session in sessions { // 遍歷所有運動會話。
            let sessionDay = calendar.startOfDay(for: session.startTime) // 獲取會話的開始日期。
            if dailyData[sessionDay] != nil {
                dailyData[sessionDay, default: 0] += session.repCount // 將重複次數加到對應的日期。
            }
        }
        
        let dateFormatter = DateFormatter() // 建立日期格式化器。
        dateFormatter.dateFormat = "EEE" // 設定日期格式為星期縮寫。
        
        return dailyData.sorted(by: { $0.key < $1.key }).map {
            (day: dateFormatter.string(from: $0.key), reps: $0.value) // 將每日資料轉換為元組陣列。
        }
    }
    
    // 建立小工具的共享資料容器。
    private func createSharedContainer() throws -> ModelContainer {
        let schema = Schema([
            ExerciseType.self, // 使用 ExerciseType 定義架構。
            WorkoutSession.self // 使用 WorkoutSession 定義架構。
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

// MARK: - Widget View

// 定義小工具的主要視圖。
struct GymCounterWidgetView: View {
    var entry: WorkoutEntry // 小工具的資料條目。
    
    @Environment(\.widgetFamily) var widgetFamily // 從環境中獲取小工具系列。
    
    var body: some View {
        switch widgetFamily { // 根據小工具系列渲染視圖。
        case .systemSmall:
            SmallWidgetView(entry: entry) // 渲染小型小工具視圖。
        case .systemMedium:
            MediumWidgetView(entry: entry) // 渲染中型小工具視圖。
        case .systemLarge:
            LargeWidgetView(entry: entry) // 渲染大型小工具視圖。
        default:
            SmallWidgetView(entry: entry) // 預設為小型小工具視圖。
        }
    }
}

// MARK: - Small Widget

// 定義小型小工具視圖。
struct SmallWidgetView: View {
    let entry: WorkoutEntry // 小工具的資料條目。
    
    var body: some View {
        VStack(spacing: 8) { // 垂直排列元素，間距為 8。
            Image(systemName: "figure.strengthtraining.traditional") // 顯示圖示。
                .font(.system(size: 32)) // 設定字體大小。
                .foregroundStyle(.green) // 設定圖示顏色。
            
            Text("\(entry.todayWorkouts)") // 顯示今天的運動次數。
                .font(.system(size: 48, weight: .bold, design: .rounded)) // 設定字體樣式。
            
            Text("今日運動") // 顯示標籤。
                .font(.caption) // 設定字體大小。
                .foregroundStyle(.secondary) // 設定文字顏色。
        }
        .containerBackground(.fill.tertiary, for: .widget) // 設定背景樣式。
        .widgetURL(URL(string: "gymcounter://stats")) // 設定小工具 URL。
    }
}

// MARK: - Medium Widget

// 定義中型小工具視圖。
struct MediumWidgetView: View {
    let entry: WorkoutEntry // 小工具的資料條目
    
    var body: some View {
        HStack(spacing: 20) { // 水平排列元素，間距為 20
            VStack(alignment: .leading, spacing: 4) { // 左側欄位
                Label("今日運動", systemImage: "calendar") // 今日運動的標籤
                    .font(.caption) // 標籤的字體大小
                    .foregroundStyle(.secondary) // 標籤的顏色
                
                Text("\(entry.todayWorkouts)") // 顯示今天的運動次數
                    .font(.system(size: 36, weight: .bold, design: .rounded)) // 數字的字體樣式
            }
            
            Divider() // 左右欄位之間的分隔線
            
            VStack(alignment: .leading, spacing: 4) { // 右側欄位
                Label("總次數", systemImage: "number") // 總重複次數的標籤
                    .font(.caption) // 標籤的字體大小
                    .foregroundStyle(.secondary) // 標籤的顏色
                
                Text("\(entry.totalReps)") // 顯示總重複次數
                    .font(.system(size: 36, weight: .bold, design: .rounded)) // 數字的字體樣式
            }
            
            Spacer() // 使內容推到兩側的間距
        }
        .padding() // 內容周圍的內距
        .containerBackground(.fill.tertiary, for: .widget) // 設定背景樣式
        .widgetURL(URL(string: "gymcounter://stats")) // 設定小工具 URL
    }
}

// MARK: - Large Widget

// 定義大型小工具視圖。
struct LargeWidgetView: View {
    let entry: WorkoutEntry // 小工具的資料條目
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // 垂直排列元素，間距為 12
            HStack { // 標題區域
                Image(systemName: "figure.strengthtraining.traditional") // 顯示圖示
                    .font(.title) // 圖示的字體大小
                    .foregroundStyle(.green) // 圖示的顏色
                
                Text("最近 7 天活動") // 小工具的標題
                    .font(.title2.bold()) // 標題的字體樣式
                
                Spacer() // 使內容推到兩側的間距
            }
            
            if entry.dailyRepsForChart.isEmpty || entry.dailyRepsForChart.allSatisfy({ $0.reps == 0 }) {
                // 檢查是否有足夠的資料來顯示圖表
                VStack {
                    Spacer() // 使內容垂直置中
                    Text("沒有足夠的數據來顯示圖表") // 顯示資料不足的訊息
                        .font(.subheadline) // 訊息的字體大小
                        .foregroundStyle(.secondary) // 訊息的顏色
                    Spacer() // 使內容垂直置中
                }
            } else {
                // 建立圖表以顯示資料
                Chart(entry.dailyRepsForChart, id: \.day) { dataPoint in
                    BarMark(
                        x: .value("日期", dataPoint.day), // X 軸的值
                        y: .value("次數", dataPoint.reps) // Y 軸的值
                    )
                    .foregroundStyle(.green) // 長條的顏色
                    .cornerRadius(6) // 長條的圓角
                }
                .chartYAxis {
                    AxisMarks(position: .leading) // Y 軸的刻度標記
                }
            }
            
            HStack(spacing: 20) { // 統計數據區域
                StatBlock(
                    title: "今日運動", // 今日運動的標題
                    value: "\(entry.todayWorkouts)", // 今日運動的數值
                    icon: "calendar" // 今日運動的圖示
                )
                
                StatBlock(
                    title: "總次數", // 總重複次數的標題
                    value: "\(entry.totalReps)", // 總重複次數的數值
                    icon: "number" // 總重複次數的圖示
                )
            }
        }
        .padding() // 內容周圍的內距
        .containerBackground(.fill.tertiary, for: .widget) // 設定背景樣式
        .widgetURL(URL(string: "gymcounter://stats")) // 設定小工具 URL
    }
}

// MARK: - Stat Block Component

// 定義一個用於顯示統計數據的元件。
struct StatBlock: View {
    let title: String // 統計數據的標題
    let value: String // 統計數據的數值
    let icon: String // 與統計數據相關聯的圖示
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon) // 統計數據的標籤
                .font(.caption) // 標籤的字體大小
                .foregroundStyle(.secondary) // 標籤的顏色
            
            Text(value) // 顯示統計數據的數值
                .font(.title3.bold()) // 數值的字體樣式
                .lineLimit(1) // 限制行數
                .minimumScaleFactor(0.5) // 最小縮放因子
        }
        .frame(maxWidth: .infinity, alignment: .leading) // 框架設定
        .padding(12) // 元件內部的內距
        .background(.fill.secondary) // 背景樣式
        .cornerRadius(12) // 圓角半徑
    }
}

// MARK: - Widget Configuration

// 定義小工具的配置。
struct gym_counterWidget: Widget {
    let kind: String = "gym_counterWidget" // 小工具的識別類型
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WorkoutTimelineProvider() // 小工具的時間軸提供者
        ) { entry in
            GymCounterWidgetView(entry: entry) // 小工具的視圖
        }
        .configurationDisplayName("運動統計") // 小工具的顯示名稱
        .description("追蹤你的運動進度") // 小工具功能的描述
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge]) // 支援的小工具系列
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    gym_counterWidget()
} timeline: {
    WorkoutEntry(
        date: Date.now,
        totalWorkouts: 15,
        todayWorkouts: 3,
        totalReps: 450,
        recentExercise: nil,
        dailyRepsForChart: []
    )
}

#Preview(as: .systemMedium) {
    gym_counterWidget()
} timeline: {
    WorkoutEntry(
        date: Date.now,
        totalWorkouts: 15,
        todayWorkouts: 3,
        totalReps: 450,
        recentExercise: nil,
        dailyRepsForChart: []
    )
}

#Preview(as: .systemLarge) {
    gym_counterWidget()
} timeline: {
    let sampleChartData = [
        (day: "Mon", reps: 50),
        (day: "Tue", reps: 80),
        (day: "Wed", reps: 60),
        (day: "Thu", reps: 120),
        (day: "Fri", reps: 90),
        (day: "Sat", reps: 150),
        (day: "Sun", reps: 70)
    ]
    WorkoutEntry(
        date: Date.now,
        totalWorkouts: 15,
        todayWorkouts: 3,
        totalReps: 450,
        recentExercise: nil,
        dailyRepsForChart: sampleChartData
    )
}
