#!/bin/bash

CLASS_NAME=$1

if [ -z "$CLASS_NAME" ]; then
    echo "Usage: ./run.sh [ClassName]"
    echo "Example: ./run.sh SymmetricExample"
    exit 1
fi

# Esegui la classe
# Nota: Su Linux il separatore del classpath è ':' invece di ';'
java -cp "lib/*:out" "$CLASS_NAME"
