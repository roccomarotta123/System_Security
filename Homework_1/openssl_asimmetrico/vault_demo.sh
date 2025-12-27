#!/bin/bash

# Vault Demo: Gestione Segreti
# Questo script mostra come usare Vault per salvare e recuperare segreti.
# Nota: Presuppone che 'vault.exe' sia installato e accessibile nel PATH.

# 1. Avvia Vault in modalità DEV (in background)
echo "Avvio di Vault in modalità DEV..."
# La modalità -dev avvia un server in memoria, non sicuro per produzione ma ottimo per test.
# Impostiamo il token di root a "root" per semplicità.
vault.exe server -dev -dev-root-token-id="root" > vault.log 2>&1 &
VAULT_PID=$!
echo "Vault avviato con PID $VAULT_PID. Log in vault.log"

# Attende qualche secondo che il server sia pronto
sleep 3

# 2. Configura l'ambiente per il client
export VAULT_ADDR='http://127.0.0.1:8200'
# Non usiamo export VAULT_TOKEN perché Windows non lo eredita facilmente.
# Usiamo 'vault login' per salvare il token.

# 3. Verifica lo stato
echo "Verifica stato Vault:"
vault.exe status -address=$VAULT_ADDR

# 4. Login (necessario perché la variabile d'ambiente non passa a Windows)
echo "Eseguo login..."
vault.exe login -address=$VAULT_ADDR -no-print root

# 5. Abilita il motore di segreti KV (Key-Value) versione 2
echo "Abilitazione motore KV v2..."
# Vault dev mode ha già secret/ abilitato, quindi questo comando potrebbe fallire.
# Usiamo '|| true' per ignorare l'errore se esiste già.
vault.exe secrets enable -address=$VAULT_ADDR -path=secret kv-v2 2>/dev/null || echo "Motore KV già abilitato o errore ignorabile."

# 6. Scrittura di un segreto (es. una chiave privata fittizia)
echo "Scrittura di un segreto in secret/data/myapp..."
# Leggiamo il contenuto della chiave direttamente in una variabile
PRIVATE_KEY_CONTENT=$(<RSA/rsa_private.pem)
vault.exe kv put -address=$VAULT_ADDR secret/myapp api_key="12345-ABCDE" private_key="$PRIVATE_KEY_CONTENT"

# 7. Lettura del segreto
echo "Lettura del segreto da secret/data/myapp..."
vault.exe kv get -address=$VAULT_ADDR secret/myapp

# 8. Lettura di un campo specifico (es. solo la chiave privata)
echo "Estrazione della chiave privata dal Vault..."
vault.exe kv get -address=$VAULT_ADDR -field=private_key secret/myapp > retrieved_key.pem
echo "Chiave recuperata in retrieved_key.pem"

# 9. Pulizia (Ferma il server Vault)
echo "Arresto di Vault..."
kill $VAULT_PID
