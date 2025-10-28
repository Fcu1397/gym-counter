//
//  gym_counterWidgetBundle.swift
//  gym-counter
//
// 這個檔案定義了 Gym Counter 應用程式的小工具組。

import WidgetKit // 匯入 WidgetKit 框架以建立小工具。
import SwiftUI // 匯入 SwiftUI 框架以構建使用者介面。

@main // 指定這是小工具組的主要入口點。
struct GymCounterWidgetBundle: WidgetBundle { // 定義一個小工具組。
    var body: some Widget { // 定義小工具組的內容。
        gym_counterWidget() // 包含 Gym Counter 小工具。
        QuickStartWidget() // 包含快速開始小工具。
        DailyGoalWidget() // 包含每日目標小工具。
        StatsTextWidget() // 包含統計文字小工具。
        AddExerciseWidget() // 包含新增運動小工具。
        StatisticsWidget() // 包含統計小工具。
    }
}
