#!/usr/bin/env bash
set -e
set -u
set -o pipefail

PROGRAM=${0##*/}

function display_help {
    cat <<-EOH
	usage: $PROGRAM [OPTIONS] <calendar.ics>

	Extract events from iCalendar file as TSV (Summary, Start, End)

	OPTIONS:
	    -h, --help    Show this help
EOH
}

function err_exit {
    echo "$1" >&2
    display_help
    exit "${2:-1}"
}

function extract_events {
    awk -v prefix="$1" '
    BEGIN {
        RS = "BEGIN:VEVENT"
        FS = "\n"
        OFS = "\t"
    }
    function extract(line) {
        sub(/^[^:]*:/, "", line)
        gsub(/\r/, "", line)
        return line
    }
    function format_date(val) {
        val = substr(val, 1, 8)
        return substr(val, 1, 4) "-" substr(val, 5, 2) "-" substr(val, 7, 2)
    }
    NR > 1 {
        summary = ""
        dtstart = ""
        dtend = ""

        for (i = 1; i <= NF; i++) {
            if ($i ~ /^SUMMARY/)  summary = extract($i)
            if ($i ~ /^DTSTART/)  dtstart = format_date(extract($i))
            if ($i ~ /^DTEND/)    dtend = format_date(extract($i))
        }

        if (dtend == dtstart) dtend = ""

        print prefix, summary, dtstart, dtend
    }
    '
}

PREFIX=""
# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) 
            display_help; exit 0 
            ;;
        -p|--prefix) 
            [[ -z "$2" || "$2" == -* ]] && err_exit "Option $1 requires an argument"
            PREFIX="$2"
            shift 2
            ;;
        -*) 
            err_exit "Unknown option: $1" 
            ;;
        *) break ;;
    esac
done

[[ $# -lt 1 ]] && err_exit "Missing input file"
[[ -f "$1" ]] || err_exit "File not found: $1"

if head -1 "$1" | grep -q $'\r'; then 
    tr -d '\r' < "$1" | extract_events "$PREFIX"
else 
    extract_events "$PREFIX" < "$1"
fi | sort -t$'\t' -k2
