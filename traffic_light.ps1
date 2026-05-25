Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$statusFile = "$env:USERPROFILE\.claude\status.json"
$width = 64
$height = 168

$colors = @{
    running = @{ fill = "#e74c3c"; glow = "#ff6b6b" }
    waiting = @{ fill = "#f1c40f"; glow = "#ffe066" }
    stopped = @{ fill = "#2ecc71"; glow = "#5eff8a" }
}
$dark = "#3a3a3a"
$bg   = "#2d2d2d"

$stateOrder = @("running", "waiting", "stopped")
$currentState = "stopped"

function Read-Status {
    try {
        if (Test-Path $statusFile) {
            $json = Get-Content $statusFile -Raw | ConvertFrom-Json
            return $json.state
        }
    } catch {}
    return "stopped"
}

$form = New-Object System.Windows.Forms.Form
$targetSize = New-Object System.Drawing.Size($width, $height)
$form.ClientSize = $targetSize
$form.MinimumSize = $targetSize
$form.MaximumSize = $targetSize
$form.StartPosition = "Manual"
$form.Location = New-Object System.Drawing.Point(100, 100)
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml($bg)

$dragging = $false
$dragOffset = $null

$form.Add_MouseDown({
    if ($_.Button -eq "Left") {
        $script:dragging = $true
        $cursorPos = [System.Windows.Forms.Cursor]::Position
        $script:dragOffset = New-Object System.Drawing.Point(
            ($cursorPos.X - $form.Location.X),
            ($cursorPos.Y - $form.Location.Y)
        )
    }
})
$form.Add_MouseMove({
    if ($script:dragging) {
        $cursorPos = [System.Windows.Forms.Cursor]::Position
        $form.Location = New-Object System.Drawing.Point(
            ($cursorPos.X - $script:dragOffset.X),
            ($cursorPos.Y - $script:dragOffset.Y)
        )
    }
})
$form.Add_MouseUp({
    if ($_.Button -eq "Left") { $script:dragging = $false }
})

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$exitItem = $menu.Items.Add("Exit")
$exitItem.Add_Click({ $form.Close() })
$form.ContextMenuStrip = $menu

$form.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = "AntiAlias"

    $centers = @(
        @{x=32; y=28},
        @{x=32; y=84},
        @{x=32; y=140}
    )

    for ($i = 0; $i -lt $stateOrder.Count; $i++) {
        $state = $stateOrder[$i]
        $c = $centers[$i]
        $r = 14
        $active = ($state -eq $script:currentState)

        if ($active) {
            $color = $colors[$state]
            $glowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($color.glow))
            $g.FillEllipse($glowBrush, $c.x - $r - 2, $c.y - $r - 2, ($r+2)*2, ($r+2)*2)
            $glowBrush.Dispose()
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($color.fill))
            $g.FillEllipse($brush, $c.x - $r, $c.y - $r, $r*2, $r*2)
            $brush.Dispose()
        } else {
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($dark))
            $g.FillEllipse($brush, $c.x - $r, $c.y - $r, $r*2, $r*2)
            $brush.Dispose()
        }
    }
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$timer.Add_Tick({
    $newState = Read-Status
    if ($newState -ne $script:currentState) {
        $script:currentState = $newState
        $form.Invalidate()
    }
})
$timer.Start()

$form.ShowDialog()
