//
//  ExerciseSelectionView.swift
//  gym-counter
//

import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext // SwiftData 的環境上下文

    // MARK: - Query

    /// 查詢所有運動類型，按排序順序排列
    @Query(sort: \ExerciseType.sortOrder) private var exercises: [ExerciseType] // 按排序順序獲取運動類型

    // MARK: - State
    @Binding var showingAddExercise: Bool // 控制是否顯示新增運動視窗的狀態
    @Binding var showingStatistics: Bool // 控制是否顯示統計資料視窗的狀態

    // 提供預設的初始化器
    init(
        showingAddExercise: Binding<Bool> = .constant(false),
        showingStatistics: Binding<Bool> = .constant(false)
    ) {
        self._showingAddExercise = showingAddExercise
        self._showingStatistics = showingStatistics
    }

    // MARK: - Body

    var body: some View {
        NavigationStack { // 使用導航堆疊管理視圖
            ZStack { // 使用 ZStack 疊加視圖
                if exercises.isEmpty { // 如果運動列表為空
                    emptyStateView // 顯示空狀態視圖
                } else {
                    exerciseListView // 顯示運動列表視圖
                }
            }
            .navigationTitle("健身計數器") // 設置導航標題
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { // 工具欄項目，放置在導航欄右側
                    toolbarMenu // 顯示工具欄菜單
                }
            }
            .sheet(isPresented: $showingAddExercise) { // 彈出新增運動的視窗
                AddExerciseView() // 顯示新增運動的視圖
            }
            .sheet(isPresented: $showingStatistics) { // 彈出統計資料的視窗
                StatisticsView() // 顯示統計資料的視圖
            }
        }
    }

    // MARK: - View Components

    private var emptyStateView: some View {
        VStack(spacing: 20) { // 使用垂直堆疊排列視圖
            Image(systemName: "figure.strengthtraining.traditional") // 顯示圖示
                .font(.system(size: 80)) // 設置圖示大小
                .foregroundStyle(.secondary) // 設置圖示顏色
            
            Text("尚無運動項目") // 顯示提示文字
                .font(.title2.bold()) // 設置字體樣式
            
            Text("點擊右上角的 + 號\n新增你的第一個運動項目") // 顯示描述文字
                .font(.subheadline) // 設置副標題字體
                .foregroundStyle(.secondary) // 設置文字顏色
                .multilineTextAlignment(.center) // 設置多行文字對齊方式
            
            Button(action: { showingAddExercise = true }) { // 點擊按鈕顯示新增運動視窗
                Label("新增運動", systemImage: "plus.circle.fill") // 顯示按鈕標籤
                    .font(.headline) // 設置按鈕字體
            }
            .buttonStyle(.borderedProminent) // 設置按鈕樣式
            .padding(.top) // 添加頂部間距
        }
        .padding() // 添加內邊距
    }

    private var exerciseListView: some View {
        ScrollView { // 使用滾動視圖顯示運動列表
            LazyVStack(spacing: 16) { // 使用懶加載垂直堆疊排列運動項目
                ForEach(exercises) { exercise in // 遍歷每個運動項目
                    NavigationLink(destination: ContentView(exerciseType: exercise)) { // 點擊跳轉到 ContentView
                        ExerciseCard(exercise: exercise) // 顯示運動卡片
                    }
                    .buttonStyle(.plain) // 設置按鈕樣式
                }
            }
            .padding() // 添加內邊距
        }
    }

    private var toolbarMenu: some View {
        Menu { // 顯示菜單
            Button(action: { showingAddExercise = true }) { // 點擊新增運動
                Label("新增運動", systemImage: "plus") // 顯示新增運動標籤
            }
            
            Button(action: { showingStatistics = true }) { // 點擊顯示統計資料
                Label("統計資料", systemImage: "chart.bar") // 顯示統計資料標籤
            }
            
            Divider() // 添加分隔線
            
            Button(role: .destructive, action: deleteAllData) { // 點擊清除所有資料
                Label("清除所有資料", systemImage: "trash") // 顯示清除資料標籤
            }
        } label: {
            Image(systemName: "ellipsis.circle") // 顯示菜單圖示
                .font(.title3) // 設置圖示大小
        }
    }

    // MARK: - Actions

    private func deleteAllData() { // 刪除所有資料
        for exercise in exercises { // 遍歷所有運動項目
            modelContext.delete(exercise) // 刪除運動項目
        }
        
        do {
            try modelContext.save() // 保存更改
            print("✅ 所有資料已清除") // 打印成功訊息
        } catch {
            print("❌ 清除資料失敗: \(error)") // 打印錯誤訊息
        }
    }
}

// MARK: - Exercise Card Component

struct ExerciseCard: View {
    let exercise: ExerciseType // 運動類型的實例
    
