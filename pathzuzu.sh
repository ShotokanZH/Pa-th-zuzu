#!/usr/bin/env bash
#+-----------+
#|PA(TH)ZUZU!|
#+-v1.0------+------+
#|Brought to you by:|
#| Shotokan@aitch.me|
#+-PGP-AHEAD--------+----------+
#|https://keybase.io/ShotokanZH|
#+-$BEGIN----------------------+

tor="$(which "$1")";
log="$(basename "$0").log"

if [ "$tor" = "" ];
then
	echo "Usage: $0 /path/to/command [args]"
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
		echo "\tNOPE ($p)";
	fi;
	IFS=':';
done;
IFS=$OIFS;

shift;

echo "Running: $tor $@";
echo "";

PATH="$tmpd" "$tor" $@;

rm -rf "$tmpd";
rm -rf "$tmpf";
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
