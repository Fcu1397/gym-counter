//
//  StatsView.swift
//  gym-counter
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var sessions: [WorkoutSession]
    
    // MARK: - State for Interactivity
    @State private var selectedDate: Date?
    @State private var selectedMuscleGroup: String?

    // MARK: - Computed Properties for Charts

    private var dailyReps: [(date: Date, reps: Int)] {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.startTime) }
        return groupedByDay.map { (date, sessions) in
            (date: date, reps: sessions.reduce(0) { $0 + $1.repCount })
        }.sorted { $0.date < $1.date }
    }

    private var repsPerExercise: [(exercise: String, reps: Int)] {
        let groupedByExercise = Dictionary(grouping: sessions) { $0.exerciseType?.name ?? "未知" }
        return groupedByExercise.map { (name, sessions) in
            (exercise: name, reps: sessions.reduce(0) { $0 + $1.repCount })
        }.sorted { $0.reps > $1.reps }
    }

    private var muscleGroupDistribution: [(muscle: String, count: Int)] {
        let groupedByMuscle = Dictionary(grouping: sessions) { $0.exerciseType?.targetMuscle ?? "未指定" }
        return groupedByMuscle.map { (muscle, sessions) in
            (muscle: muscle, count: sessions.count)
        }.sorted { $0.count > $1.count }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if sessions.isEmpty {
                        ContentUnavailableView("沒有統計數據", systemImage: "chart.bar.xaxis", description: Text("完成一些運動後，這裡會顯示您的統計圖表。"))
                    } else {
                        dailyRepsChart
                        repsPerExerciseChart
                        muscleGroupPieChart
                    }
                }
                .padding()
            }
            .navigationTitle("統計")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // MARK: - Chart Views

    private var dailyRepsChart: some View {
        VStack(alignment: .leading) {
            Text("每日總次數").font(.headline)
            Chart {
                ForEach(dailyReps, id: \.date) { dataPoint in
                    LineMark(x: .value("日期", dataPoint.date, unit: .day), y: .value("總次數", dataPoint.reps))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("日期", dataPoint.date, unit: .day), y: .value("總次數", dataPoint.reps))
                        .foregroundStyle(.blue)
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    if let selectedDate = selectedDate, let dataPoint = dailyReps.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                        let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedDate)!
                        if let startPosition = proxy.position(forX: dateInterval.start), let endPosition = proxy.position(forX: dateInterval.end) {
                            let midPosition = startPosition + (endPosition - startPosition) / 2
                            VStack(alignment: .center) {
                                Text(dataPoint.date, format: .dateTime.month().day()).font(.caption).foregroundStyle(.secondary)
                                Text("\(dataPoint.reps) 次").font(.headline).fontWeight(.bold)
                            }
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .position(x: midPosition, y: geometry.size.height / 2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var repsPerExerciseChart: some View {
        VStack(alignment: .leading) {
            Text("各運動總次數").font(.headline)
            Chart(repsPerExercise, id: \.exercise) { dataPoint in
                BarMark(x: .value("次數", dataPoint.reps), y: .value("運動", dataPoint.exercise))
                    .foregroundStyle(by: .value("運動", dataPoint.exercise))
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var muscleGroupPieChart: some View {
        VStack(alignment: .leading) {
            Text("目標肌群分佈").font(.headline)
            Chart(muscleGroupDistribution, id: \.muscle) { dataPoint in
                SectorMark(angle: .value("次數", dataPoint.count), innerRadius: .ratio(0.618), angularInset: 1.5)
                    .foregroundStyle(by: .value("肌群", dataPoint.muscle))
                    .cornerRadius(5)
            }
            .chartAngleSelection(value: $selectedMuscleGroup)
            .frame(height: 300)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    StatsView()
}
