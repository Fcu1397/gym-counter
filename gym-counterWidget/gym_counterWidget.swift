//
//  GymCounterWidget.swift
//  gym-counter
//
import WidgetKit
import SwiftUI
import SwiftData
import Charts

// MARK: - Widget Entry

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let totalWorkouts: Int
    let todayWorkouts: Int
    let totalReps: Int
    let recentExercise: ExerciseType?
    let dailyRepsForChart: [(day: String, reps: Int)] // 新增圖表數據
}

// MARK: - Timeline Provider

struct WorkoutTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WorkoutEntry {
        WorkoutEntry(
            date: Date.now,
            totalWorkouts: 0,
            todayWorkouts: 0,
            totalReps: 0,
            recentExercise: nil,
            dailyRepsForChart: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> Void) {
        Task {
            let entry = await fetchWorkoutData()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutEntry>) -> Void) {
        Task {
            let entry = await fetchWorkoutData()
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date.now)!
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    private func fetchWorkoutData() async -> WorkoutEntry {
        do {
            let container = try createSharedContainer()
            let context = ModelContext(container)
            
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                sortBy: [.init(\.startTime, order: .reverse)]
            )
            let allSessions = try context.fetch(sessionDescriptor)
            
            let todayStart = Calendar.current.startOfDay(for: Date.now)
            let todaySessions = allSessions.filter { $0.startTime >= todayStart }
            let totalReps = allSessions.reduce(0) { $0 + $1.repCount }
            let recentExercise = allSessions.first?.exerciseType
            
            let dailyReps = calculateDailyReps(for: allSessions)
            
            print("✅ Widget 資料讀取成功: \(allSessions.count) 筆紀錄")
            
            return WorkoutEntry(
                date: Date.now,
                totalWorkouts: allSessions.count,
                todayWorkouts: todaySessions.count,
                totalReps: totalReps,
                recentExercise: recentExercise,
                dailyRepsForChart: dailyReps
            )
            
        } catch {
            print("❌ Widget 讀取資料失敗: \(error)")
            return WorkoutEntry(
                date: Date.now,
                totalWorkouts: 0,
                todayWorkouts: 0,
                totalReps: 0,
                recentExercise: nil,
                dailyRepsForChart: []
            )
        }
    }
    
    private func calculateDailyReps(for sessions: [WorkoutSession]) -> [(day: String, reps: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        var dailyData: [Date: Int] = [:]
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dailyData[date] = 0
            }
        }
        
        for session in sessions {
            let sessionDay = calendar.startOfDay(for: session.startTime)
            if dailyData[sessionDay] != nil {
                dailyData[sessionDay, default: 0] += session.repCount
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        return dailyData.sorted(by: { $0.key < $1.key }).map {
            (day: dateFormatter.string(from: $0.key), reps: $0.value)
        }
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

// MARK: - Widget View

struct GymCounterWidgetView: View {
    var entry: WorkoutEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: WorkoutEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 32))
                .foregroundStyle(.green)
            
            Text("\(entry.todayWorkouts)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text("今日運動")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://stats"))
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: WorkoutEntry
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Label("今日運動", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(entry.todayWorkouts)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Label("總次數", systemImage: "number")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(entry.totalReps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://stats"))
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: WorkoutEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title)
                    .foregroundStyle(.green)
                
                Text("最近 7 天活動")
                    .font(.title2.bold())
                
                Spacer()
            }
            
            if entry.dailyRepsForChart.isEmpty || entry.dailyRepsForChart.allSatisfy({ $0.reps == 0 }) {
                VStack {
                    Spacer()
                    Text("沒有足夠的數據來顯示圖表")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                Chart(entry.dailyRepsForChart, id: \.day) { dataPoint in
                    BarMark(
                        x: .value("日期", dataPoint.day),
                        y: .value("次數", dataPoint.reps)
                    )
                    .foregroundStyle(.green)
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
            
            HStack(spacing: 20) {
                StatBlock(
                    title: "今日運動",
                    value: "\(entry.todayWorkouts)",
                    icon: "calendar"
                )
                
                StatBlock(
                    title: "總次數",
                    value: "\(entry.totalReps)",
                    icon: "number"
                )
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "gymcounter://stats"))
    }
}

// MARK: - Stat Block Component

struct StatBlock: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.fill.secondary)
        .cornerRadius(12)
    }
}

// MARK: - Widget Configuration

struct gym_counterWidget: Widget {
    let kind: String = "gym_counterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WorkoutTimelineProvider()
        ) { entry in
            GymCounterWidgetView(entry: entry)
        }
        .configurationDisplayName("運動統計")
        .description("追蹤你的運動進度")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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


