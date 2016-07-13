param(
[ValidateSet('interactive', 'detached', ignorecase=$true)]
[string]$attachmode="interactive"
)

#start saratiba
get-service Saratiba | start-service

# take interactive / detached action as appropriate
if ($attachmode -eq "interactive") {
  powershell
} else {
 # sleep-loop indefinitely (until container stop)
 while (1 -eq 1) {   
   Start-Sleep -Seconds 1
  }
}