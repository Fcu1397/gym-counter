//
//  Item.swift
//  gym-counter
//
//  定義一個簡單的數據模型，用於存儲時間戳。

import Foundation // 匯入 Foundation 框架以使用基本功能。
import SwiftData // 匯入 SwiftData 框架以進行資料管理。

@Model // 標記為 SwiftData 的模型。
final class Item { // 定義一個名為 Item 的數據模型。
    var timestamp: Date // 定義一個屬性，用於存儲時間戳。
    
    init(timestamp: Date) { // 初始化方法，用於創建 Item 實例。
        self.timestamp = timestamp // 將傳入的時間戳賦值給屬性。
    }
}
