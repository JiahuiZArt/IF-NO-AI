# IF-NO-AI

`如果没有AI（If No AI）` 是一个基于 **SwiftUI + MVVM** 的 iOS 16+ 专注应用：
- 通过 Screen Time API 选择并限制 AI 相关 App
- 专注成功推动“城市成长”
- 专注失败触发城市衰退并清空连胜

## 项目结构

```
IfNoAI.xcodeproj
IfNoAI/
  IfNoAIApp.swift
  IfNoAI.entitlements
  Models/
  ViewModels/
  Views/
  Services/
  Resources/Info.plist
```

## 运行方式

1. 使用 Xcode 打开 `IfNoAI.xcodeproj`。
2. 设置你的 Team（Signing）。
3. 在真机上授权 Screen Time（模拟器通常无法完整测试 FamilyControls 限制行为）。
4. 运行应用，在首页选择要限制的 App 并开始专注。

## 关键能力

- `FamilyActivityPicker` 选择限制应用
- `ManagedSettingsStore` 在专注时施加 shield
- 倒计时（30/60/120 分钟）和状态流转（idle/running/success/failed）
- 城市等级（荒地/小镇/城市）与进度系统
- 连续打卡（streak）和本地历史记录（UserDefaults）
