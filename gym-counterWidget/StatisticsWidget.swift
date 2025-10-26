//
//  StatisticsWidget.swift
//  gym-counter
//
//  統計資料快捷 Widget
//

import WidgetKit
import SwiftUI

// MARK: - Statistics Widget Entry

struct StatisticsEntry: TimelineEntry {
    let date: Date
}

// MARK: - Statistics Timeline Provider

struct StatisticsProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(date: Date.now)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        completion(StatisticsEntry(date: Date.now))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StatisticsEntry>) -> Void) {
        let entry = StatisticsEntry(date: Date.now)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 24, to: Date.now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Statistics Widget View

struct StatisticsWidgetView: View {
    var entry: StatisticsEntry
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundStyle(.cyan)
            
            Text("統計資料")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("查看詳細數據")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://statistics"))
    }
}

// MARK: - Widget Configuration

struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StatisticsProvider()
        ) { entry in
            StatisticsWidgetView(entry: entry)
        }
        .configurationDisplayName("統計資料")
        .description("快速查看統計資料頁面")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    StatisticsWidget()
} timeline: {
    StatisticsEntry(date: Date.now)
}
