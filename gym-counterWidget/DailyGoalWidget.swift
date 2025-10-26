//
//  DailyGoalWidget.swift
//  gym-counter
//
//  今日目標 Widget
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Daily Goal Widget Entry

struct DailyGoalEntry: TimelineEntry {
    let date: Date
    let todayReps: Int
    let goalReps: Int
    let completionPercentage: Double
}

// MARK: - Daily Goal Timeline Provider

struct DailyGoalProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> DailyGoalEntry {
        DailyGoalEntry(
            date: Date.now,
            todayReps: 50,
            goalReps: 100,
            completionPercentage: 0.5
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailyGoalEntry) -> Void) {
        Task {
            let entry = await fetchDailyGoal()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyGoalEntry>) -> Void) {
        Task {
            let entry = await fetchDailyGoal()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date.now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func fetchDailyGoal() async -> DailyGoalEntry {
        do {
            let container = try createSharedContainer()
            let context = ModelContext(container)
            
            let todayStart = Calendar.current.startOfDay(for: Date.now)
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                sortBy: [.init(\.startTime, order: .reverse)]
            )
            let allSessions = try context.fetch(sessionDescriptor)
            
            let todaySessions = allSessions.filter { $0.startTime >= todayStart }
            let todayReps = todaySessions.reduce(0) { $0 + $1.repCount }
            
            // 設定每日目標為 100 次（可以根據需求調整）
            let goalReps = 100
            let percentage = min(Double(todayReps) / Double(goalReps), 1.0)
            
            return DailyGoalEntry(
                date: Date.now,
                todayReps: todayReps,
                goalReps: goalReps,
                completionPercentage: percentage
            )
            
        } catch {
            print("❌ DailyGoal Widget 讀取失敗: \(error)")
        }
        
        return DailyGoalEntry(
            date: Date.now,
            todayReps: 0,
            goalReps: 100,
            completionPercentage: 0
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

// MARK: - Daily Goal Widget View

struct DailyGoalWidgetView: View {
    var entry: DailyGoalEntry
    
    var body: some View {
        VStack(spacing: 10) {
            Text("今日目標")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.3)
                    .foregroundStyle(.blue)
                
                Circle()
                    .trim(from: 0.0, to: entry.completionPercentage)
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .foregroundStyle(.blue)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: entry.completionPercentage)
                
                VStack(spacing: 2) {
                    Text("\(entry.todayReps)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("/ \(entry.goalReps)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            
            Text("\(Int(entry.completionPercentage * 100))% 完成")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://stats"))
    }
}

// MARK: - Widget Configuration

struct DailyGoalWidget: Widget {
    let kind: String = "DailyGoalWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: DailyGoalProvider()
        ) { entry in
            DailyGoalWidgetView(entry: entry)
        }
        .configurationDisplayName("今日目標")
        .description("追蹤你的每日運動目標進度")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    DailyGoalWidget()
} timeline: {
    DailyGoalEntry(
        date: Date.now,
        todayReps: 75,
        goalReps: 100,
        completionPercentage: 0.75
    )
}
