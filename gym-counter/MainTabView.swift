//
//  MainTabView.swift
//  gym-counter
//

import SwiftUI // 匯入 SwiftUI 框架，用於構建用戶界面

struct MainTabView: View { // 定義主標籤視圖
    @State private var selectedTab: Tab = .exercise // 定義當前選中的標籤，默認為運動標籤
    @State private var showAddExercise = false // 控制是否顯示新增運動視窗的狀態
    @State private var showStatistics = false // 控制是否顯示統計資料視窗的狀態
    
    enum Tab { // 定義標籤的枚舉類型
        case exercise // 運動標籤
        case stats // 統計標籤
    }
    
    var body: some View { // 主視圖的內容
        TabView(selection: $selectedTab) { // 使用 TabView 管理標籤頁面
            ExerciseSelectionView( // 運動選擇視圖
                showingAddExercise: $showAddExercise, // 傳遞新增運動狀態綁定
                showingStatistics: $showStatistics // 傳遞統計資料狀態綁定
            )
                .tabItem { // 定義標籤項目
                    Label("運動", systemImage: "figure.run") // 使用圖示和標籤描述
                }
                .tag(Tab.exercise) // 設置標籤的標識符
            
            StatsView() // 統計視圖
                .tabItem { // 定義標籤項目
                    Label("統計", systemImage: "chart.bar.fill") // 使用圖示和標籤描述
                }
                .tag(Tab.stats) // 設置標籤的標識符
        }
        .onOpenURL { url in // 處理深層鏈接的回調
            handleDeepLink(url) // 調用處理深層鏈接的方法
        }
    }
    
    private func handleDeepLink(_ url: URL) { // 處理深層鏈接的方法
        guard url.scheme == "gymcounter" else { return } // 確保鏈接的 scheme 是 gymcounter
        
        switch url.host { // 根據鏈接的主機部分進行處理
        case "stats":
            selectedTab = .stats // 切換到統計標籤
        case "exercise":
            selectedTab = .exercise // 切換到運動標籤
        case "add-exercise":
            // 先切換到運動頁面
            selectedTab = .exercise // 切換到運動標籤
            // 延遲一下再顯示新增運動頁面，確保頁面已經切換
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAddExercise = true // 顯示新增運動視窗
            }
        case "statistics":
            // 先切換到運動頁面
            selectedTab = .exercise // 切換到運動標籤
            // 延遲一下再顯示統計資料頁面
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showStatistics = true // 顯示統計資料視窗
            }
        default:
            break // 不處理其他鏈接
        }
    }
}

#Preview {
    MainTabView() // 預覽主標籤視圖
}
