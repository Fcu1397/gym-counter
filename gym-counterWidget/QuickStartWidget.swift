//
//  QuickStartWidget.swift
//  gym-counter
//
//  快速開始運動 Widget
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Quick Start Widget Entry

struct QuickStartEntry: TimelineEntry {
    let date: Date
    let recentExerciseName: String?
    let recentExerciseIcon: String?
}

// MARK: - Quick Start Timeline Provider

struct QuickStartProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> QuickStartEntry {
        QuickStartEntry(
            date: Date.now,
            recentExerciseName: "伏地挺身",
            recentExerciseIcon: "figure.arms.open"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickStartEntry) -> Void) {
        Task {
            let entry = await fetchRecentExercise()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickStartEntry>) -> Void) {
        Task {
            let entry = await fetchRecentExercise()
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date.now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func fetchRecentExercise() async -> QuickStartEntry {
        do {
            let container = try createSharedContainer()
            let context = ModelContext(container)
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                sortBy: [.init(\.startTime, order: .reverse)]
            )
            let sessions = try context.fetch(sessionDescriptor)
            
            if let recent = sessions.first, let exerciseType = recent.exerciseType {
                return QuickStartEntry(
                    date: Date.now,
                    recentExerciseName: exerciseType.name,
                    recentExerciseIcon: exerciseType.icon
                )
            }
            
        } catch {
            print("❌ QuickStart Widget 讀取失敗: \(error)")
        }
        
        return QuickStartEntry(
            date: Date.now,
            recentExerciseName: nil,
            recentExerciseIcon: nil
        )
    }
    
    private func createSharedContainer() throws -> ModelContainer {
        let schema = Schema([
            ExerciseType.self,
            WorkoutSession.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.buildwithashton.gym-counter"),
            cloudKitDatabase: .none
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }
}

// MARK: - Quick Start Widget View

struct QuickStartWidgetView: View {
    var entry: QuickStartEntry
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: entry.recentExerciseIcon ?? "figure.run")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("快速開始")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if let name = entry.recentExerciseName {
                Text(name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("開始運動")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://exercise"))
    }
}

// MARK: - Widget Configuration

struct QuickStartWidget: Widget {
    let kind: String = "QuickStartWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: QuickStartProvider()
        ) { entry in
            QuickStartWidgetView(entry: entry)
        }
        .configurationDisplayName("快速開始")
        .description("快速開始你最近的運動")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    QuickStartWidget()
} timeline: {
    QuickStartEntry(
        date: Date.now,
        recentExerciseName: "伏地挺身",
        recentExerciseIcon: "figure.arms.open"
    )
}
