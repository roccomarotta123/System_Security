#!/bin/bash

# ECDSA: Firma e verifica con Curve Ellittiche
# Nota: ECDSA offre sicurezza simile a RSA con chiavi molto più piccole e veloci.

# 1. Genera la chiave privata ECDSA (Curva P-256 / prime256v1)
echo "Generazione chiave privata ECDSA (P-256)..."
openssl genpkey -algorithm EC -out ecdsa_private.pem -pkeyopt ec_paramgen_curve:P-256

# 2. Estrae la chiave pubblica ECDSA
echo "Estrazione chiave pubblica ECDSA..."
openssl pkey -in ecdsa_private.pem -pubout -out ecdsa_public.pem

# 3. Firma digitale del file (SHA256)
echo "Firmando con ECDSA-SHA256..."
openssl dgst -sha256 -sign ecdsa_private.pem -out messaggio_ecdsa.sig ../messaggio.txt

# 4. Verifica della firma
echo "Verificando firma ECDSA-SHA256..."
openssl dgst -sha256 -verify ecdsa_public.pem -signature messaggio_ecdsa.sig ../messaggio.txt

# 5. Genera un certificato X509 (v1) autofirmato
echo "Generazione certificato ECDSA X509 v1..."
openssl req -new -x509 -key ecdsa_private.pem -out ecdsa_cert_v1.crt -days 365 -subj "/CN=Test ECDSA v1"

# 6. Genera un certificato X509v3 autofirmato
echo "Generazione certificato ECDSA X509 v3..."
openssl req -new -x509 -key ecdsa_private.pem -out ecdsa_cert_v3.crt -days 365 -config ../openssl_v3.cnf

# Verifica dei certificati
echo "Verifica versione certificato v1:"
openssl x509 -in ecdsa_cert_v1.crt -text -noout | grep "Version"
echo "Verifica versione certificato v3:"
openssl x509 -in ecdsa_cert_v3.crt -text -noout | grep "Version"
echo "Verifica estensioni v3:"
openssl x509 -in ecdsa_cert_v3.crt -text -noout | grep -A 1 "Subject Alternative Name"

# 7. Esportazione in formato PKCS#12 (.p12)
echo "Esportazione in PKCS#12..."
openssl pkcs12 -export -in ecdsa_cert_v3.crt -inkey ecdsa_private.pem -out ecdsa_keystore.p12 -name "ecdsa_key" -passout pass:password

# 8. Importazione in Java KeyStore (JKS) usando Keytool
echo "Importazione in Java KeyStore (JKS)..."
keytool.exe -importkeystore \
    -srckeystore ecdsa_keystore.p12 -srcstoretype PKCS12 -srcstorepass password \
    -destkeystore ecdsa_keystore.jks -deststorepass password -noprompt

# Verifica del contenuto del KeyStore
echo "Contenuto del KeyStore JKS:"
keytool.exe -list -keystore ecdsa_keystore.jks -storepass password
