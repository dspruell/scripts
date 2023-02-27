# Shell aliases and functions

alias sort-ipv4='sort -n -t. -k1,1 -k2,2 -k3,3 -k4,4'
alias tolower="tr '[:upper:]' '[:lower:]'"
alias toupper="tr '[:lower:]' '[:upper:]'"

alias officemalscanner="/usr/bin/wine /opt/OfficeMalScanner/OfficeMalScanner.exe"
alias rtfscan="/usr/bin/wine /opt/OfficeMalScanner/RTFScan.exe"
alias malhost-setup="/usr/bin/wine /opt/OfficeMalScanner/MalHost-Setup.exe"
alias disview="/usr/bin/wine /opt/OfficeMalScanner/DisView.exe"
alias start-fakenet="sudo fakenet -c /etc/fakenet/default.ini -v"

alias black="black -l 79"
