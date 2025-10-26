//
//  ContentView.swift
//  gym-counter
//
import SwiftUI
import SwiftData
import Observation
import WidgetKit // 匯入 WidgetKit

struct ContentView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Properties
    let exerciseType: ExerciseType
    
    // MARK: - State
    @State private var motionManager = MotionManager()
    @State private var workoutState: WorkoutState = .idle
    @State private var workoutStartTime: Date?
    @State private var showingSaveConfirmation = false
    @State private var lastSavedRepCount: Int = 0 // 用於儲存最後一次的次數
    
    // MARK: - Computed Properties
    private var isWorkoutInProgress: Bool {
        workoutState != .idle
    }
    
    private var canSaveWorkout: Bool {
        motionManager.repCount > 0 && workoutStartTime != nil
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 50) {
            headerSection
            countDisplay
            controlButtons
            workoutStatusIndicator
        }
        .padding()
        .navigationTitle(exerciseType.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("運動已儲存", isPresented: $showingSaveConfirmation) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("已記錄 \(lastSavedRepCount) 次") // 使用儲存的次數
        }
        .onDisappear {
            handleViewDisappear()
        }
        .backgroundStyle(.thinMaterial)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        Text(exerciseType.name)
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)
    }
    
    private var countDisplay: some View {
        Text("\(motionManager.repCount)")
            .font(.system(size: 120, weight: .heavy, design: .monospaced))
            .foregroundStyle(workoutState == .active ? .green : .primary)
            .contentTransition(.numericText())
            .animation(.smooth, value: motionManager.repCount) // iOS 18+ smooth animation
            .onTapGesture {
                incrementCount()
            }
            .sensoryFeedback(.impact, trigger: motionManager.repCount) // iOS 18+ 觸覺回饋
    }
    
    private var controlButtons: some View {
        HStack(spacing: 25) {
            playPauseButton
            stopButton
            resetButton
        }
    }
    
    private var playPauseButton: some View {
        Button(action: toggleWorkout) {
            Image(systemName: workoutState == .active ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(workoutState == .active ? .orange : .green)
                .symbolEffect(.bounce, value: workoutState) // iOS 18+ SF Symbols 動畫
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.selection, trigger: workoutState)
        .accessibilityLabel(workoutState == .active ? "暫停" : "開始")
    }
    
    private var stopButton: some View {
        Button(action: endWorkout) {
            Image(systemName: "stop.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
                .symbolEffect(.pulse, options: .repeating, value: canSaveWorkout) // iOS 18+ 脈衝效果
        }
        .buttonStyle(.borderless)
        .disabled(!canSaveWorkout)
        .opacity(canSaveWorkout ? 1.0 : 0.5)
        .sensoryFeedback(.success, trigger: showingSaveConfirmation)
        .accessibilityLabel("結束並儲存")
    }
    
    private var resetButton: some View {
        Button(action: resetCount) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .symbolEffect(.rotate, value: motionManager.repCount == 0) // iOS 18+ 旋轉效果
        }
        .buttonStyle(.borderless)
        .disabled(motionManager.repCount == 0)
        .opacity(motionManager.repCount == 0 ? 0.5 : 1.0)
        .sensoryFeedback(.warning, trigger: motionManager.repCount == 0)
        .accessibilityLabel("重置")
    }
    
    private var workoutStatusIndicator: some View {
        Group {
            if isWorkoutInProgress {
                HStack(spacing: 8) {
                    Circle()
                        .fill(workoutState == .active ? Color.green : Color.orange)
                        .frame(width: 12, height: 12)
                        .symbolEffect(.pulse, options: .repeating) // iOS 18+ 脈衝動畫
                    
                    Text(workoutState == .active ? "運動中" : "已暫停")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .transition(.blurReplace) // iOS 18+ 模糊過場效果
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleWorkout() {
        withAnimation(.smooth) { // iOS 18+ smooth animation
            switch workoutState {
            case .idle:
                startWorkout()
            case .active:
                pauseWorkout()
            case .paused:
                resumeWorkout()
            }
        }
    }
    
    private func startWorkout() {
        workoutState = .active
        workoutStartTime = Date.now // iOS 18+ 使用 Date.now
        motionManager.startUpdates()
    }
    
    private func pauseWorkout() {
        workoutState = .paused
        motionManager.stopUpdates()
    }
    
    private func resumeWorkout() {
        workoutState = .active
        motionManager.startUpdates()
    }
    
    private func endWorkout() {
        guard canSaveWorkout else { return }
        
        motionManager.stopUpdates()
        
        let repsToSave = motionManager.repCount
        
        Task {
            await saveWorkoutSession()
            await MainActor.run {
                lastSavedRepCount = repsToSave
                resetWorkoutState()
                showingSaveConfirmation = true
            }
        }
    }
    
    private func incrementCount() {
        guard isWorkoutInProgress else { return }
        withAnimation(.smooth) {
            motionManager.repCount += 1
        }
    }
    
    private func resetCount() {
        withAnimation(.smooth) {
            motionManager.repCount = 0
        }
    }
    
    private func resetWorkoutState() {
        workoutState = .idle
        workoutStartTime = nil
        motionManager.repCount = 0
    }
    
    // MARK: - Data Management (iOS 18+ async/await pattern)
    
    private func saveWorkoutSession() async {
        guard let startTime = workoutStartTime else {
            print("錯誤: 缺少開始時間")
            return
        }
        
        let newSession = WorkoutSession(
            startTime: startTime,
            repCount: motionManager.repCount
        )
        newSession.endTime = Date.now
        newSession.exerciseType = exerciseType
        
        // iOS 18+ SwiftData 改進的即時同步
        await MainActor.run {
            modelContext.insert(newSession)
        }
        
        do {
            // iOS 18+ 明確的儲存方法
            try modelContext.save()
            print("✅ 運動已儲存: \(exerciseType.name) - \(newSession.repCount) 次")
            
            // 通知 Widget 更新
            WidgetCenter.shared.reloadAllTimelines()
            
        } catch {
            print("❌ 儲存失敗: \(error.localizedDescription)")
            // iOS 18+ 可以使用 EnergyKit 監控儲存操作的能耗
        }
    }
    
    private func handleViewDisappear() {
        // 如果正在運動中離開畫面，停止陀螺儀但保留狀態
        if workoutState == .active {
            motionManager.stopUpdates()
        }
        
        // 可選：提醒使用者有未儲存的資料
        if isWorkoutInProgress && motionManager.repCount > 0 {
            print("⚠️ 警告: 有未儲存的運動資料")
        }
    }
}

// MARK: - Supporting Types

enum WorkoutState: Equatable {
    case idle      // 尚未開始
    case active    // 運動中
    case paused    // 已暫停
}



