$pythonPath = (Get-Command python.exe -ErrorAction SilentlyContinue).Source

if (-not $pythonPath) {
    $pythonPath = (Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\Python" -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { Test-Path "$($_.FullName)\python.exe" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1).FullName
}

if ($pythonPath) {
    $pythonDir = Split-Path $pythonPath
    $scriptsDir = Join-Path $pythonDir "Scripts"
    setx PATH "$env:PATH;$pythonDir;$scriptsDir"
    Write-Host "✅ Python adicionado ao PATH. Feche e reabra o terminal."
} else {
    Write-Host "❌ Python não encontrado no diretório padrão."
}
