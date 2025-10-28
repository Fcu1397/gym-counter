//
//  AddExerciseWidget.swift
//  gym-counter
//

import WidgetKit // 匯入 WidgetKit 框架，用於構建小工具
import SwiftUI // 匯入 SwiftUI 框架，用於構建用戶界面

// MARK: - Add Exercise Widget Entry

struct AddExerciseEntry: TimelineEntry { // 定義新增運動的時間軸條目
    let date: Date // 條目包含的日期
}

// MARK: - Add Exercise Timeline Provider

struct AddExerciseProvider: TimelineProvider { // 定義時間軸提供者
    
    func placeholder(in context: Context) -> AddExerciseEntry { // 提供佔位符條目
        AddExerciseEntry(date: Date.now) // 返回當前日期的條目
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AddExerciseEntry) -> Void) { // 提供快照條目
        completion(AddExerciseEntry(date: Date.now)) // 返回當前日期的條目
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AddExerciseEntry>) -> Void) { // 提供時間軸條目
        let entry = AddExerciseEntry(date: Date.now) // 創建當前日期的條目
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 24, to: Date.now)! // 設置下一次更新時間為 24 小時後
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // 創建時間軸，包含條目和更新策略
        completion(timeline) // 返回時間軸
    }
}

// MARK: - Add Exercise Widget View

struct AddExerciseWidgetView: View { // 定義新增運動小工具的視圖
    var entry: AddExerciseEntry // 條目數據
    
    var body: some View { // 視圖內容
        VStack(spacing: 12) { // 使用垂直堆疊排列內容，間距為 12
            Image(systemName: "plus.circle.fill") // 顯示加號圖示
                .font(.system(size: 50)) // 設置圖示大小為 50
                .foregroundStyle(.green) // 設置圖示顏色為綠色
            
            Text("新增運動") // 顯示標題文字
                .font(.headline) // 設置字體為標題樣式
                .foregroundStyle(.primary) // 設置文字顏色為主要顏色
            
            Text("快速新增項目") // 顯示描述文字
                .font(.caption) // 設置字體為說明樣式
                .foregroundStyle(.secondary) // 設置文字顏色為次要顏色
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 設置視圖填滿可用空間
        .containerBackground(.fill.tertiary, for: .widget) // 設置背景顏色為三級填充
        .widgetURL(URL(string: "gymcounter://add-exercise")) // 設置小工具的深層鏈接 URL
    }
}

// MARK: - Widget Configuration

struct AddExerciseWidget: Widget { // 定義新增運動小工具
    let kind: String = "AddExerciseWidget" // 小工具的唯一標識符
    
    var body: some WidgetConfiguration { // 配置小工具
        StaticConfiguration( // 使用靜態配置
            kind: kind, // 設置標識符
            provider: AddExerciseProvider() // 設置時間軸提供者
        ) { entry in
            AddExerciseWidgetView(entry: entry) // 設置小工具的視圖
        }
        .configurationDisplayName("新增運動") // 設置小工具的顯示名稱
        .description("快速開啟新增運動頁面") // 設置小工具的描述
        .supportedFamilies([.systemSmall]) // 支援的小工具尺寸類型
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) { // 預覽小工具，尺寸為小
    AddExerciseWidget() // 預覽新增運動小工具
} timeline: {
    AddExerciseEntry(date: Date.now) // 預覽使用的條目數據
}
