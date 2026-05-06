$base = 'http://localhost:5000'
$outdir = 's:\Projects\iStart\istart-backend\test_output'

New-Item -ItemType Directory -Force -Path $outdir | Out-Null

Write-Host "Registering founder..."
$founder = Invoke-RestMethod -Uri "$base/api/auth/register" -Method Post -Body (ConvertTo-Json @{name='Founder'; email='founder@example.com'; password='pass123'; role='founder'}) -ContentType 'application/json'
$founder | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'founder.json')

Write-Host "Registering collaborator..."
$collab = Invoke-RestMethod -Uri "$base/api/auth/register" -Method Post -Body (ConvertTo-Json @{name='Collab'; email='collab@example.com'; password='pass123'; role='collaborator'}) -ContentType 'application/json'
$collab | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'collab.json')

Write-Host "Registering investor..."
$investor = Invoke-RestMethod -Uri "$base/api/auth/register" -Method Post -Body (ConvertTo-Json @{name='Investor'; email='investor@example.com'; password='pass123'; role='investor'}) -ContentType 'application/json'
$investor | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'investor.json')

Write-Host "Creating idea as founder..."
$founderToken = $founder.token
$idea = Invoke-RestMethod -Uri "$base/api/ideas" -Method Post -Headers @{ Authorization = "Bearer $founderToken" } -Body (ConvertTo-Json @{title='Smoke Test Idea'; description='Smoke test'}) -ContentType 'application/json'
$idea | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'idea.json')

Write-Host "Creating common thread (founder+collab+investor)..."
 $collabToken = $collab.token
 $investorToken = $investor.token
 $participants = @($founder.user.id, $collab.user.id, $investor.user.id)

 try {
		 $thread = Invoke-RestMethod -Uri "$base/api/discussion" -Method Post -Headers @{ Authorization = "Bearer $collabToken" } -Body (ConvertTo-Json @{ startupIdeaId = $idea._id; title = 'Common Thread'; participants = $participants }) -ContentType 'application/json' -ErrorAction Stop
		 $thread | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'thread.json')
 } catch {
		 Write-Host "Error creating thread: $_"
		 if ($_.Exception.Response -and $_.Exception.Response.GetResponseStream()) {
			 $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
			 $body = $reader.ReadToEnd(); $reader.Close(); Write-Host "Response body: $body"
		 }
 }

Write-Host "Posting a message as collaborator..."
 try {
		 $msg = Invoke-RestMethod -Uri "$base/api/discussion/$($thread._id)/messages" -Method Post -Headers @{ Authorization = "Bearer $collabToken" } -Body (ConvertTo-Json @{ content = 'Hello from collaborator' }) -ContentType 'application/json' -ErrorAction Stop
		 $msg | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'message.json')
 } catch {
		 Write-Host "Error posting message: $_"
		 if ($_.Exception.Response -and $_.Exception.Response.GetResponseStream()) {
			 $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
			 $body = $reader.ReadToEnd(); $reader.Close(); Write-Host "Response body: $body"
		 }
 }

Write-Host "Fetching founder notifications..."
$notifications = Invoke-RestMethod -Uri "$base/api/notifications" -Method Get -Headers @{ Authorization = "Bearer $founderToken" }
$notifications | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 (Join-Path $outdir 'notifications.json')

Write-Host "Smoke test complete. Outputs written to $outdir"
