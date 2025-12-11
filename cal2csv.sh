#!/usr/bin/env bash
set -e
set -u
set -o pipefail

PROGRAM=${0##*/}

function display_help {
    cat <<-EOH
    usage: $PROGRAM <calendar.ics>

    Extract events from iCalendar file as TSV (Date, Summary)

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
    awk '
    BEGIN {
        RS = "BEGIN:VEVENT"
        FS = "\n"
        OFS = "\t"
    }
    function extract(line) {
        sub(/^[^:]*:/, "", line)
        gsub(/\r/, "", line)
        # Escape existing tabs to avoid breaking TSV structure
        gsub(/\t/, " ", line)
        return line
    }
    function format_date(val) {
        # Check if we have at least 8 characters (YYYYMMDD)
        if (length(val) < 8) return val
        
        # Extract parts
        y = substr(val, 1, 4)
        m = substr(val, 5, 2)
        d = substr(val, 7, 2)
        
        # Return format dd.mm.YYYY
        # return d "." m "." y
        return y "-" m "-" d
    }
    NR > 1 {
        summary = ""
        dtstart = ""

        for (i = 1; i <= NF; i++) {
            if ($i ~ /^SUMMARY/)  summary = extract($i)
            if ($i ~ /^DTSTART/)  dtstart = format_date(extract($i))
        }

        # Only print if we found a summary and a date
        if (summary != "" && dtstart != "") {
            # Print Date first, then Summary
            print dtstart, summary
        }
    }
    '
}

# Check for help argument
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    display_help
    exit 0
fi

[[ $# -lt 1 ]] && err_exit "Missing input file"
[[ -f "$1" ]] || err_exit "File not found: $1"

# Handle potential CRLF line endings from curl
if head -1 "$1" | grep -q $'\r'; then 
    tr -d '\r' < "$1" | extract_events
else 
    extract_events < "$1"
fi | sort -t$'\t' -k1.7,1.10 -k1.4,1.5 -k1.1,1.2
# Note: The sort command above sorts by Year (chars 7-10), then Month (4-5), then Day (1-2)
