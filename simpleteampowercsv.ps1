Connect-MicrosoftTeams

# Define the path to your CSV file
$csvFilePath = "d:\tests\powercsv\simple_courses_codes_econ.csv"

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
$resultsFilePath = "d:\tests\powercsv\SAVED_RESULTS_simple_courses_codes_econ.csv"

# Export results to a CSV file
$results | Export-Csv -Path $resultsFilePath -NoTypeInformation