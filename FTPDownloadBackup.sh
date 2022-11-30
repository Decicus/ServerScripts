#!/bin/bash

usage()
{
cat << EOF
usage: $0

Connects to an FTP server directory using lftp and runs the \`mirror\` command to download all files and directories to a local directory.
Automatically appends current datetime as a suffix to the local directory name.

Requirements:
    - Install \`lftp\`
    - Add credentials to \`.netrc\` - Example: machine ftp.example.com login USERNAME password FTP_PASSWORD_HERE

OPTIONS:
    -h        Show this message
    -u        FTP URI - URI looks something like: ftp://USERNAME@ftp.example.com/your_backups_path
    -p        LOCAL path to copy the backups to.
EOF
}

# Variables
# URI looks something like: ftp://USERNAME@ftp.example.com/your_backups_path
URI="";
LOCAL_PATH="";
CURRENT_DATETIME="`date +%Y%m%d_%H%M%S`";

while getopts "hu:p:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        u)
            URI="${OPTARG}";
            ;;
        p)
            LOCAL_PATH="${OPTARG}";
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1));

if ! [ -x "$(command -v lftp)" ]; then
    echo "Error: lftp is not installed." >&2
    exit 1
fi

if [[ -z "$URI" ]]; then
    echo "URI is required (-u)";
    exit 1;
fi

if [[ -z "${LOCAL_PATH}" ]]; then
    echo "Local path not specified (-p)";
    exit 1;
fi

LOCAL_PATH="$(realpath "${LOCAL_PATH}")/${CURRENT_DATETIME}";
if [[ ! -d "${LOCAL_PATH}" ]]; then
    mkdir -p "${LOCAL_PATH}";
fi

echo "Downloading to ${LOCAL_PATH}";
lftp -e "mirror . ${LOCAL_PATH}; exit" "${URI}";