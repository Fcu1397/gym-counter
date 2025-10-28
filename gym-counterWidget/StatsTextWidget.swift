//
//  StatsTextWidget.swift
//  gym-counter
//
//  顯示簡單統計文字的小工具
//

import WidgetKit // 匯入 WidgetKit 框架以建立小工具。
import SwiftUI // 匯入 SwiftUI 框架以構建使用者介面。

// MARK: - Stats Text Widget Entry

// 定義簡單統計文字小工具的資料結構。
struct StatsTextEntry: TimelineEntry {
    let date: Date // 條目的日期。
    let statsText: String // 要顯示的統計文字。
}

// MARK: - Stats Text Timeline Provider

// 提供簡單統計文字小工具的時間軸。
struct StatsTextProvider: TimelineProvider {
    
    // 返回小工具的佔位符條目。
    func placeholder(in context: Context) -> StatsTextEntry {
        StatsTextEntry(
            date: Date.now, // 當前日期。
            statsText: "今日完成 0 次運動" // 預設的統計文字。
        )
    }
    
    // 返回小工具的快照條目。
    func getSnapshot(in context: Context, completion: @escaping (StatsTextEntry) -> Void) {
        completion(
            StatsTextEntry(
                date: Date.now, // 當前日期。
                statsText: "今日完成 5 次運動" // 快照的統計文字。
            )
        )
    }
    
    // 返回小工具的時間軸。
    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsTextEntry>) -> Void) {
        let entry = StatsTextEntry(
            date: Date.now, // 當前日期。
            statsText: "今日完成 10 次運動" // 時間軸的統計文字。
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date.now)! // 設定下一次更新為 1 小時後。
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // 使用條目建立時間軸。
        completion(timeline) // 將時間軸傳遞給完成處理器。
    }
}

// MARK: - Stats Text Widget View

// 定義簡單統計文字小工具的主要視圖。
struct StatsTextWidgetView: View {
    var entry: StatsTextEntry // 小工具的資料條目。
    
    var body: some View {
        Text(entry.statsText) // 顯示統計文字。
            .font(.headline) // 設定文字的字體樣式。
            .foregroundStyle(.primary) // 設定文字的顏色。
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 設定視圖的最大寬度和高度。
            .containerBackground(.fill.tertiary, for: .widget) // 設定背景樣式。
            .widgetURL(URL(string: "gymcounter://stats")) // 設定小工具的 URL。
    }
}

// MARK: - Widget Configuration

// 定義簡單統計文字小工具的配置。
struct StatsTextWidget: Widget {
    let kind: String = "StatsTextWidget" // 小工具的識別類型。
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind, // 設定小工具的識別類型。
            provider: StatsTextProvider() // 設定小工具的時間軸提供者。
        ) { entry in
            StatsTextWidgetView(entry: entry) // 設定小工具的視圖。
        }
        .configurationDisplayName("統計文字") // 設定小工具的顯示名稱。
        .description("顯示簡單的統計文字") // 設定小工具的描述。
        .supportedFamilies([.systemSmall]) // 設定支援的小工具系列。
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) { // 定義小工具的預覽。
    StatsTextWidget() // 預覽簡單統計文字小工具。
} timeline: {
    StatsTextEntry(
        date: Date.now, // 當前日期。
        statsText: "今日完成 3 次運動" // 預覽的統計文字。
    )
}
