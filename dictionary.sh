#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "\033[1;31mError\033[0m: No arguments provided."
    echo -e "\033[1;31mUsage\033[0m: $0 \033[1m<word>\033[0m"
    exit 1
fi

if [ ! "$(command -v jq)" ]; then
    echo -e "\033[1;31mError\033[0m: jq is not installed."
    exit 1
fi

response=$(curl -s -w "%{http_code}" "https://api.dictionaryapi.dev/api/v2/entries/en/$1")
status_code="${response: -3}"
body="${response:: -3}"

if [ "$status_code" -ne 200 ]; then
    echo -e "\033[1;31mError\033[0m: We couldn't find definitions for the word."
    exit 1
fi

meanings=$(echo "$body" | jq -r '.[0].meanings // []')

len=$(echo "$meanings" | jq length)

if [ "$len" -eq 0 ]; then
    echo -e "\033[1;31mError\033[0m: No meanings found for the word."
    exit 1
fi

for ((i=0; i<len; i++)); do
    meaning=$(echo "$meanings" | jq ".[$i]")

    _jq() {
        echo "$meaning" | jq -r "$1"
    }

    partOfSpeech=$(_jq '.partOfSpeech')
    definition=$(_jq '.definitions[0].definition // "No definition available."')

    echo -e "\033[1;31mPart of Speech\033[0m: ${partOfSpeech^}"
    echo -e "\033[1;31mDefinition\033[0m: $definition"

    if ((i < len - 1)); then
        echo
    fi
done
