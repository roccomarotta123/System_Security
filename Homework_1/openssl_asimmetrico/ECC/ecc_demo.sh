#!/bin/bash

# ECC ECDH + AES: cifratura e decifratura

# 1. Genera chiavi ECC per A e B
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out ecc_priv_A.pem
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out ecc_priv_B.pem
openssl pkey -in ecc_priv_A.pem -pubout -out ecc_pub_A.pem
openssl pkey -in ecc_priv_B.pem -pubout -out ecc_pub_B.pem

# 2. Deriva la chiave condivisa (ECDH)
openssl pkeyutl -derive -inkey ecc_priv_A.pem -peerkey ecc_pub_B.pem -out shared_A.bin
openssl pkeyutl -derive -inkey ecc_priv_B.pem -peerkey ecc_pub_A.pem -out shared_B.bin

# 3. Usa il file di testo di esempio come input
# Assicurati che messaggio.txt sia presente nella cartella principale

# 4. Cifra con AES-256-CBC usando la chiave condivisa
openssl enc -aes-256-cbc -in ../messaggio.txt -out messaggio_ecc.enc -pass file:shared_A.bin

# 5. Decifra con AES-256-CBC usando la chiave condivisa
openssl enc -d -aes-256-cbc -in messaggio_ecc.enc -out messaggio_ecc_decrypted.txt -pass file:shared_B.bin

# 6. Mostra il risultato
cat messaggio_ecc_decrypted.txt
