#!/usr/bin/env bash
set -euo pipefail
if [[ -f '/etc/os-release' ]]; then
    source '/etc/os-release'
fi
case ${ID:?} in
    debian | ubuntu) sudo bash -c '
        apt-get update; apt-get -y install lazarus
    ' >/dev/null ;;
esac
declare -ar OPS=(
    -Fuuse/mseide-msegui/lib/common/kernel/linux
    -Fuuse/mseide-msegui/lib/common/*
    -Mobjfpc -Sh -Fcutf8 -B -Xs -CX -XX -O2 -SIcorba -vewinhq
)
declare -i exitCode=0
mapfile -t < <(
    if (fpc "${OPS[@]}" "src/yearev.pas.pas"); then
        printf '\x1b[32mSUCCES\x1b[0m\n' >&2
        printf 'exitCode:0\n'
    else
        printf '\x1b[31mERROR\x1b[0m\n'  >&2
        printf 'exitCode:1\n'
    fi |
        grep --extended-regexp '(Error:|Fatal:|Linking|exitCode)'
)
if ((${#MAPFILE[@]})) && ((${MAPFILE[-1]##*:})); then
    exitCode+=${MAPFILE[-1]##*:}
fi
printf '%s\n' "${MAPFILE[@]}"
exit "${exitCode}"
