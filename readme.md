# Windows rules firewall cleaner

This script is provided as is, without any sort of warranty. You are fully responsible for what it may 
happen on your machine(s) if you run it. 

This script finds rules that point to executables or services that don't exist on the computer in the 
path the rule specifies. These rules are usually leftover rules from installations that are no longer
there (such as games or uninstalled applications). 

---

## Requirements
The script must be run under a windows local administrator account. 

## Usage
  ```
  pwsh
  git clone repo-url
  cd repo-name
  ```

  To show the rules that the script identifies as orphaned.
  ```
  .\fwcleanup.ps1 -report
  ```

  To disable orphaned rules
  ```
  .\fwcleanup.ps1 -report
  ```
  
  To delete orphaned rules
  ```
  .\fwcleanup.ps1 -delete
  ```
