//
//  AddExerciseView.swift
//  gym-counter
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    @State private var name = ""
    @State private var targetMuscle = ""
    @State private var selectedIcon = "figure.mixed.cardio"
    @State private var showError = false
    @State private var errorMessage = ""
    
    // MARK: - Constants
    
    // 常用運動圖示
    private let commonIcons = [
        "figure.arms.open",          // 伏地挺身
        "figure.flexibility",        // 深蹲
        "figure.core.training",      // 仰臥起坐
        "figure.climbing",           // 引體向上
        "figure.mind.and.body",      // 平板支撐
        "figure.mixed.cardio",       // 有氧運動
        "figure.strengthtraining.traditional", // 重訓
        "figure.walk",               // 行走
        "figure.run",                // 跑步
        "dumbbell.fill"              // 啞鈴
    ]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                iconSelectionSection
            }
            .navigationTitle("新增運動")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") { saveExercise() }
                        .disabled(name.isEmpty)
                }
            }
            .alert("錯誤", isPresented: $showError) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var basicInfoSection: some View {
        Section("基本資訊") {
            TextField("運動名稱", text: $name)
                .textInputAutocapitalization(.never)
            
            TextField("目標肌群", text: $targetMuscle)
                .textInputAutocapitalization(.never)
        }
    }
    
    private var iconSelectionSection: some View {
        Section("選擇圖示") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                ForEach(commonIcons, id: \.self) { icon in
                    iconButton(for: icon)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func iconButton(for icon: String) -> some View {
        Button(action: {
            withAnimation(.smooth) {
                selectedIcon = icon
            }
        }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(selectedIcon == icon ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(selectedIcon == icon ? Color.green : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedIcon)
    }
    
    // MARK: - Actions
    
    private func saveExercise() {
        // 獲取當前所有運動的最大 sortOrder
        let descriptor = FetchDescriptor<ExerciseType>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        
        let maxSortOrder: Int
        do {
            let exercises = try modelContext.fetch(descriptor)
            maxSortOrder = exercises.first?.sortOrder ?? 0
        } catch {
            maxSortOrder = 0
        }
        
        let newExercise = ExerciseType(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            targetMuscle: targetMuscle.isEmpty ? "全身" : targetMuscle.trimmingCharacters(in: .whitespacesAndNewlines),
            isCustom: true,
            sortOrder: maxSortOrder + 1
        )
        
        modelContext.insert(newExercise)
        
        do {
            try modelContext.save()
            print("✅ 新運動已儲存: \(name)")
            dismiss()
        } catch {
            print("❌ 儲存失敗: \(error.localizedDescription)")
            errorMessage = "儲存失敗: \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - Preview

#Preview {
    AddExerciseView()
        .modelContainer(for: [ExerciseType.self, WorkoutSession.self])
}
