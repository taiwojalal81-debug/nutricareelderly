$source = "C:\Users\JALAL\Desktop\NutriCare\Meals Diagram\*.*"
$dest = "C:\Users\JALAL\Desktop\NutriCare\assets\images"

Get-ChildItem -Path $source | ForEach-Object {
    $newName = $_.Name.ToLower().Replace(" ", "_")
    $destPath = Join-Path $dest $newName
    Copy-Item $_.FullName -Destination $destPath -Force
}
