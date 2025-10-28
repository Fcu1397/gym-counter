//
//  StatisticsWidget.swift
//  gym-counter
//
//  統計資料快捷 Widget
//

import WidgetKit // 匯入 WidgetKit 框架以建立小工具。
import SwiftUI // 匯入 SwiftUI 框架以構建使用者介面。

// MARK: - Statistics Widget Entry

// 定義統計資料小工具的資料結構。
struct StatisticsEntry: TimelineEntry {
    let date: Date // 條目的日期。
}

// MARK: - Statistics Timeline Provider

// 提供統計資料小工具的時間軸。
struct StatisticsProvider: TimelineProvider {
    
    // 返回小工具的佔位符條目。
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(date: Date.now) // 使用當前日期作為佔位符條目。
    }
    
    // 返回小工具的快照條目。
    func getSnapshot(in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        completion(StatisticsEntry(date: Date.now)) // 返回當前日期的快照條目。
    }
    
    // 返回小工具的時間軸。
    func getTimeline(in context: Context, completion: @escaping (Timeline<StatisticsEntry>) -> Void) {
        let entry = StatisticsEntry(date: Date.now) // 建立當前日期的條目。
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 24, to: Date.now)! // 設定下一次更新為 24 小時後。
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // 使用條目建立時間軸。
        completion(timeline) // 將時間軸傳遞給完成處理器。
    }
}

// MARK: - Statistics Widget View

// 定義統計資料小工具的主要視圖。
struct StatisticsWidgetView: View {
    var entry: StatisticsEntry // 小工具的資料條目
    
    var body: some View {
        VStack(spacing: 12) { // 垂直排列元素，間距為 12
            Image(systemName: "chart.bar.fill") // 顯示統計圖表的圖示
                .font(.system(size: 50)) // 設定圖示的字體大小
                .foregroundStyle(.cyan) // 設定圖示的顏色
            
            Text("統計資料") // 顯示標題
                .font(.headline) // 設定標題的字體樣式
                .foregroundStyle(.primary) // 設定標題的顏色
            
            Text("查看詳細數據") // 顯示描述文字
                .font(.caption) // 設定描述文字的字體大小
                .foregroundStyle(.secondary) // 設定描述文字的顏色
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 設定視圖的最大寬度和高度
        .containerBackground(.fill.tertiary, for: .widget) // 設定背景樣式
        .widgetURL(URL(string: "gymcounter://statistics")) // 設定小工具的 URL
    }
}

// MARK: - Widget Configuration

// 定義統計資料小工具的配置。
struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget" // 小工具的識別類型
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind, // 設定小工具的識別類型
            provider: StatisticsProvider() // 設定小工具的時間軸提供者
        ) { entry in
            StatisticsWidgetView(entry: entry) // 設定小工具的視圖
        }
        .configurationDisplayName("統計資料") // 設定小工具的顯示名稱
        .description("快速查看統計資料頁面") // 設定小工具的描述
        .supportedFamilies([.systemSmall]) // 設定支援的小工具系列
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) { // 定義小工具的預覽
    StatisticsWidget() // 預覽統計資料小工具
} timeline: {
    StatisticsEntry(date: Date.now) // 使用當前日期作為預覽條目
}
