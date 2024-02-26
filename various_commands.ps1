Install-Module -Name MicrosoftTeams

$Username = 'teleconf.econ@uth.gr'
$Password = 'xxxxxx'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force

$SecureString = $pass
# Users you password securly
# $MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$SecureString



# Define the password as a secure string
#$password = ConvertTo-SecureString "MyPassword123!" -AsPlainText -Force

# Convert the secure string to a plain text string
$passwordString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

# Create the password credential object
$passwordCredential = New-Object Microsoft.Open.AzureAD.Model.PasswordCredential -ArgumentList "MyPasswordCredential", $passwordString

# Create the Azure AD application
#New-AzureADApplication -DisplayName "MyApplication" -PasswordCredentials $passwordCredential



Connect-MicrosoftTeams -TenantId $Username -Credential $passwordCredential



get-Team -User teleconf.econ@o365.uth.gr | Format-Table -Property DisplayName

$group = New-Team -DisplayName "Δοκιμαστική ΔΙΚΑΙΟ 2024" -Description "Περιγραφή Δοκιμαστική ΔΙΚΑΙΟ 2024" -AllowGiphy $false -AllowDeleteChannels $false -AllowCreateUpdateRemoveTabs $false -AllowCreateUpdateRemoveConnectors $false -AllowCreateUpdateChannels $false -AllowAddRemoveApps $false

Add-TeamUser -GroupId $group.GroupId -User "vtzimourtos@o365.uth.gr" -Role Member

Remove-TeamUser -GroupId $group.GroupId -User "vtzimourtos@o365.uth.gr" -Role Owner

Set-TeamPicture -GroupId $group.GroupId -ImagePath  D:\Tests\powercsv\teleconfECON.png

Set-TeamPicture -GroupId 'a6b3f822-b2fd-45ca-99c3-169d7b3b1250' -ImagePath D:\Tests\powercsv\teleconfECON.png

Get-Team | Group-Object description | Format-Table -Property groupid,displayname,description -AutoSize | Out-File -FilePath D:\Tests\powercsv\UThMsTeams.txt


get-Team -User teleconf.econ@o365.uth.gr | Group-Object description

get-Team -User teleconf.econ@o365.uth.gr | Filter -Description = 'Δοκιμαστική ΔΙΚΑΙΟ 2024' | Format-Table -Property groupid,displayname,description -AutoSize | Out-File -FilePath D:\Tests\powercsv\UThMsTeams.txt

get-Team -User teleconf.econ@o365.uth.gr | Format-Table -Property groupid,displayname,description -AutoSize | Out-File -FilePath D:\Tests\powercsv\UThMsTeams.txt



# Define your variables
$teamName = "Δοκιμαστική ΔΙΚΑΙΟ 2024"
$accessToken = "Your Access Token"
$tenantId = "Your Tenant ID"

# Make the request to Microsoft Graph API
$uri = "https://graph.microsoft.com/v1.0/groups?\$filter=resourceProvisioningOptions/Any(x:x eq 'Team') and displayName eq '$teamName'"
$headers = @{
    "Authorization" = "Bearer $accessToken"
}
$response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

# Extract the Group ID
if ($response.value) {
    $groupId = $response.value.id
    Write-Host "Group ID of Team '$teamName' is: $groupId"
} else {
    Write-Host "Team '$teamName' not found."
}
