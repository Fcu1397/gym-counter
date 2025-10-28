//
//  gym_counterApp.swift
//  gym-counter
//

import SwiftUI // 匯入 SwiftUI 框架，用於構建用戶界面
import SwiftData // 匯入 SwiftData 框架，用於數據管理

@main
struct GymCounterApp: App { // 主應用程序入口點
    // MARK: - App Group Configuration
    
    /// App Group Identifier - 用於 App 和 Widget 之間共享資料
    /// 記得在 Xcode 中啟用 App Groups 並使用相同的 identifier
    static let appGroupIdentifier = "group.com.buildwithashton.gym-counter" // 定義 App Group 的標識符
    
    // MARK: - Shared Model Container
    
    /// 共享的 SwiftData 容器 (App 和 Widget 都使用此容器)
    let sharedModelContainer: ModelContainer = { // 創建共享的數據容器
        let schema = Schema([ // 定義數據模型的結構
            ExerciseType.self, // 包括運動類型模型
            WorkoutSession.self // 包括運動紀錄模型
        ])
        
        let modelConfiguration = ModelConfiguration( // 配置數據容器
            schema: schema, // 使用定義的數據結構
            isStoredInMemoryOnly: false, // 是否僅存儲在內存中
            groupContainer: .identifier(GymCounterApp.appGroupIdentifier), // 使用 App Group 共享容器
            cloudKitDatabase: .none // 不使用 CloudKit
        )
        
        do {
            let container = try ModelContainer( // 嘗試創建數據容器
                for: schema, // 使用定義的數據結構
                configurations: [modelConfiguration] // 使用配置
            )
            
            // 首次啟動時插入預設資料
            GymCounterApp.insertDefaultDataIfNeeded(container: container) // 插入預設數據
            
            return container // 返回創建的容器
        } catch {
            fatalError("無法創建 ModelContainer: \(error)") // 如果創建失敗，終止程序並打印錯誤
        }
    }()
    
    // MARK: - Body
    
    var body: some Scene { // 定義應用程序的場景
        WindowGroup { // 主窗口組
            MainTabView() // 顯示主標籤視圖
        }
        .modelContainer(sharedModelContainer) // 將共享數據容器附加到場景
    }
    
    // MARK: - Helper Methods
    
    /// 首次啟動時插入預設運動類型
    static func insertDefaultDataIfNeeded(container: ModelContainer) { // 插入預設數據的輔助方法
        let context = ModelContext(container) // 創建數據上下文
        
        // 檢查是否已有資料
        let fetchDescriptor = FetchDescriptor<ExerciseType>() // 定義查詢描述符
        
        do {
            let existingExercises = try context.fetch(fetchDescriptor) // 查詢現有的運動類型
            
            // 如果沒有資料，插入預設運動類型
            if existingExercises.isEmpty {
                print("📝 首次啟動，插入預設運動類型...") // 打印提示信息
                
                for (index, exercise) in ExerciseType.sampleExercises.enumerated() { // 遍歷預設運動類型
                    exercise.sortOrder = index + 1 // 設置排序順序
                    context.insert(exercise) // 插入運動類型到上下文
                }
                
                try context.save() // 保存更改
                print("✅ 預設運動類型已插入") // 打印成功信息
            }
        } catch {
            print("❌ 檢查或插入預設資料失敗: \(error)") // 打印錯誤信息
        }
    }
}

// MARK: - Shared Container Helper (供 Widget 使用)

extension GymCounterApp { // GymCounterApp 的擴展
    /// 取得共享的 ModelContainer (供 Widget 使用)
    static func createSharedContainer() throws -> ModelContainer { // 創建共享數據容器的方法
        let schema = Schema([ // 定義數據模型的結構
            ExerciseType.self, // 包括運動類型模型
            WorkoutSession.self // 包括運動紀錄模型
        ])
        
        // 暫時使用本地存儲
        let modelConfiguration = ModelConfiguration( // 配置數據容器
            schema: schema, // 使用定義的數據結構
            isStoredInMemoryOnly: false, // 是否僅存儲在內存中
            groupContainer: .identifier(GymCounterApp.appGroupIdentifier), // 使用 App Group 共享容器
            cloudKitDatabase: .none // 不使用 CloudKit
        )
        
        return try ModelContainer( // 嘗試創建數據容器
            for: schema, // 使用定義的數據結構
            configurations: [modelConfiguration] // 使用配置
        )
    }
}
