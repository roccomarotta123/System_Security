#!/bin/bash

# Crea la cartella out se non esiste
if [ ! -d "out" ]; then
    mkdir out
fi

# Compila i file
# Nota: Su Linux il separatore del classpath è ':' invece di ';'
javac -cp "lib/*" -d out src/*.java

if [ $? -ne 0 ]; then
    echo "[ERROR] Compilation failed."
    exit 1
fi

echo "[SUCCESS] Compilation complete."
