$baseUrl = "http://localhost:3000/api"
$email = "testuser_$(Get-Random)@university.edu"
$password = "Password123!"

function Test-Endpoint {
    param($Name, $Method, $Path, $Body, $Token, $IsMultipart = $false)
    Write-Host "`n[TEST] $Name" -ForegroundColor Cyan
    $headers = @{}
    if ($Token) { $headers["Authorization"] = "Bearer $Token" }
    
    try {
        if ($IsMultipart) {
            $response = Invoke-RestMethod -Uri "$baseUrl$Path" -Method $Method -Headers $headers -Body $Body -ContentType "multipart/form-data; boundary=test_boundary"
        } else {
            $headers["Content-Type"] = "application/json"
            $response = Invoke-RestMethod -Uri "$baseUrl$Path" -Method $Method -Headers $headers -Body ($Body | ConvertTo-Json)
        }
        Write-Host "Success!" -ForegroundColor Green
        return $response
    } catch {
        Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) { Write-Host "Details: $($_.ErrorDetails.Message)" }
        return $null
    }
}

# --- Module 1: Auth ---
$registerData = @{ name = "Test User"; email = $email; password = $password; role = "STUDENT" }
$regRes = Test-Endpoint "M1: Register User" "Post" "/auth/register" $registerData

$loginData = @{ email = $email; password = $password }
$loginRes = Test-Endpoint "M1: Login User" "Post" "/auth/login" $loginData
$token = $loginRes.token
if (-not $token) { Write-Error "No token, stopping."; exit }

# --- Module 2: Schedule ---
$scheduleData = @{
    className = "Full System Test Class"; startTime = "09:00"; endTime = "10:30"
    dayOfWeek = "Monday"; roomNumber = "Room 101"; description = "Testing"
}
$schedRes = Test-Endpoint "M2: Create Schedule" "Post" "/schedules" $scheduleData $token
Test-Endpoint "M2: Get Timetable" "Get" "/schedules/timetable" $null $token

# --- Module 3: Assignments ---
$assignmentData = @{
    title = "Test Paper"; description = "System test assignment"
    deadline = (Get-Date).AddDays(1).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    subject = "Computer Science"; priority = "HIGH"
}
$assignRes = Test-Endpoint "M3: Create Assignment" "Post" "/assignments" $assignmentData $token

# --- Module 4: AI Assistant ---
Test-Endpoint "M4: Get Task Priority" "Get" "/ai/prioritize" $null $token
Test-Endpoint "M4: Get Workload" "Get" "/ai/workload" $null $token
Test-Endpoint "M4: Get Suggestions" "Get" "/ai/suggestions" $null $token

# --- Module 5: Discussion ---
$groupData = @{ name = "Full System Test Group"; description = "Testing Collaboration" }
$groupRes = Test-Endpoint "M5: Create Group" "Post" "/discussions/groups" $groupData $token

if ($groupRes.id) {
    $msgData = @{ content = "Hello from full test!"; groupId = $groupRes.id }
    $msgRes = Test-Endpoint "M5: Post Message" "Post" "/discussions/messages" $msgData $token
    
    if ($msgRes.id) {
        $commentData = @{ content = "Test comment"; messageId = $msgRes.id }
        Test-Endpoint "M5: Post Comment" "Post" "/discussions/comments" $commentData $token
    }
}

# --- Module 6: Study Materials (Simple Multipart) ---
$LF = "`r`n"
$boundary = "test_boundary"
$multipartBody = "--$boundary$LF" +
                 "Content-Disposition: form-data; name=`"title`"$LF$LF" +
                 "Test Notes$LF" +
                 "--$boundary$LF" +
                 "Content-Disposition: form-data; name=`"courseName`"$LF$LF" +
                 "CS101$LF" +
                 "--$boundary$LF" +
                 "Content-Disposition: form-data; name=`"file`"; filename=`"test.txt`"$LF" +
                 "Content-Type: text/plain$LF$LF" +
                 "Sample note content for test.$LF" +
                 "--$boundary--$LF"

$matRes = Test-Endpoint "M6: Upload Material" "Post" "/materials/upload" $multipartBody $token $true
Test-Endpoint "M6: List Materials" "Get" "/materials" $null $token

# --- Module 7: Notifications ---
Test-Endpoint "M7: Get Notifications" "Get" "/notifications" $null $token

# --- Module 8: Admin (Verify Access Denied for Student) ---
Test-Endpoint "M8: Get Admin Logs (Should Fail)" "Get" "/admin/logs" $null $token

Write-Host "`nFull System Test Completed!" -ForegroundColor Yellow
