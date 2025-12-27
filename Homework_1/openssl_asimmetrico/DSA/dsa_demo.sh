#!/bin/bash

# DSA: Firma e verifica
# Nota: DSA può essere usato SOLO per la firma, non per la cifratura.

# Configurazione per OpenSSL legacy (se necessario per DSA in OpenSSL 3.0+)
LEGACY_PATH="../../openssl_simmetrico/legacy_openssl/install"
LEGACY_BIN="$LEGACY_PATH/bin/openssl"
LEGACY_LIB="$LEGACY_PATH/lib"
export LD_LIBRARY_PATH="$LEGACY_LIB:$LD_LIBRARY_PATH"

# 1. Genera i parametri DSA (2048 bit)
echo "Generazione parametri DSA..."
openssl dsaparam -out dsa_params.pem 2048

# 2. Genera la chiave privata DSA dai parametri
echo "Generazione chiave privata DSA..."
openssl genpkey -paramfile dsa_params.pem -out dsa_private.pem

# 3. Estrae la chiave pubblica DSA
echo "Estrazione chiave pubblica DSA..."
openssl dsa -in dsa_private.pem -pubout -out dsa_public.pem

# 4. Firma digitale del file (SHA256)
echo "Firmando con DSA-SHA256..."
openssl dgst -sha256 -sign dsa_private.pem -out messaggio_dsa.sig ../messaggio.txt

# 5. Verifica della firma
echo "Verificando firma DSA-SHA256..."
openssl dgst -sha256 -verify dsa_public.pem -signature messaggio_dsa.sig ../messaggio.txt

# 6. Genera un certificato X509 (v1) autofirmato
echo "Generazione certificato DSA X509 v1..."
openssl req -new -x509 -key dsa_private.pem -out dsa_cert_v1.crt -days 365 -subj "/CN=Test DSA v1"

# 7. Genera un certificato X509v3 autofirmato
echo "Generazione certificato DSA X509 v3..."
openssl req -new -x509 -key dsa_private.pem -out dsa_cert_v3.crt -days 365 -config ../openssl_v3.cnf

# Verifica dei certificati
echo "Verifica versione certificato v1:"
openssl x509 -in dsa_cert_v1.crt -text -noout | grep "Version"
echo "Verifica versione certificato v3:"
openssl x509 -in dsa_cert_v3.crt -text -noout | grep "Version"
echo "Verifica estensioni v3:"
openssl x509 -in dsa_cert_v3.crt -text -noout | grep -A 1 "Subject Alternative Name"

# 8. Esportazione in formato PKCS#12 (.p12)
echo "Esportazione in PKCS#12..."
openssl pkcs12 -export -in dsa_cert_v3.crt -inkey dsa_private.pem -out dsa_keystore.p12 -name "dsa_key" -passout pass:password

# 9. Importazione in Java KeyStore (JKS) usando Keytool
echo "Importazione in Java KeyStore (JKS)..."
keytool.exe -importkeystore \
    -srckeystore dsa_keystore.p12 -srcstoretype PKCS12 -srcstorepass password \
    -destkeystore dsa_keystore.jks -deststorepass password -noprompt

# Verifica del contenuto del KeyStore
echo "Contenuto del KeyStore JKS:"
keytool.exe -list -keystore dsa_keystore.jks -storepass password
