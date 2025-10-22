//
//  ExerciseSelectionView.swift
//  GymCounter
//
//  運動選擇主畫面 - 顯示所有運動類型供使用者選擇
//
import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Query
    
    /// 查詢所有運動類型，按排序順序排列
    @Query(sort: \ExerciseType.sortOrder) private var exercises: [ExerciseType]
    
    // MARK: - State
    @State private var showingAddExercise = false
    @State private var showingStatistics = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                if exercises.isEmpty {
                    emptyStateView
                } else {
                    exerciseListView
                }
            }
            .navigationTitle("健身計數器")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    toolbarMenu
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
            .sheet(isPresented: $showingStatistics) {
            }
        }
    }
    
    // MARK: - View Components
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("尚無運動項目")
                .font(.title2.bold())
            
            Text("點擊右上角的 + 號\n新增你的第一個運動項目")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddExercise = true }) {
                Label("新增運動", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
    
    private var exerciseListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(exercises) { exercise in
                    NavigationLink(destination: ContentView()) {
                        ExerciseCard(exercise: exercise)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private var toolbarMenu: some View {
        Menu {
            Button(action: { showingAddExercise = true }) {
                Label("新增運動", systemImage: "plus")
            }
            
            Button(action: { showingStatistics = true }) {
                Label("統計資料", systemImage: "chart.bar")
            }
            
            Divider()
            
            Button(role: .destructive, action: deleteAllData) {
                Label("清除所有資料", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
        }
    }
    
    // MARK: - Actions
    
    private func deleteAllData() {
        // 刪除所有紀錄
        for exercise in exercises {
            modelContext.delete(exercise)
        }
        
        do {
            try modelContext.save()
            print("✅ 所有資料已清除")
        } catch {
            print("❌ 清除資料失敗: \(error)")
        }
    }
}

// MARK: - Exercise Card Component

struct ExerciseCard: View {
    let exercise: ExerciseType
    
    var body: some View {
        HStack(spacing: 16) {
            // 圖示
            Image(systemName: exercise.icon)
                .font(.system(size: 40))
                .foregroundStyle(.green)
                .frame(width: 60, height: 60)
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                
                Text(exercise.targetMuscle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !exercise.sessions.isEmpty {
                    HStack(spacing: 12) {
                        Label("\(exercise.sessions.count) 次", systemImage: "calendar")
                        Label("\(exercise.totalReps) 下", systemImage: "number")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 箭頭
            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.fill.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
