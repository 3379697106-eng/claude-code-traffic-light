# Claude Code 红绿灯 🚦

桌面悬浮红绿灯，实时显示 Claude Code 运行状态。

| 灯色 | 含义 | 触发时机 |
|------|------|---------|
| 红灯 | Claude 工作中 | 启动会话 / 你发消息 |
| 黄灯 | 需要你决定 | 权限请求 / 询问问题 |
| 绿灯 | 无待办 | 回复完毕 / 会话结束 |

## 安装

### 1. 配置 Hooks

将以下内容添加到项目 `.claude/settings.json`（或参考本仓库 `.claude/settings.json`）：

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State running" }]
    }],
    "Stop": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State stopped" }]
    }],
    "UserPromptSubmit": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State running" }]
    }],
    "PermissionRequest": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State waiting" }]
    }],
    "Elicitation": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State waiting" }]
    }],
    "PostToolUse": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State running" }]
    }],
    "SessionEnd": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"路径/status_writer.ps1\" -State stopped" }]
    }]
  }
}
```

> 把 `路径` 替换为实际路径，如 `d:/Hello world`。

### 2. 启动红绿灯

双击 `启动红绿灯.bat`，或在终端运行：

```powershell
powershell -ExecutionPolicy Bypass -File "路径/traffic_light.ps1"
```

### 3. 重启 Claude Code

Hooks 在 Claude Code 重启后生效。

## 自定义音效

编辑 `traffic_light.ps1` 顶部的 `$soundFiles`，换成任意 `.wav` 路径即可：

```powershell
$soundFiles = @{
    running = "C:\Windows\Media\Windows Ding.wav"    # 红灯
    waiting = "C:\Windows\Media\Windows Notify.wav"  # 黄灯
    stopped = "C:\Windows\Media\chimes.wav"          # 绿灯
}
```

系统自带音效在 `C:\Windows\Media\`，设为 `$null` 则该状态静音。

## 交互

- **拖动窗口**：左键按住拖动
- **静音开关**：右键 → `Mute sounds` / `Unmute sounds`
- **退出**：右键 → Exit

## 文件说明

```
traffic_light.ps1   # 红绿灯悬浮窗（PowerShell + WinForms）
status_writer.ps1   # Hook 状态写入脚本
启动红绿灯.bat       # 一键启动
extension/          # VS Code 扩展（可选，进程监控备份）
```

## 依赖

- Windows 10/11
- PowerShell 5.1+（系统自带）

无需安装 Python 或任何第三方库。
