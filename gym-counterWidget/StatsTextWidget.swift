//
//  StatsTextWidget.swift
//  gym-counter
//
//  文字統計資料 Widget
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Stats Text Widget Entry

struct StatsTextEntry: TimelineEntry {
    let date: Date
    let totalWorkouts: Int
    let totalReps: Int
    let weeklyWorkouts: Int
    let weeklyReps: Int
    let averageRepsPerWorkout: Int
    let mostPopularExercise: String?
}

// MARK: - Stats Text Timeline Provider

struct StatsTextProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> StatsTextEntry {
        StatsTextEntry(
            date: Date.now,
            totalWorkouts: 50,
            totalReps: 1500,
            weeklyWorkouts: 12,
            weeklyReps: 360,
            averageRepsPerWorkout: 30,
            mostPopularExercise: "伏地挺身"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StatsTextEntry) -> Void) {
        Task {
            let entry = await fetchStatsData()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsTextEntry>) -> Void) {
        Task {
            let entry = await fetchStatsData()
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date.now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func fetchStatsData() async -> StatsTextEntry {
        do {
            let container = try createSharedContainer()
            let context = ModelContext(container)
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                sortBy: [.init(\.startTime, order: .reverse)]
            )
            let allSessions = try context.fetch(sessionDescriptor)
            
            let totalWorkouts = allSessions.count
            let totalReps = allSessions.reduce(0) { $0 + $1.repCount }
            
            // 計算本週數據
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date.now)!
            let weeklySessions = allSessions.filter { $0.startTime >= weekAgo }
            let weeklyWorkouts = weeklySessions.count
            let weeklyReps = weeklySessions.reduce(0) { $0 + $1.repCount }
            
            // 計算平均每次運動次數
            let averageReps = totalWorkouts > 0 ? totalReps / totalWorkouts : 0
            
            // 找出最受歡迎的運動
            var exerciseCounts: [String: Int] = [:]
            for session in allSessions {
                if let exerciseName = session.exerciseType?.name {
                    exerciseCounts[exerciseName, default: 0] += 1
                }
            }
            let mostPopular = exerciseCounts.max(by: { $0.value < $1.value })?.key
            
            return StatsTextEntry(
                date: Date.now,
                totalWorkouts: totalWorkouts,
                totalReps: totalReps,
                weeklyWorkouts: weeklyWorkouts,
                weeklyReps: weeklyReps,
                averageRepsPerWorkout: averageReps,
                mostPopularExercise: mostPopular
            )
            
        } catch {
            print("❌ StatsText Widget 讀取失敗: \(error)")
        }
        
        return StatsTextEntry(
            date: Date.now,
            totalWorkouts: 0,
            totalReps: 0,
            weeklyWorkouts: 0,
            weeklyReps: 0,
            averageRepsPerWorkout: 0,
            mostPopularExercise: nil
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

// MARK: - Stats Text Widget View

struct StatsTextWidgetView: View {
    var entry: StatsTextEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallStatsTextView(entry: entry)
        case .systemMedium:
            MediumStatsTextView(entry: entry)
        default:
            SmallStatsTextView(entry: entry)
        }
    }
}

// MARK: - Small Stats Text View

struct SmallStatsTextView: View {
    let entry: StatsTextEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundStyle(.purple)
                Text("統計數據")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                StatRow(label: "總訓練", value: "\(entry.totalWorkouts)", icon: "flame.fill")
                StatRow(label: "總次數", value: "\(entry.totalReps)", icon: "number")
                StatRow(label: "本週", value: "\(entry.weeklyWorkouts)", icon: "calendar")
            }
            
            Spacer()
            
            if let exercise = entry.mostPopularExercise {
                Text("最愛：\(exercise)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://stats"))
    }
}

// MARK: - Medium Stats Text View

struct MediumStatsTextView: View {
    let entry: StatsTextEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text("運動統計總覽")
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    StatRow(label: "總訓練次數", value: "\(entry.totalWorkouts)", icon: "flame.fill")
                    StatRow(label: "總完成次數", value: "\(entry.totalReps)", icon: "number")
                    StatRow(label: "平均每次", value: "\(entry.averageRepsPerWorkout)", icon: "chart.line.uptrend.xyaxis")
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    StatRow(label: "本週訓練", value: "\(entry.weeklyWorkouts)", icon: "calendar")
                    StatRow(label: "本週次數", value: "\(entry.weeklyReps)", icon: "arrow.up.right")
                    
                    if let exercise = entry.mostPopularExercise {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            Text(exercise)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .padding(.top, 2)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://stats"))
    }
}

// MARK: - Stat Row Component

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.purple)
                .frame(width: 16)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Widget Configuration

struct StatsTextWidget: Widget {
    let kind: String = "StatsTextWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StatsTextProvider()
        ) { entry in
            StatsTextWidgetView(entry: entry)
        }
        .configurationDisplayName("統計資料")
        .description("查看詳細的運動統計數據")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    StatsTextWidget()
} timeline: {
    StatsTextEntry(
        date: Date.now,
        totalWorkouts: 45,
        totalReps: 1350,
        weeklyWorkouts: 10,
        weeklyReps: 300,
        averageRepsPerWorkout: 30,
        mostPopularExercise: "伏地挺身"
    )
}

#Preview(as: .systemMedium) {
    StatsTextWidget()
} timeline: {
    StatsTextEntry(
        date: Date.now,
        totalWorkouts: 45,
        totalReps: 1350,
        weeklyWorkouts: 10,
        weeklyReps: 300,
        averageRepsPerWorkout: 30,
        mostPopularExercise: "伏地挺身"
    )
}
