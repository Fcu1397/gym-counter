//
//  AddExerciseWidget.swift
//  gym-counter
//
//  新增運動快捷 Widget
//

import WidgetKit
import SwiftUI

// MARK: - Add Exercise Widget Entry

struct AddExerciseEntry: TimelineEntry {
    let date: Date
}

// MARK: - Add Exercise Timeline Provider

struct AddExerciseProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> AddExerciseEntry {
        AddExerciseEntry(date: Date.now)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AddExerciseEntry) -> Void) {
        completion(AddExerciseEntry(date: Date.now))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AddExerciseEntry>) -> Void) {
        let entry = AddExerciseEntry(date: Date.now)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 24, to: Date.now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Add Exercise Widget View

struct AddExerciseWidgetView: View {
    var entry: AddExerciseEntry
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            Text("新增運動")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("快速新增項目")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://add-exercise"))
    }
}

// MARK: - Widget Configuration

struct AddExerciseWidget: Widget {
    let kind: String = "AddExerciseWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: AddExerciseProvider()
        ) { entry in
            AddExerciseWidgetView(entry: entry)
        }
        .configurationDisplayName("新增運動")
        .description("快速開啟新增運動頁面")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    AddExerciseWidget()
} timeline: {
    AddExerciseEntry(date: Date.now)
}