    var body: some View {
        HStack(spacing: 16) { // 使用水平堆疊排列內容
            // 圖示
            Image(systemName: exercise.icon) // 顯示運動圖示
                .font(.system(size: 40)) // 設置圖示大小
                .foregroundStyle(.green) // 設置圖示顏色
                .frame(width: 60, height: 60) // 設置框架大小
                .background(.green.opacity(0.1)) // 設置背景顏色
                .clipShape(RoundedRectangle(cornerRadius: 12)) // 設置圓角矩形
            
            // 資訊
            VStack(alignment: .leading, spacing: 4) { // 使用垂直堆疊排列文字
                Text(exercise.name) // 顯示運動名稱
                    .font(.title3.bold()) // 設置字體樣式
                    .foregroundStyle(.primary) // 設置文字顏色
                
                Text(exercise.targetMuscle) // 顯示目標肌群
                    .font(.subheadline) // 設置副標題字體
                    .foregroundStyle(.secondary) // 設置文字顏色
                
                if !exercise.sessions.isEmpty { // 如果有運動紀錄
                    HStack(spacing: 12) { // 使用水平堆疊排列紀錄
                        Label("\(exercise.sessions.count) 次", systemImage: "calendar") // 顯示次數
                        Label("\(exercise.totalReps) 下", systemImage: "number") // 顯示總次數
                    }
                    .font(.caption) // 設置字體樣式
                    .foregroundStyle(.secondary) // 設置文字顏色
                }
            }
            
            Spacer() // 添加空間
            
            // 箭頭
            Image(systemName: "chevron.right") // 顯示箭頭圖示
                .font(.body.weight(.semibold)) // 設置字體樣式
                .foregroundStyle(.tertiary) // 設置顏色
        }
        .padding() // 添加內邊距
        .background(.fill.secondary) // 設置背景顏色
        .clipShape(RoundedRectangle(cornerRadius: 16)) // 設置圓角矩形
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2) // 添加陰影效果
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss // 環境變數，用於關閉視圖
    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var sessions: [WorkoutSession] // 按開始時間排序的運動紀錄
    
    var body: some View {
        NavigationStack { // 使用導航堆疊管理視圖
            List { // 使用列表顯示內容
                overviewSection // 總覽區段
                recentSessionsSection // 最近紀錄區段
            }
            .navigationTitle("統計資料") // 設置導航標題
            .navigationBarTitleDisplayMode(.inline) // 設置標題顯示模式
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { // 工具欄項目，放置在右上角
                    Button("完成") { dismiss() } // 點擊按鈕關閉視圖
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var overviewSection: some View {
        Section("總覽") { // 總覽區段
            StatRow(title: "總運動次數", value: "\(sessions.count)") // 顯示總運動次數
            StatRow(title: "總完成次數", value: "\(totalReps)") // 顯示總完成次數
            
            if let lastSession = sessions.first { // 如果有最近的運動紀錄
                StatRow(
                    title: "最近運動",
                    value: lastSession.startTime.formatted(date: .abbreviated, time: .shortened) // 顯示最近運動時間
                )
            }
        }
    }
    
    private var recentSessionsSection: some View {
        Section("最近記錄") { // 最近紀錄區段
            if sessions.isEmpty { // 如果沒有運動紀錄
                Text("尚無運動記錄") // 顯示提示文字
                    .foregroundStyle(.secondary) // 設置文字顏色
            } else {
                ForEach(sessions.prefix(10)) { session in // 遍歷最近的 10 條運動紀錄
                    SessionRow(session: session) // 顯示運動紀錄行
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalReps: Int {
        sessions.reduce(0) { $0 + $1.repCount } // 計算總完成次數
    }
}

// MARK: - Stat Row Component

struct StatRow: View {
    let title: String // 標題
    let value: String // 值
    
    var body: some View {
        HStack { // 使用水平堆疊排列內容
            Text(title) // 顯示標題
            Spacer() // 添加空間
            Text(value) // 顯示值
                .bold() // 設置字體加粗
                .foregroundStyle(.green) // 設置文字顏色
        }
    }
}

// MARK: - Session Row Component

struct SessionRow: View {
    let session: WorkoutSession // 運動紀錄的實例
    
    var body: some View {
        HStack { // 使用水平堆疊排列內容
            VStack(alignment: .leading, spacing: 4) { // 使用垂直堆疊排列文字
                Text(session.exerciseType?.name ?? "未知運動") // 顯示運動名稱
                    .font(.headline) // 設置字體樣式
                
                Text(session.startTime.formatted(date: .abbreviated, time: .shortened)) // 顯示運動開始時間
                    .font(.caption) // 設置字體樣式
                    .foregroundStyle(.secondary) // 設置文字顏色
                
                if let duration = session.endTime?.timeIntervalSince(session.startTime) { // 如果有運動時長
                    Text("時長: \(formatDuration(duration))") // 顯示運動時長
                        .font(.caption2) // 設置字體樣式
                        .foregroundStyle(.secondary) // 設置文字顏色
                }
            }
            
            Spacer() // 添加空間
            
            VStack(alignment: .trailing) { // 右側統計數據
                Text("\(session.repCount)") // 顯示重複次數
                    .font(.title3.bold()) // 設置字體樣式
                
                Text("次") // 單位
                    .font(.caption) // 設置字體樣式
                    .foregroundStyle(.secondary) // 設置文字顏色
            }
        }
        .padding(.vertical, 4) // 添加上下內邊距
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60 // 計算分鐘數
        let seconds = Int(duration) % 60 // 計算秒數
        return String(format: "%d:%02d", minutes, seconds) // 格式化時間字串
    }
}

// MARK: - Preview

#Preview("空狀態") {
    ExerciseSelectionView()
        .modelContainer(for: [ExerciseType.self, WorkoutSession.self])
}

#Preview("已有資料") {
    let container = try! ModelContainer(
        for: ExerciseType.self, WorkoutSession.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 插入範例資料
    let context = ModelContext(container)
    for exercise in ExerciseType.sampleExercises {
        context.insert(exercise)
    }
    
    return ExerciseSelectionView()
        .modelContainer(container)
}
