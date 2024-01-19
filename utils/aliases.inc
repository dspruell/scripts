# Shell aliases and functions

alias prefix-hyphens='while read line; do echo "- $line"; done'
alias sort-ipv4='sort -n -t. -k1,1 -k2,2 -k3,3 -k4,4'
alias tolower="tr '[:upper:]' '[:lower:]'"
alias toupper="tr '[:lower:]' '[:upper:]'"

alias black="black -l 79"
alias capa-scan='capa -s "$CAPA_SIGS" -r "$CAPA_RULES"'
alias disview="/usr/bin/wine /opt/OfficeMalScanner/DisView.exe"
alias excel="open -a 'Microsoft Excel'"
alias gps="(set -x; git pull; git status)"
alias malhost-setup="/usr/bin/wine /opt/OfficeMalScanner/MalHost-Setup.exe"
alias officemalscanner="/usr/bin/wine /opt/OfficeMalScanner/OfficeMalScanner.exe"
alias pdns-format='awk '"'"'{print $1,$2,$3,$4,$5,$6}'"'"' | column -t'
alias rtfscan="/usr/bin/wine /opt/OfficeMalScanner/RTFScan.exe"
alias start-fakenet="sudo fakenet -c /etc/fakenet/default.ini -v"
alias tika-app="java -jar /opt/apache-tika/tika-app.jar"
