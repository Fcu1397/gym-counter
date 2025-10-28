//
//  ContentView.swift
//  gym-counter
//

import SwiftUI
import SwiftData
import Observation
import WidgetKit // 匯入 WidgetKit，用於小工具更新

struct ContentView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext // SwiftData 的環境上下文

    // MARK: - Properties
    let exerciseType: ExerciseType // 運動類型的實例

    // MARK: - State
    @State private var motionManager = MotionManager() // 管理運動數據的實例
    @State private var workoutState: WorkoutState = .idle // 運動狀態，預設為 idle
    @State private var workoutStartTime: Date? // 運動開始時間
    @State private var showingSaveConfirmation = false // 是否顯示儲存確認提示
    @State private var lastSavedRepCount: Int = 0 // 用於儲存最後一次的次數

    // MARK: - Computed Properties
    private var isWorkoutInProgress: Bool {
        workoutState != .idle // 判斷是否正在運動
    }

    private var canSaveWorkout: Bool {
        motionManager.repCount > 0 && workoutStartTime != nil // 判斷是否可以儲存運動
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 50) { // 使用垂直堆疊排列視圖
            headerSection // 標題區域
            countDisplay // 計數顯示區域
            controlButtons // 控制按鈕區域
            workoutStatusIndicator // 運動狀態指示器
        }
        .padding() // 添加內邊距
        .navigationTitle(exerciseType.name) // 設置導航標題為運動名稱
        .navigationBarTitleDisplayMode(.inline) // 設置標題顯示模式
        .alert("運動已儲存", isPresented: $showingSaveConfirmation) { // 儲存確認提示框
            Button("確定", role: .cancel) { } // 確定按鈕
        } message: {
            Text("已記錄 \(lastSavedRepCount) 次") // 顯示儲存的次數
        }
        .onDisappear {
            handleViewDisappear() // 處理視圖消失時的邏輯
        }
        .backgroundStyle(.thinMaterial) // 設置背景樣式
    }

    // MARK: - View Components

    private var headerSection: some View {
        Text(exerciseType.name) // 顯示運動名稱
            .font(.system(size: 40, weight: .bold, design: .rounded)) // 設置字體樣式
            .foregroundStyle(.primary) // 設置前景顏色
    }

    private var countDisplay: some View {
        Text("\(motionManager.repCount)") // 顯示次數
            .font(.system(size: 120, weight: .heavy, design: .monospaced)) // 設置字體樣式
            .foregroundStyle(workoutState == .active ? .green : .primary) // 根據狀態設置顏色
            .contentTransition(.numericText()) // 數字過渡效果
            .animation(.smooth, value: motionManager.repCount) // 平滑動畫效果
            .onTapGesture {
                incrementCount() // 點擊時增加次數
            }
            .sensoryFeedback(.impact, trigger: motionManager.repCount) // 添加觸覺回饋
    }

    private var controlButtons: some View {
        HStack(spacing: 25) { // 使用水平堆疊排列按鈕
            playPauseButton // 播放/暫停按鈕
            stopButton // 停止按鈕
            resetButton // 重置按鈕
        }
    }

    private var playPauseButton: some View {
        Button(action: toggleWorkout) { // 切換運動狀態
            Image(systemName: workoutState == .active ? "pause.circle.fill" : "play.circle.fill") // 根據狀態顯示圖示
                .font(.system(size: 60)) // 設置圖示大小
                .foregroundStyle(workoutState == .active ? .orange : .green) // 設置顏色
                .symbolEffect(.bounce, value: workoutState) // 添加彈跳效果
        }
        .buttonStyle(.borderless) // 設置按鈕樣式
        .sensoryFeedback(.selection, trigger: workoutState) // 添加選擇回饋
        .accessibilityLabel(workoutState == .active ? "暫停" : "開始") // 設置無障礙標籤
    }

    private var stopButton: some View {
        Button(action: endWorkout) { // 結束運動
            Image(systemName: "stop.circle.fill") // 停止圖示
                .font(.system(size: 60)) // 設置圖示大小
                .foregroundStyle(.red) // 設置顏色
                .symbolEffect(.pulse, options: .repeating, value: canSaveWorkout) // 添加脈衝效果
        }
        .buttonStyle(.borderless) // 設置按鈕樣式
        .disabled(!canSaveWorkout) // 禁用條件
        .opacity(canSaveWorkout ? 1.0 : 0.5) // 設置透明度
        .sensoryFeedback(.success, trigger: showingSaveConfirmation) // 添加成功回饋
        .accessibilityLabel("結束並儲存") // 設置無障礙標籤
    }

    private var resetButton: some View {
        Button(action: resetCount) { // 重置計數
            Image(systemName: "arrow.counterclockwise.circle.fill") // 重置圖示
                .font(.system(size: 60)) // 設置圖示大小
                .foregroundStyle(.blue) // 設置顏色
                .symbolEffect(.rotate, value: motionManager.repCount == 0) // 添加旋轉效果
        }
        .buttonStyle(.borderless) // 設置按鈕樣式
        .disabled(motionManager.repCount == 0) // 禁用條件
        .opacity(motionManager.repCount == 0 ? 0.5 : 1.0) // 設置透明度
        .sensoryFeedback(.warning, trigger: motionManager.repCount == 0) // 添加警告回饋
        .accessibilityLabel("重置") // 設置無障礙標籤
    }

    private var workoutStatusIndicator: some View {
        Group {
            if isWorkoutInProgress { // 如果正在運動
                HStack(spacing: 8) { // 使用水平堆疊排列
                    Circle() // 圓形指示器
                        .fill(workoutState == .active ? Color.green : Color.orange) // 根據狀態設置顏色
                        .frame(width: 12, height: 12) // 設置大小
                        .symbolEffect(.pulse, options: .repeating) // 添加脈衝效果
                    
                    Text(workoutState == .active ? "運動中" : "已暫停") // 顯示狀態文字
                        .font(.subheadline) // 設置字體樣式
                        .foregroundStyle(.secondary) // 設置顏色
                }
                .transition(.blurReplace) // 添加模糊過場效果
            }
        }
    }

    // MARK: - Actions

    private func toggleWorkout() {
        withAnimation(.smooth) { // 平滑動畫效果
            switch workoutState {
            case .idle:
                startWorkout() // 開始運動
            case .active:
                pauseWorkout() // 暫停運動
            case .paused:
                resumeWorkout() // 恢復運動
            }
        }
    }

    private func startWorkout() {
        workoutState = .active // 設置狀態為運動中
        workoutStartTime = Date.now // 記錄開始時間
        motionManager.startUpdates() // 開始更新運動數據
    }

    private func pauseWorkout() {
        workoutState = .paused // 設置狀態為已暫停
        motionManager.stopUpdates() // 停止更新運動數據
    }

    private func resumeWorkout() {
        workoutState = .active // 設置狀態為運動中
        motionManager.startUpdates() // 恢復更新運動數據
    }

    private func endWorkout() {
        guard canSaveWorkout else { return } // 確保可以儲存
        
        motionManager.stopUpdates() // 停止更新運動數據
        
        let repsToSave = motionManager.repCount // 獲取次數
        
        Task {
            await saveWorkoutSession() // 儲存運動數據
            await MainActor.run {
                lastSavedRepCount = repsToSave // 更新最後儲存的次數
                resetWorkoutState() // 重置運動狀態
                showingSaveConfirmation = true // 顯示儲存確認
            }
        }
    }

    private func incrementCount() {
        guard isWorkoutInProgress else { return } // 確保正在運動
        withAnimation(.smooth) {
            motionManager.repCount += 1 // 增加次數
        }
    }

    private func resetCount() {
        withAnimation(.smooth) {
            motionManager.repCount = 0 // 重置次數
        }
    }

    private func resetWorkoutState() {
        workoutState = .idle // 設置狀態為 idle
        workoutStartTime = nil // 清除開始時間
        motionManager.repCount = 0 // 重置次數
    }

    // MARK: - Data Management (iOS 18+ async/await pattern)

    private func saveWorkoutSession() async {
        guard let startTime = workoutStartTime else {
            print("錯誤: 缺少開始時間")
            return
        }
        
        let newSession = WorkoutSession(
            startTime: startTime, // 設置開始時間
            repCount: motionManager.repCount // 設置次數
        )
        newSession.endTime = Date.now // 設置結束時間
        newSession.exerciseType = exerciseType // 設置運動類型
        
        await MainActor.run {
            modelContext.insert(newSession) // 插入新運動數據
        }
        
        do {
            try modelContext.save() // 儲存數據
            print("✅ 運動已儲存: \(exerciseType.name) - \(newSession.repCount) 次")
            WidgetCenter.shared.reloadAllTimelines() // 通知 Widget 更新
        } catch {
            print("❌ 儲存失敗: \(error.localizedDescription)")
        }
    }

    private func handleViewDisappear() {
        if workoutState == .active {
            motionManager.stopUpdates() // 停止更新運動數據
        }
        
        if isWorkoutInProgress && motionManager.repCount > 0 {
            print("⚠️ 警告: 有未儲存的運動資料") // 提醒未儲存的數據
        }
    }
}

// MARK: - Supporting Types

enum WorkoutState: Equatable {
    case idle      // 尚未開始
    case active    // 運動中
    case paused    // 已暫停
}
