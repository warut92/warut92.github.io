#!/usr/bin/env bash

# ---- Functions ----

hello() {
    echo "Hello! This is function: hello"
}

goodbye() {
    echo "Goodbye! This is function: goodbye"
}

create_file() {
    echo "Create file function running..."
}

# ---- Main logic ----

case "$1" in
    hello)
        hello
        ;;
    goodbye)
        goodbye
        ;;
    create)
        create_file
        ;;
    *)
        echo "Usage: $0 {hello|goodbye|create}"
        exit 1
        ;;
esac
