# Define variables
$extensionUrl = "https://github.com/prathameshpatil1001/chrome-extension-host/archive/refs/heads/main.zip"  # URL of the extension's ZIP file
$tempZipPath = "$env:TEMP\extension.zip"                                             # Temporary path for the downloaded ZIP
$extractPath = "$env:TEMP\extension"                                                 # Path where the ZIP will be extracted
$chromePath = "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe"              # Path to the Chrome executable

# Step 1: Download the extension ZIP without showing it in the Downloads folder
Invoke-WebRequest -Uri $extensionUrl -OutFile $tempZipPath

# Step 2: Extract the downloaded ZIP file to a temporary location
Expand-Archive -Path $tempZipPath -DestinationPath $extractPath -Force

# Step 3: Identify the unpacked extension folder
$unpackedExtensionPath = Join-Path $extractPath "chrome-extension-host-main"  # Adjust based on the extracted folder name

# Step 4: Launch Chrome with the unpacked extension loaded
Start-Process -FilePath $chromePath -ArgumentList "--load-extension=$unpackedExtensionPath"

# Step 5: Clean up the temporary files (optional)
Remove-Item -Path $tempZipPath -Force
# Optionally keep the extracted files if you want to test further
# Remove-Item -Path $extractPath -Recurse -Force
