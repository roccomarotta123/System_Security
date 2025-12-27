#!/bin/bash
# Imposta la variabile LD_LIBRARY_PATH per le librerie OpenSSL legacy
export LD_LIBRARY_PATH="$(dirname "$0")/legacy_openssl/install/lib"
# Script per generare chiave e IV, cifrare e decifrare un file con algoritmo selezionabile


AES_ALGOS=(
	"aes-128-cbc"
	"aes-192-cbc"
	"aes-256-cbc"
	"aes-128-ecb"
	"aes-256-ecb"
)
DES_ALGOS=(
	"des-cbc"
	"des-ede3-cbc"
)
CAMELLIA_ALGOS=(
	"camellia-128-cbc"
	"camellia-256-cbc"
)
BLOWFISH_ALGOS=(
	"bf-cbc"
)

# Funzione per processare una famiglia
process_family() {
	FAMILY_NAME="$1"
	shift
	ALGO_LIST=("$@")
	mkdir -p "$FAMILY_NAME"
	for ALGO in "${ALGO_LIST[@]}"; do
		DIR="$FAMILY_NAME/$ALGO"
		mkdir -p "$DIR"

		# Usa sempre body.bin e header.bin come input
		if [[ ! -f "body.bin" || ! -f "header.bin" ]]; then
			echo "File body.bin o header.bin non trovati. Assicurati che siano nella cartella principale."
			exit 1
		fi

		# Scegli il binario openssl in base all'algoritmo
		if [[ "$ALGO" == des-cbc || "$ALGO" == des-ede3-cbc || "$ALGO" == bf-cbc ]]; then
			OPENSSL_BIN="$(dirname "$0")/legacy_openssl/install/bin/openssl"
		else
			OPENSSL_BIN="openssl"
		fi

		# Genera chiave e IV in base all'algoritmo
			case "$ALGO" in
				aes-128-cbc|aes-128-ecb|camellia-128-cbc)
				# ...existing code...
				$OPENSSL_BIN rand -hex 16 > "$DIR/key.bin"
					;;
				aes-192-cbc)
				# ...existing code...
				$OPENSSL_BIN rand -hex 24 > "$DIR/key.bin"
					;;
				aes-256-cbc|aes-256-ecb|camellia-256-cbc)
				# ...existing code...
				$OPENSSL_BIN rand -hex 32 > "$DIR/key.bin"
					;;
				des-cbc)
				# ...existing code...
				$OPENSSL_BIN rand -hex 8 > "$DIR/key.bin"
					;;
				des-ede3-cbc)
				# ...existing code...
				$OPENSSL_BIN rand -hex 24 > "$DIR/key.bin"
					;;
				bf-cbc)
				# ...existing code...
				$OPENSSL_BIN rand -hex 16 > "$DIR/key.bin"
					;;
				*)
					echo "Algoritmo $ALGO non gestito."
					continue
					;;
			esac

			# IV richiesto solo per CBC (non per ECB)
			if [[ "$ALGO" == des-cbc || "$ALGO" == des-ede3-cbc || "$ALGO" == bf-cbc ]]; then
				$OPENSSL_BIN rand -hex 8 > "$DIR/iv.bin"
				IV_ARG=( -iv "$(cat "$DIR/iv.bin")" )
				echo "Chiave e IV generati in $DIR."
			elif [[ "$ALGO" == *cbc ]]; then
				$OPENSSL_BIN rand -hex 16 > "$DIR/iv.bin"
				IV_ARG=( -iv "$(cat "$DIR/iv.bin")" )
				echo "Chiave e IV generati in $DIR."
			else
				IV_ARG=()
				echo "Chiave generata in $DIR. (IV non richiesto per ECB)"
			fi

		echo "Cifro body.bin in $DIR/body.enc..."
		$OPENSSL_BIN enc -"$ALGO" -in "body.bin" -out "$DIR/body.enc" -K "$(cat "$DIR/key.bin")" "${IV_ARG[@]}"
		echo "File cifrato: $DIR/body.enc"

		# Unisco header e body cifrato per creare l'immagine
		cat header.bin "$DIR/body.enc" > "$DIR/tux_encrypted.bmp"
		echo "Immagine cifrata creata: $DIR/tux_encrypted.bmp"

		echo "Decifro $DIR/body.enc in $DIR/body_decrypted.bin..."
		$OPENSSL_BIN enc -d -"$ALGO" -in "$DIR/body.enc" -out "$DIR/body_decrypted.bin" -K "$(cat "$DIR/key.bin")" "${IV_ARG[@]}"
		echo "File decifrato: $DIR/body_decrypted.bin"
		echo "---------------------------------------------"
	done
}

# Esegui per ogni famiglia
process_family "aes" "${AES_ALGOS[@]}"
process_family "des" "${DES_ALGOS[@]}"
process_family "camellia" "${CAMELLIA_ALGOS[@]}"
process_family "blowfish" "${BLOWFISH_ALGOS[@]}"
