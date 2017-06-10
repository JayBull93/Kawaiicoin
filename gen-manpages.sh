#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

KawaiicoinD=${KawaiicoinD:-$SRCDIR/Kawaiicoind}
KawaiicoinCLI=${KawaiicoinCLI:-$SRCDIR/Kawaiicoin-cli}
KawaiicoinTX=${KawaiicoinTX:-$SRCDIR/Kawaiicoin-tx}
KawaiicoinQT=${KawaiicoinQT:-$SRCDIR/qt/Kawaiicoin-qt}

[ ! -x $KawaiicoinD ] && echo "$KawaiicoinD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
kwiVER=($($KawaiicoinCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for Kawaiicoind if --version-string is not set,
# but has different outcomes for Kawaiicoin-qt and Kawaiicoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$KawaiicoinD --version | sed -n '1!p' >> footer.h2m

for cmd in $KawaiicoinD $KawaiicoinCLI $KawaiicoinTX $KawaiicoinQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${kwiVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${kwiVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
