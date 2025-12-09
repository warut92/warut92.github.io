#!/usr/bin/env bash

DIR="./data"

# Base name: YYMMDD
BASE="$(date +%y%m%d)"
FILENAME="$DIR/${BASE}.md"

# If filename exists, add numbers: YYMMDD-1.md, YYMMDD-2.md, ...
if [ -e "$FILENAME" ]; then
    n=1
    while [ -e "${BASE}-$n.md" ]; do
        n=$((n+1))
    done
    FILENAME="$DIR/${BASE}-$n.md"
fi

# Create file and write filename inside
{
    echo "ชื่อเรื่อง"
    echo "DATE: $(date '+%Y-%m-%d %H:%M')"
    echo 
    echo "ข้อความ"
    echo "[เขียนไปเรื่อย]"
} > "$FILENAME"

echo "สร้างไฟล์แล้ว: $FILENAME"
