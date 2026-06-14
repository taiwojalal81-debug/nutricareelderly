$filePath = "C:\Users\JALAL\Desktop\NutriCare\food_images_download_list.md"
$content = Get-Content -Path $filePath -Raw
$content = $content -replace '\[Search Unsplash\]\(https://unsplash.com/s/photos/(.*?)\)', '[Search Google Images](https://www.google.com/search?tbm=isch&q=$1)'
$content = $content -replace '-food', '+food'
Set-Content -Path $filePath -Value $content
