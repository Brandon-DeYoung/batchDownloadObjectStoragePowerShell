param($url)

$dev = $false

# Set the URL in development mode
if ($dev -eq $true) {
  $url = "https://objectstorage.us-ashburn-1.oraclecloud.com/p/X2FDHgjV4e9HqHnhsxkajNdP6S-I-onokYIgZ9yOVBmI6LyIXxg1BA-QtfAHwS3A/n/idfa0xm5fax7/b/ps1Test/o/"
}

# Request URL input if not provided
if (!$url) {
  $url = Read-Host "Please enter the PAR:"
}

# Fetch the JSON from the URL
$curlOutput = curl.exe -s $url

# Check if the output is not empty or null
if (![string]::IsNullOrWhiteSpace($curlOutput)) {
  $json = ConvertFrom-Json $curlOutput

  # Check if the JSON contains the "objects" property
  if ($json.objects) {
    Write-Output $curlOutput

    # Extract folder name from URL
    $urlParts = $url.Split("/")
    $folderName = $urlParts[$urlParts.Length - 3]

    # Create parent directory if it doesn't exist
    if (!(Test-Path $folderName)) {
      New-Item -ItemType Directory -Path $folderName
    }

    # Iterate through each object, create folders, and download files
    foreach ($obj in $json.objects) {
      if ($obj.name.EndsWith("/")) {
        $fullPath = Join-Path -Path $folderName -ChildPath $obj.name
        if (!(Test-Path $fullPath)) {
          New-Item -ItemType Directory -Path $fullPath
        }
      } else {
        $downloadUrl = $url + $obj.name
        $localPath = Join-Path -Path $folderName -ChildPath $obj.name
        Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath
      }
    }
  }
  else {
    # Prompt to regenerate PAR if no JSON object detected
    Write-Host "Error: Recreate the PAR with 'Enable Object Listing' enabled and run the script with the new PAR" -ForegroundColor Red
  }
}
else {
  # Error if the URL did not return valid JSON
  Write-Host "Error: The URL did not return valid JSON. Please check the URL and try again." -ForegroundColor Red
}
