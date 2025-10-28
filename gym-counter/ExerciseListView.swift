//
//  ExerciseListView.swift
//  gym-counter
//

import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext // SwiftData 的環境上下文
    // 使用 @Query 自動從 SwiftData 讀取所有 ExerciseType
    @Query(sort: \ExerciseType.name) private var exercises: [ExerciseType] // 按名稱排序的運動類型數據
    
    @State private var showingAddExercise = false // 控制是否顯示新增運動視窗的狀態

    var body: some View {
        NavigationStack { // 使用導航堆疊管理視圖
            List { // 列表顯示所有運動項目
                ForEach(exercises) { exercise in // 遍歷每個運動項目
                    // 每個列表項目都是一個導航連結，點擊後會進入計數畫面
                    NavigationLink(value: exercise) {
                        VStack(alignment: .leading) { // 垂直堆疊顯示運動名稱和目標肌群
                            Text(exercise.name).font(.headline) // 運動名稱，使用標題字體
                            Text(exercise.targetMuscle).font(.subheadline).foregroundColor(.secondary) // 目標肌群，使用副標題字體
                        }
                    }
                }
                .onDelete(perform: deleteExercises) // 支援刪除功能
            }
            .navigationTitle("選擇運動") // 設置導航標題
            .navigationDestination(for: ExerciseType.self) { exercise in
                // 這裡定義了點擊連結後要跳轉到的畫面
                ContentView(exerciseType: exercise) // 跳轉到 ContentView，傳遞選中的運動類型
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // 工具欄項目，放置在導航欄右側
                    Button(action: { showingAddExercise = true }) { // 點擊按鈕顯示新增運動視窗
                        Image(systemName: "plus") // 使用加號圖示
                    }
                }
            }
            // 彈出新增運動的視窗
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView() // 顯示新增運動的視圖
            }
            // 如果是空的，顯示提示
            .overlay {
                if exercises.isEmpty { // 當運動列表為空時顯示提示
                    ContentUnavailableView("沒有運動項目", systemImage: "figure.strengthtraining.traditional", description: Text("點擊右上角的 '+' 來新增您的第一個運動項目。")) // 顯示提示內容
                }
            }
        }
    }

    private func deleteExercises(offsets: IndexSet) { // 刪除運動項目
        withAnimation { // 使用動畫效果
            for index in offsets { // 遍歷要刪除的索引
                modelContext.delete(exercises[index]) // 刪除對應的運動項目
            }
        }
    }
}

#Preview {
    ExerciseListView()
        .modelContainer(for: ExerciseType.self) // 預覽時設置模型容器
}
