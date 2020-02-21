$credential = (Get-Credential)
Connect-PowerBIServiceAccount -Credential $credential

$workspaces = "Test",
"Test 2"

$users = 
"test@test.com",
"test2@test.com"


$ids = Foreach($name in $workspaces) {Get-PowerBIWorkspace -Scope Organization -Filter "name eq '$name'" }

Foreach ($user in $users) {
Foreach($id in $ids) {
Add-PowerBIWorkspaceUser -Scope Organization -Id $id.id -UserEmailAddress $user -AccessRight Admin
}}
