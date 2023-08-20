Invoke-Expression (&starship init powershell)
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Import-Module ZLocation
Import-Module posh-git

Set-alias 'ifconfig' 'ipconfig'
Set-alias 'which' 'Get-Command'
Set-alias 'open' 'explorer.exe'
