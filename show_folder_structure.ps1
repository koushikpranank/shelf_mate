# Save this as show_folder_structure.ps1 and run it inside your project folder

# Change directory to lib folder
Set-Location -Path .\lib

function Show-Tree {
    param (
        [Parameter(Mandatory=$true)]
        [string]$path,

        [int]$indent = 0
    )

    $items = Get-ChildItem -Path $path | Sort-Object -Property PSIsContainer, Name -Descending
    foreach ($item in $items) {
        $prefix = ' ' * $indent
        if ($item.PSIsContainer) {
            Write-Host "${prefix}[Folder] $($item.Name)"
            Show-Tree -path $item.FullName -indent ($indent + 4)
        }
        else {
            if ($item.Extension -eq '.dart' -or $item.Extension -eq '.arb') {
                Write-Host "${prefix}[File] $($item.Name)"
            }
        }
    }
}

# Run the Show-Tree function starting at current directory (lib)
Show-Tree -path (Get-Location)
