#!/bin/bash

# RSA: cifratura, decifratura, firma e verifica

# 1. Genera una coppia di chiavi RSA
openssl genpkey -algorithm RSA -out rsa_private.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in rsa_private.pem -out rsa_public.pem

# 2. Cifra un file con la chiave pubblica
openssl rsautl -encrypt -inkey rsa_public.pem -pubin -in ../messaggio.txt -out messaggio_rsa.enc

# 3. Decifra il file con la chiave privata
openssl rsautl -decrypt -inkey rsa_private.pem -in messaggio_rsa.enc -out messaggio_rsa_decrypted.txt

# 4. Firma digitale del file (SHA256)
echo "Firmando con SHA256..."
openssl dgst -sha256 -sign rsa_private.pem -out messaggio_rsa_sha256.sig ../messaggio.txt

# 5. Verifica della firma (SHA256)
echo "Verificando firma SHA256..."
openssl dgst -sha256 -verify rsa_public.pem -signature messaggio_rsa_sha256.sig ../messaggio.txt

# 6. Firma digitale del file (SHA512)
echo "Firmando con SHA512..."
openssl dgst -sha512 -sign rsa_private.pem -out messaggio_rsa_sha512.sig ../messaggio.txt

# 7. Verifica della firma (SHA512)
echo "Verificando firma SHA512..."
openssl dgst -sha512 -verify rsa_public.pem -signature messaggio_rsa_sha512.sig ../messaggio.txt

# 8. Firma digitale del file (SHA1)
echo "Firmando con SHA1..."
openssl dgst -sha1 -sign rsa_private.pem -out messaggio_rsa_sha1.sig ../messaggio.txt

# 9. Verifica della firma (SHA1)
echo "Verificando firma SHA1..."
openssl dgst -sha1 -verify rsa_public.pem -signature messaggio_rsa_sha1.sig ../messaggio.txt

# 10. Firma digitale del file (MD5)
echo "Firmando con MD5..."
openssl dgst -md5 -sign rsa_private.pem -out messaggio_rsa_md5.sig ../messaggio.txt

# 11. Verifica della firma (MD5)
echo "Verificando firma MD5..."
openssl dgst -md5 -verify rsa_public.pem -signature messaggio_rsa_md5.sig ../messaggio.txt

# 12. Firma digitale del file (RIPEMD160)
echo "Firmando con RIPEMD160..."
openssl dgst -ripemd160 -sign rsa_private.pem -out messaggio_rsa_ripemd160.sig ../messaggio.txt

# 13. Verifica della firma (RIPEMD160)
echo "Verificando firma RIPEMD160..."
openssl dgst -ripemd160 -verify rsa_public.pem -signature messaggio_rsa_ripemd160.sig ../messaggio.txt

# 14. HMAC (Hash-based Message Authentication Code)
echo "Calcolando HMAC..."
openssl dgst -sha256 -hmac "secret_key" -out messaggio_hmac.sig ../messaggio.txt
echo "HMAC calcolato."

# --- Algoritmi Legacy (Richiedono Legacy OpenSSL via WSL) ---
# Configurazione per OpenSSL legacy
LEGACY_PATH="../../openssl_simmetrico/legacy_openssl/install"
LEGACY_BIN="$LEGACY_PATH/bin/openssl"
LEGACY_LIB="$LEGACY_PATH/lib"


# Esporta LD_LIBRARY_PATH per l'intera sessione o per i comandi specifici
export LD_LIBRARY_PATH="$LEGACY_LIB:$LD_LIBRARY_PATH"

# 15. Firma digitale del file (MD4 - Legacy)
echo "Firmando con MD4 (Legacy)..."
"$LEGACY_BIN" dgst -md4 -sign rsa_private.pem -out messaggio_rsa_md4.sig ../messaggio.txt

# 16. Verifica della firma (MD4 - Legacy)
echo "Verificando firma MD4 (Legacy)..."
"$LEGACY_BIN" dgst -md4 -verify rsa_public.pem -signature messaggio_rsa_md4.sig ../messaggio.txt

# 17. Firma digitale del file (MDC2 - Legacy)
echo "Firmando con MDC2 (Legacy)..."
"$LEGACY_BIN" dgst -mdc2 -sign rsa_private.pem -out messaggio_rsa_mdc2.sig ../messaggio.txt

# 18. Verifica della firma (MDC2 - Legacy)
echo "Verificando firma MDC2 (Legacy)..."
"$LEGACY_BIN" dgst -mdc2 -verify rsa_public.pem -signature messaggio_rsa_mdc2.sig ../messaggio.txt

# Nota: MD2 non è supportato nemmeno nella versione legacy 1.1.1w compilata.
# echo "Firmando con MD2 (Legacy)..."
# openssl dgst -provider legacy -provider default -md2 -sign rsa_private.pem -out messaggio_rsa_md2.sig ../messaggio.txt


# 19. Genera un certificato X509 (v1) autofirmato
echo "Generazione certificato X509 v1..."
openssl req -new -x509 -key rsa_private.pem -out rsa_cert_v1.crt -days 365 -subj "/CN=Test RSA v1"

# 20. Genera un certificato X509v3 autofirmato
echo "Generazione certificato X509 v3..."
# Nota: usiamo -config per specificare le estensioni v3
openssl req -new -x509 -key rsa_private.pem -out rsa_cert_v3.crt -days 365 -config ../openssl_v3.cnf

# Verifica dei certificati
echo "Verifica versione certificato v1:"
openssl x509 -in rsa_cert_v1.crt -text -noout | grep "Version"
echo "Verifica versione certificato v3:"
openssl x509 -in rsa_cert_v3.crt -text -noout | grep "Version"
echo "Verifica estensioni v3:"
openssl x509 -in rsa_cert_v3.crt -text -noout | grep -A 1 "Subject Alternative Name"

# 21. Esportazione in formato PKCS#12 (.p12)
# Il formato PKCS#12 è un contenitore sicuro per chiave privata e certificato.
echo "Esportazione in PKCS#12..."
openssl pkcs12 -export -in rsa_cert_v3.crt -inkey rsa_private.pem -out rsa_keystore.p12 -name "rsa_key" -passout pass:password

# 22. Importazione in Java KeyStore (JKS) usando Keytool
# Keytool è l'utility di Java per gestire i certificati. Importiamo il p12 nel formato nativo JKS.
echo "Importazione in Java KeyStore (JKS)..."
# Nota: usiamo keytool.exe perché siamo su Windows (chiamato da WSL)
keytool.exe -importkeystore \
    -srckeystore rsa_keystore.p12 -srcstoretype PKCS12 -srcstorepass password \
    -destkeystore rsa_keystore.jks -deststorepass password -noprompt

# Verifica del contenuto del KeyStore
echo "Contenuto del KeyStore JKS:"
keytool.exe -list -keystore rsa_keystore.jks -storepass password
