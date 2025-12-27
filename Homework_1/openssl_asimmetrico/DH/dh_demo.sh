#!/bin/bash

# Diffie-Hellman (DH) Classico + AES: cifratura e decifratura

echo "1. Generazione parametri DH (potrebbe richiedere del tempo)..."
# Generiamo i parametri DH (es. 2048 bit)
openssl genpkey -genparam -algorithm DH -out dhp.pem -pkeyopt dh_paramgen_prime_len:2048

echo "2. Generazione chiavi per A e B..."
# Genera chiave privata A
openssl genpkey -paramfile dhp.pem -out dh_priv_A.pem
# Estrae pubblica A
openssl pkey -in dh_priv_A.pem -pubout -out dh_pub_A.pem

# Genera chiave privata B
openssl genpkey -paramfile dhp.pem -out dh_priv_B.pem
# Estrae pubblica B
openssl pkey -in dh_priv_B.pem -pubout -out dh_pub_B.pem

echo "3. Derivazione chiave condivisa..."
# A calcola il segreto usando la sua privata e la pubblica di B
openssl pkeyutl -derive -inkey dh_priv_A.pem -peerkey dh_pub_B.pem -out dh_shared_A.bin
# B calcola il segreto usando la sua privata e la pubblica di A
openssl pkeyutl -derive -inkey dh_priv_B.pem -peerkey dh_pub_A.pem -out dh_shared_B.bin

# Usiamo la chiave derivata come password per la cifratura
openssl enc -aes-256-cbc -in ../messaggio.txt -out messaggio_dh.enc -pass file:dh_shared_A.bin

echo "5. Decifratura con AES-256-CBC usando la chiave condivisa (lato B)..."
openssl enc -d -aes-256-cbc -in messaggio_dh.enc -out messaggio_dh_decrypted.txt -pass file:dh_shared_B.bin

echo "6. Risultato decifrato:"
cat messaggio_dh_decrypted.txt
