#!/bin/sh
#
# https://gist.github.com/joeybaumgartner/f3675fc2861ca3e47c8ccc29bdfc306e

if [ $# -lt 1 ]
then
  echo “man2pdf [man page name]”
  exit
fi

tempfoo=`basename $0`
TMPPDFFILE=`mktemp /tmp/${tempfoo}.XXXXXX` || exit 1

man -t $* | pstopdf -o $TMPPDFFILE

export psStatus=$?
if [ $psStatus -ne 0 ]; then
	echo "Could not output contents of man page to temp file"
	exit 1
fi

open -a Preview.app $TMPPDFFILE
