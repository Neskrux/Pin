$py = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python" -Directory -Recurse -ErrorAction SilentlyContinue |
  Where-Object { Test-Path "$($_.FullName)\python.exe" } |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($py) {
  $pythonDir = $py.FullName
  $scriptsDir = Join-Path $pythonDir "Scripts"
  $userPath = [Environment]::GetEnvironmentVariable("Path","User")
  $newPath  = "$pythonDir;$scriptsDir;$userPath"
  [Environment]::SetEnvironmentVariable("Path",$newPath,"User")
  Write-Host "✅ Python e Scripts colocados no início do PATH do usuário. Abra um novo CMD e teste: python --version"
} else {
  Write-Host "❌ Não encontrei uma pasta com python.exe no diretório padrão do usuário."
}
