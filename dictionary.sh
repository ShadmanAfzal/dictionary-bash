#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "\033[1;31mError\033[0m: No arguments provided."
    echo -e "\033[1;31mUsage\033[0m: $0 \033[1m<arg1>\033[0m"
    exit 1
fi

if [ ! "$(command -v jq)" ]; then
  echo -e "\033[1;31mError\033[0m: jq is not installed."
  exit 1
fi

response=`curl -s https://api.dictionaryapi.dev/api/v2/entries/en/$1`

meanings=$(echo "$response" | jq -r '.[0].meanings')

len=$(echo "$meanings" | jq length)

for ((i=0; i<len; i++)); do 

    meaning=$(echo "$meanings" | jq ".[$i]")

    _jq() {
        echo "$meaning" | jq -r ${1}
    }

    partOfSpeech=$(_jq '.partOfSpeech')
    definition=$(_jq '.definitions[0].definition')
    
    echo -e "\033[1;31mPart of Speech\033[0m: ${partOfSpeech^}"
    echo -e "\033[1;31mmDefinition\033[0m: $definition"

    if ((i < len - 1)); then
        echo
    fi
done
