[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# --- 自动补全增强 ---

# 1. 启用预测文本功能（从历史记录中获取预测）
Set-PSReadLineOption -PredictionSource History

# 2. 设置 Tab 键为菜单式补全（按一下 Tab 出现列表，再按循环选择，类似 Zsh）
Set-PSReadLineOption -EditMode Emacs # 推荐 Emacs 模式，更像 Linux
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# 3. 改变预测文本的颜色（可选，默认是浅灰色）
Set-PSReadLineOption -Colors @{ InlinePrediction = '#7A7A7A' }

# 开启代理函数
function proxy {
    $Env:http_proxy="http://127.0.0.1:7890"
    $Env:https_proxy="http://127.0.0.1:7890"
    Write-Host "Proxy On" -ForegroundColor Green
}

# 关闭代理函数
function unproxy {
    $Env:http_proxy=$null
    $Env:https_proxy=$null
    Write-Host "Proxy Off" -ForegroundColor Red
}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression


# 基础 ls：只显示图标和分类排序
function ls {
    eza --icons --group-directories-first $args
}

# ll：详细列表，包含 Git 状态、文件大小、权限和 ISO 时间格式
function ll {
    eza -l --icons --git --group-directories-first --time-style=long-iso $args
}

function la {
    eza -la --icons --git --group-directories-first $args
}

# lt：以树状结构展示（默认展示 2 层）
function lt {
    eza --tree --level=2 --icons --group-directories-first $args
}

function lsg {
    param([string]$pattern)
    # --color=always 保留 eza 颜色
    # --icons 保留图标
    # rg 是 ripgrep，过滤匹配项
    eza --color=always --icons --group-directories-first | rg $pattern
}

if (Test-Path Alias:ls) { Remove-Item Alias:ls }

function lf {
    fzf --preview 'eza --color=always --icons --tree --level=2 {}'
}


zoxide init powershell | Out-String | Invoke-Expression

# 跳转并自动 ll
function zl {
    z $args
    ll
}


# 使用 FZF 搜索历史命令
function Search-History {
    $command = Get-History | Select-Object -Unique -Property CommandLine | 
               Sort-Object -Descending | Out-String -Stream | 
               fzf --height 40% --layout=reverse --border
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command.Trim())
    }
}

# 绑定 Ctrl + R 到搜索函数
Set-PSReadLineKeyHandler -Key "Ctrl+r" -ScriptBlock { Search-History }


# 输入 frp (find-in-file-preview) 后输入关键词，实时在右侧预览代码行
function frp {
    rg --line-number --column --no-heading --color=always --smart-case $args | fzf --ansi --preview 'bat --style=numbers --color=always --highlight-line {2} {1}'
}