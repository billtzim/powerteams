#2) Για όσους επιθυμούν να κάνουν ενέργειες μέσω του Windows PowerShell, παραθέτω μερικές αρχικές πληροφορίες:
#- Θα χρειαστεί να εγκαταστήσετε το module: MicrosoftTeams (https://www.powershellgallery.com/packages/MicrosoftTeams/)
#- Κάνετε connect-MicrosoftTeams με τον λογαριασμό teleconf....@o365.uth.gr
#- Κατόπιν διαχειρίζεστε τις ομάδες Teams στις οποίες είστε Owner, με εντολές του module: https://docs.microsoft.com/en-us/powershell/module/teams/?view=teams-ps
#ΕΦΙΣΤΩ ΠΡΟΣΟΧΗ στη χρήση εντολών που δεν ξεκινούν από Get- (πχ. Add- Set- , Remove- κτλ) καθώς επεμβαίνουν σε ρυθμίσεις στα Teams.
#Οι εντολές Get- έχουν χαρακτήρα "Read-Only", πχ.:
#get-Team -User teleconf....@o365.uth.gr | Format-Table -Property DisplayName
#ή
#Get-Team | Group-Object description | Format-Table -Property groupid,displayname,description -AutoSize | Out-File -FilePath c:\UThMsTeams.txt

Connect-MicrosoftTeams

# Define the path to your CSV file
$csvFilePath = "D:\Repositories\powerteams\simple_courses_codes_econ.csv"
#$csvFilePath = "simple_courses_codes_econ.csv"

# Read the CSV file
$data = Import-Csv -Path $csvFilePath

# Define the command you want to execute
#$commandToExecute = "YourCommandHere"

# Define an array to store results
$results = @()

# Loop through each row in the CSV file
foreach ($row in $data) {
    $title = $row.Title
    $description = $row.Description
    $owner = $row.Owner

    # Construct the command with parameters
    #$fullCommand = "$commandToExecute -Title '$title' -Description '$description' -Owner '$owner'"
    $group = New-Team -DisplayName $title -Description $description -AllowGiphy $false -AllowDeleteChannels $false -AllowCreateUpdateRemoveTabs $false -AllowCreateUpdateRemoveConnectors $false -AllowCreateUpdateChannels $false -AllowAddRemoveApps $false
    Add-TeamUser -GroupId $group.GroupId -User "vtzimourtos@o365.uth.gr" -Role Owner

    # Execute the command
    #Write-Host "Executing command: $fullCommand"

    # Create an object with title and output
    $resultObject = [PSCustomObject]@{
        Title = $title
        Description = $description
        GroupID = $group.GroupId
    }

    # Add the result object to the results array
    $results += $resultObject

    # Invoke-Expression $fullCommand  # Uncomment this line to actually execute the command
}

# Define the path to save the results CSV file
$resultsFilePath = "D:\Repositories\powerteams\SAVED_RESULTS_simple_courses_codes_econ.csv"
#$resultsFilePath = "SAVED_RESULTS_simple_courses_codes_econ.csv"

# Export results to a CSV file
$results | Export-Csv -Path $resultsFilePath -NoTypeInformation
