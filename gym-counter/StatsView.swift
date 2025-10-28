//
//  StatsView.swift
//  gym-counter
//

import SwiftUI // 匯入 SwiftUI 框架，用於構建用戶界面
import SwiftData // 匯入 SwiftData 框架，用於數據管理
import Charts // 匯入 Charts 框架，用於繪製圖表

struct StatsView: View { // 定義統計視圖
    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var sessions: [WorkoutSession] // 查詢運動紀錄，按開始時間倒序排列

    // MARK: - State for Interactivity
    @State private var selectedDate: Date? // 用於選擇的日期狀態
    @State private var selectedMuscleGroup: String? // 用於選擇的肌群狀態

    // MARK: - Computed Properties for Charts

    private var dailyReps: [(date: Date, reps: Int)] { // 每日總次數的計算屬性
        let calendar = Calendar.current // 獲取當前日曆
        let groupedByDay = Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.startTime) } // 按天分組
        return groupedByDay.map { (date, sessions) in
            (date: date, reps: sessions.reduce(0) { $0 + $1.repCount }) // 計算每一天的總次數
        }.sorted { $0.date < $1.date } // 按日期排序
    }

    private var repsPerExercise: [(exercise: String, reps: Int)] { // 各運動總次數的計算屬性
        let groupedByExercise = Dictionary(grouping: sessions) { $0.exerciseType?.name ?? "未知" } // 按運動名稱分組
        return groupedByExercise.map { (name, sessions) in
            (exercise: name, reps: sessions.reduce(0) { $0 + $1.repCount }) // 計算每個運動的總次數
        }.sorted { $0.reps > $1.reps } // 按次數倒序排序
    }

    private var muscleGroupDistribution: [(muscle: String, count: Int)] { // 目標肌群分佈的計算屬性
        let groupedByMuscle = Dictionary(grouping: sessions) { $0.exerciseType?.targetMuscle ?? "未指定" } // 按肌群分組
        return groupedByMuscle.map { (muscle, sessions) in
            (muscle: muscle, count: sessions.count) // 計算每個肌群的次數
        }.sorted { $0.count > $1.count } // 按次數倒序排序
    }

    // MARK: - Body

    var body: some View {
        NavigationStack { // 使用導航堆疊管理視圖
            ScrollView { // 使用滾動視圖顯示內容
                VStack(alignment: .leading, spacing: 24) { // 使用垂直堆疊排列內容
                    if sessions.isEmpty { // 如果沒有運動紀錄
                        ContentUnavailableView("沒有統計數據", systemImage: "chart.bar.xaxis", description: Text("完成一些運動後，這裡會顯示您的統計圖表。")) // 顯示提示內容
                    } else {
                        dailyRepsChart // 顯示每日總次數圖表
                        repsPerExerciseChart // 顯示各運動總次數圖表
                        muscleGroupPieChart // 顯示目標肌群分佈圖表
                    }
                }
                .padding() // 添加內邊距
            }
            .navigationTitle("統計") // 設置導航標題
            .background(Color(UIColor.systemGroupedBackground)) // 設置背景顏色
        }
    }

    // MARK: - Chart Views

    private var dailyRepsChart: some View { // 每日總次數圖表
        VStack(alignment: .leading) { // 使用垂直堆疊排列內容
            Text("每日總次數").font(.headline) // 顯示標題
            Chart { // 繪製圖表
                ForEach(dailyReps, id: \.date) { dataPoint in // 遍歷每日數據
                    LineMark(x: .value("日期", dataPoint.date, unit: .day), y: .value("總次數", dataPoint.reps)) // 繪製折線圖
                        .interpolationMethod(.catmullRom) // 設置插值方法
                    PointMark(x: .value("日期", dataPoint.date, unit: .day), y: .value("總次數", dataPoint.reps)) // 繪製數據點
                        .foregroundStyle(.blue) // 設置顏色
                }
            }
            .chartXSelection(value: $selectedDate) // 支持 X 軸選擇
            .chartOverlay { proxy in // 添加圖表覆蓋層
                GeometryReader { geometry in // 使用幾何讀取器
                    if let selectedDate = selectedDate, let dataPoint = dailyReps.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) { // 確保選擇的日期有效
                        let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedDate)! // 獲取日期區間
                        if let startPosition = proxy.position(forX: dateInterval.start), let endPosition = proxy.position(forX: dateInterval.end) { // 確保位置有效
                            let midPosition = startPosition + (endPosition - startPosition) / 2 // 計算中間位置
                            VStack(alignment: .center) { // 使用垂直堆疊顯示數據
                                Text(dataPoint.date, format: .dateTime.month().day()).font(.caption).foregroundStyle(.secondary) // 顯示日期
                                Text("\(dataPoint.reps) 次").font(.headline).fontWeight(.bold) // 顯示次數
                            }
                            .padding() // 添加內邊距
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8)) // 設置背景
                            .position(x: midPosition, y: geometry.size.height / 2) // 設置位置
                        }
                    }
                }
            }
            .chartXAxis { // 設置 X 軸
                AxisMarks(values: .stride(by: .day)) { _ in // 設置軸標記
                    AxisGridLine() // 顯示網格線
                    AxisTick() // 顯示刻度
                    AxisValueLabel(format: .dateTime.month().day()) // 顯示標籤
                }
            }
            .frame(height: 200) // 設置高度
        }
        .padding() // 添加內邊距
        .background(Color(UIColor.secondarySystemGroupedBackground)) // 設置背景顏色
        .cornerRadius(12) // 設置圓角
    }

    private var repsPerExerciseChart: some View { // 各運動總次數圖表
        VStack(alignment: .leading) { // 使用垂直堆疊排列內容
            Text("各運動總次數").font(.headline) // 顯示標題
            Chart(repsPerExercise, id: \.exercise) { dataPoint in // 繪製圖表
                BarMark(x: .value("次數", dataPoint.reps), y: .value("運動", dataPoint.exercise)) // 繪製柱狀圖
                    .foregroundStyle(by: .value("運動", dataPoint.exercise)) // 設置顏色
            }
            .frame(height: 200) // 設置高度
        }
        .padding() // 添加內邊距
        .background(Color(UIColor.secondarySystemGroupedBackground)) // 設置背景顏色
        .cornerRadius(12) // 設置圓角
    }

    private var muscleGroupPieChart: some View { // 目標肌群分佈圖表
        VStack(alignment: .leading) { // 使用垂直堆疊排列內容
            Text("目標肌群分佈").font(.headline) // 顯示標題
            Chart(muscleGroupDistribution, id: \.muscle) { dataPoint in // 繪製圖表
                SectorMark(angle: .value("次數", dataPoint.count), innerRadius: .ratio(0.618), angularInset: 1.5) // 繪製扇形圖
                    .foregroundStyle(by: .value("肌群", dataPoint.muscle)) // 設置顏色
                    .cornerRadius(5) // 設置圓角
            }
            .chartAngleSelection(value: $selectedMuscleGroup) // 支持角度選擇
            .frame(height: 300) // 設置高度
        }
        .padding() // 添加內邊距
        .background(Color(UIColor.secondarySystemGroupedBackground)) // 設置背景顏色
        .cornerRadius(12) // 設置圓角
    }
}

// MARK: - Preview
#Preview {
    StatsView() // 預覽統計視圖
}
