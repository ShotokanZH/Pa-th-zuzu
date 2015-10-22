# Pa(th)zuzu
Checks for PATH substitution vulnerabilities and logs the commands executed by the vulnerable executables

#How to make it work
- `chmod +x`
- `./pathzuzu.sh /path/to/command [args]`

Returns 0 if the executable is vulnerable, 1 otherwise.
