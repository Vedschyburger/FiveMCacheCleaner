#  PowerShell Script to Clear FivM Cache
#  This script automatically removes outdated cache folders from FiveM to free up disk space and help prevent potential issues.
#  © Vedschyburger https://github.com/Vedschyburger/

# Automatically use the correct user path
$BasePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "FiveM\FiveM.app\data"

# List of folders to be deleted
$FolderList = @("cache", "server-cache", "server-cache-priv")

# Iterate through each folder in the list
foreach ($Folder in $FolderList) {
    # Create the full path by combining the base path with the folder name
    $FullPath = Join-Path -Path $BasePath -ChildPath $Folder
    
    # Check if the folder exists at the full path
    if (Test-Path -Path $FullPath) {
        # Delete the folder and its contents
        Remove-Item -Path $FullPath -Recurse -Force
        Write-Host "Folder deleted: $FullPath"
    } else {
        # Inform that the folder was not found
        Write-Host "Folder not found: $FullPath"
    }
}

