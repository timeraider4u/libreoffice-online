#!/bin/bash 

LOOLPATH=$(getent passwd lool | cut -d: -f6)
MYPATH="${LOOLPATH}/../"
SYSPATH="${MYPATH}/systemplate"
if [ ! -d "${SYSPATH}" ]; then
	echo "Directory '${SYSPATH}' does not exists" >&2
	exit 1
fi

MNT_POINT=$(stat -c "%m" "${MYPATH}")
findmnt "${MNT_POINT}" | tail --lines=1 | grep noexec 1> /dev/null
if [[ "${?}" == "0" ]]; then
	echo "'${MNT_POINT}' is mounted with noexec" \
		"which prevents libreoffice-online from working!" >&2
	exit 1
fi
