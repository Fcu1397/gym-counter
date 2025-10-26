//
//  ExerciseListView.swift
//  gym-counter
//

import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    // 使用 @Query 自動從 SwiftData 讀取所有 ExerciseType
    @Query(sort: \ExerciseType.name) private var exercises: [ExerciseType]
    
    @State private var showingAddExercise = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises) { exercise in
                    // 每個列表項目都是一個導航連結，點擊後會進入計數畫面
                    NavigationLink(value: exercise) {
                        VStack(alignment: .leading) {
                            Text(exercise.name).font(.headline)
                            Text(exercise.targetMuscle).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteExercises)
            }
            .navigationTitle("選擇運動")
            .navigationDestination(for: ExerciseType.self) { exercise in
                // 這裡定義了點擊連結後要跳轉到的畫面
                ContentView(exerciseType: exercise)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExercise = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // 彈出新增運動的視窗
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
            // 如果是空的，顯示提示
            .overlay {
                if exercises.isEmpty {
                    ContentUnavailableView("沒有運動項目", systemImage: "figure.strengthtraining.traditional", description: Text("點擊右上角的 '+' 來新增您的第一個運動項目。"))
                }
            }
        }
    }

    private func deleteExercises(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(exercises[index])
            }
        }
    }
}

#Preview {
    ExerciseListView()
        .modelContainer(for: ExerciseType.self)
}
