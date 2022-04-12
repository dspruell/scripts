# Local clamdscan instance
ClamAV's clamd(8) is typically run as a system-wide daemon by the superuser.
But this is often not optimal for a single-user analysis system, where files
that need scanned reside inside a user home directory. So a local per-user
instance can be nice.

## Setup
The file `clamd.conf.local` is a minimal Clamd configuration file sufficient
for running a local instance. It should be placed at a suitable path (I use
`~/analysis`).

The file `clamd-local.sh` is a script to execute a local clamd(8) instance
based on the path the configuration is stored.

A local clamd command can be set up as a shell alias. The following alias
should be added to the shell's environment file. For ksh: the file indicated
at `$ENV` (typically `~/.kshrc`):

```
# Calls clamdscan(1) with a connection to a local clamd instance.
alias clamdscan-local='clamdscan --config-file=~/analysis/clamd.conf.local --verbose --no-summary'
```
