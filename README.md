# System_Security

## Compilazione OpenSSL 1.1 legacy su Linux/WSL

1. Vai nella cartella:
   ```bash
   cd Homework_1/openssl_simmetrico/legacy_openssl
   ```
2. Scarica i sorgenti:
   ```bash
   wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
   tar -xzf openssl-1.1.1w.tar.gz
   cd openssl-1.1.1w
   ```
3. Compila e installa localmente:
   ```bash
   ./config --prefix=$(pwd)/../install --openssldir=$(pwd)/../install/ssl
   make
   make install
   ```

## Compilazione OpenSSL 1.1 legacy su macOS

1. Installa Xcode Command Line Tools (se non già installati):
   ```bash
   xcode-select --install
   ```
2. Vai nella cartella:
   ```bash
   cd Homework_1/openssl_simmetrico/legacy_openssl
   ```
3. Scarica i sorgenti:
   ```bash
   curl -O https://www.openssl.org/source/openssl-1.1.1w.tar.gz
   tar -xzf openssl-1.1.1w.tar.gz
   cd openssl-1.1.1w
   ```
4. Compila e installa localmente:
   ```bash
   ./Configure darwin64-x86_64-cc --prefix=$(pwd)/../install --openssldir=$(pwd)/../install/ssl
   make
   make install
   ```

## Note per utenti Windows

Su Windows, per eseguire questo progetto è necessario installare WSL (Windows Subsystem for Linux) oppure un ambiente simile che supporti Bash (ad esempio Git Bash o Cygwin). Dopo aver installato WSL, segui la procedura indicata per i sistemi Linux per compilare OpenSSL 1.1 legacy all'interno del repository.

OpenSSL 1.1 non è disponibile tramite i normali gestori di pacchetti Windows o Linux moderni, quindi la compilazione locale è obbligatoria per garantire compatibilità e portabilità.

Dopo la compilazione, lo script userà automaticamente la versione locale di OpenSSL legacy.
