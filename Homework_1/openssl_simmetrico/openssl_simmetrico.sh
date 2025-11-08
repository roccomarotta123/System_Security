#!/bin/bash
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

		# Usa sempre messaggio.txt come file di input
		if [[ ! -f "messaggio.txt" ]]; then
			echo "File messaggio.txt di default non trovato. Creane uno nella cartella principale."
			exit 1
		fi

		# Scegli il binario openssl in base all'algoritmo
		if [[ "$ALGO" == des-cbc || "$ALGO" == des-ede3-cbc || "$ALGO" == bf-cbc ]]; then
			OPENSSL_BIN="/opt/local/bin/openssl-1.1"
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
	# ...existing code...
		$OPENSSL_BIN rand -hex 8 > "$DIR/iv.bin"
				IV_ARG=( -iv "$(cat "$DIR/iv.bin")" )
				echo "Chiave e IV generati in $DIR."
			elif [[ "$ALGO" == *cbc ]]; then
	# ...existing code...
		$OPENSSL_BIN rand -hex 16 > "$DIR/iv.bin"
				IV_ARG=( -iv "$(cat "$DIR/iv.bin")" )
				echo "Chiave e IV generati in $DIR."
			else
				IV_ARG=()
				echo "Chiave generata in $DIR. (IV non richiesto per ECB)"
			fi

		echo "Cifro messaggio.txt in $DIR/messaggio.enc..."
	# ...existing code...
		$OPENSSL_BIN enc -"$ALGO" -in "messaggio.txt" -out "$DIR/messaggio.enc" -K "$(cat "$DIR/key.bin")" "${IV_ARG[@]}"
		echo "File cifrato: $DIR/messaggio.enc"

		echo "Decifro $DIR/messaggio.enc in $DIR/messaggio_decrypted.txt..."
	# ...existing code...
		$OPENSSL_BIN enc -d -"$ALGO" -in "$DIR/messaggio.enc" -out "$DIR/messaggio_decrypted.txt" -K "$(cat "$DIR/key.bin")" "${IV_ARG[@]}"
		echo "File decifrato: $DIR/messaggio_decrypted.txt"
		echo "---------------------------------------------"
	done
}

# Esegui per ogni famiglia
process_family "aes" "${AES_ALGOS[@]}"
process_family "des" "${DES_ALGOS[@]}"
process_family "camellia" "${CAMELLIA_ALGOS[@]}"
process_family "blowfish" "${BLOWFISH_ALGOS[@]}"
