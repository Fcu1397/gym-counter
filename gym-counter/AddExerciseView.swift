//
//  AddExerciseView.swift
//  gym-counter
//

import SwiftUI
import SwiftData

// 新增運動的視圖，允許用戶輸入運動名稱、目標肌群並選擇圖示
struct AddExerciseView: View {

    // MARK: - Environment
    // 用於關閉視圖的環境變數
    @Environment(\.dismiss) private var dismiss
    // 用於管理資料模型的環境變數
    @Environment(\.modelContext) private var modelContext

    // MARK: - State
    // 運動名稱的狀態變數
    @State private var name = ""
    // 目標肌群的狀態變數
    @State private var targetMuscle = ""
    // 選中圖示的狀態變數，預設為 "figure.mixed.cardio"
    @State private var selectedIcon = "figure.mixed.cardio"
    // 是否顯示錯誤提示的狀態變數
    @State private var showError = false
    // 錯誤訊息的狀態變數
    @State private var errorMessage = ""

    // MARK: - Constants
    
    // 常用運動圖示的陣列，包含各種系統圖示名稱
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

    // 視圖的主體，包含導航堆疊和表單
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection // 基本資訊區段
                iconSelectionSection // 圖示選擇區段
            }
            .navigationTitle("新增運動") // 設置導航標題
            .navigationBarTitleDisplayMode(.inline) // 設置標題顯示模式
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() } // 取消按鈕，關閉視圖
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") { saveExercise() } // 儲存按鈕，觸發儲存動作
                        .disabled(name.isEmpty) // 當名稱為空時禁用按鈕
                }
            }
            .alert("錯誤", isPresented: $showError) { // 錯誤提示框
                Button("確定", role: .cancel) { } // 確定按鈕
            } message: {
                Text(errorMessage) // 顯示錯誤訊息
            }
        }
    }

    // MARK: - View Components

    // 基本資訊區段，包含運動名稱和目標肌群的輸入欄位
    private var basicInfoSection: some View {
        Section("基本資訊") {
            TextField("運動名稱", text: $name) // 運動名稱輸入框
                .textInputAutocapitalization(.never) // 禁用自動大寫
            
            TextField("目標肌群", text: $targetMuscle) // 目標肌群輸入框
                .textInputAutocapitalization(.never) // 禁用自動大寫
        }
    }

    // 圖示選擇區段，顯示常用圖示的網格
    private var iconSelectionSection: some View {
        Section("選擇圖示") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                ForEach(commonIcons, id: \.self) { icon in
                    iconButton(for: icon) // 為每個圖示創建按鈕
                }
            }
            .padding(.vertical, 8) // 設置垂直間距
        }
    }

    // 為指定圖示創建按鈕視圖，處理選中狀態和動畫
    private func iconButton(for icon: String) -> some View {
        Button(action: {
            withAnimation(.smooth) { // 使用動畫切換選中狀態
                selectedIcon = icon
            }
        }) {
            Image(systemName: icon) // 顯示圖示
                .font(.title2) // 設置字體大小
                .foregroundStyle(selectedIcon == icon ? .white : .primary) // 設置前景顏色
                .frame(width: 60, height: 60) // 設置框架大小
                .background(selectedIcon == icon ? Color.green : Color.gray.opacity(0.2)) // 設置背景顏色
                .clipShape(RoundedRectangle(cornerRadius: 12)) // 設置圓角矩形
        }
        .buttonStyle(.plain) // 設置按鈕樣式
        .sensoryFeedback(.selection, trigger: selectedIcon) // 添加感官反饋
    }

    // MARK: - Actions

    // 儲存新運動的方法，計算排序順序並插入資料模型
    private func saveExercise() {
        // 獲取當前所有運動的最大 sortOrder
        let descriptor = FetchDescriptor<ExerciseType>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        
        let maxSortOrder: Int
        do {
            let exercises = try modelContext.fetch(descriptor) // 嘗試獲取運動數據
            maxSortOrder = exercises.first?.sortOrder ?? 0 // 獲取最大排序值
        } catch {
            maxSortOrder = 0 // 如果出錯，默認為 0
        }
        
        let newExercise = ExerciseType(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines), // 去除名稱的空白字符
            icon: selectedIcon, // 設置選中圖示
            targetMuscle: targetMuscle.isEmpty ? "全身" : targetMuscle.trimmingCharacters(in: .whitespacesAndNewlines), // 設置目標肌群
            isCustom: true, // 標記為自定義
            sortOrder: maxSortOrder + 1 // 設置排序值
        )
        
        modelContext.insert(newExercise) // 插入新運動
        
        do {
            try modelContext.save() // 嘗試保存數據
            print("✅ 新運動已儲存: \(name)") // 打印成功訊息
            dismiss() // 關閉視圖
        } catch {
            print("❌ 儲存失敗: \(error.localizedDescription)") // 打印錯誤訊息
            errorMessage = "儲存失敗: \(error.localizedDescription)" // 設置錯誤訊息
            showError = true // 顯示錯誤提示
        }
    }
}

// MARK: - Preview

#Preview {
    AddExerciseView()
        .modelContainer(for: [ExerciseType.self, WorkoutSession.self]) // 設置模型容器
}
