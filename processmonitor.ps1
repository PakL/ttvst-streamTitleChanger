while(0 -ne 1) {
  try {
    Get-Process | ? { $_.Path -ne $null -and $_.Path -notmatch '\\windows\\(system32\\|explorer.exe|windowsapps\\|systemapps\\)' } | % { $_.Path }
    Write-Host -NoNewline '###'
    Start-Sleep -m 15000
  } catch {
    Write-Error $_
  }
}