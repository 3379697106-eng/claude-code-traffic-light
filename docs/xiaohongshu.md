---

## 给 Claude Code 装了个红绿灯🚦，再也不用猜它在干嘛了！

经常用 Claude Code 写代码，发现一个痛点：切出去干别的事时，完全不知道它是还在跑、还是卡住等我了、还是已经完了😵‍💫

于是花了半天写了个桌面红绿灯组件：

🔴 红灯 = Claude 正在干活
🟡 黄灯 = 需要你做决定（权限/选择）
🟢 绿灯 = 已完成，没待办

一个小竖条浮在桌面左上角，自动变色，瞟一眼就知道状态✨

### 怎么做到的
- PowerShell + WinForms，**零依赖**，Windows 自带就能跑
- 利用 Claude Code 的 Hooks 机制自动检测状态
- 窗口置顶、无边框、可拖动、右键退出

### 怎么用
1. 下载 GitHub 仓库
2. 配置 Hooks（复制 settings.example.json）
3. 双击 `启动红绿灯.bat`
4. 重启 Claude Code，搞定

真的很小很小一个玩意但超级实用，写码幸福感+10086 🥹

🔗 GitHub：github.com/3379697106-eng/claude-code-traffic-light

#ClaudeCode #AI编程 #效率工具 #桌面美化 #程序员日常 #Windows小工具 #PowerShell

