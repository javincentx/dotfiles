# sync.ps1 - Git 一键同步脚本
param(
    [Parameter(Position=0)]
    [string]$Message
)

# 1. 自动生成备注：如果没有输入备注，则使用当前时间
if (-not $Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "update: routine sync ($timestamp)"
}

# 2. 检查 Git 仓库环境
if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
    Write-Host "❌ 错误：当前目录不是 Git 仓库！" -ForegroundColor Red
    return
}

Write-Host "`n🚀 准备同步..." -ForegroundColor Cyan

# 3. 添加所有更改
git add -A
Write-Host "✔ 已暂存所有更改" -ForegroundColor Green

# 4. 检查是否有需要提交的内容
$status = git status --porcelain
if (-not $status) {
    Write-Host "✨ 环境已是最新，无需提交。" -ForegroundColor Yellow
    return
}

# 5. 执行提交
git commit -m "$Message"
Write-Host "✔ 已提交: $Message" -ForegroundColor Green

# 6. 推送到 GitHub
Write-Host "📤 正在推送到远程仓库..." -ForegroundColor Cyan
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 同步成功！你的配置已安全备份到云端。" -ForegroundColor Green
} else {
    Write-Host "❌ 推送失败，请检查网络或 SSH 配置。" -ForegroundColor Red
}