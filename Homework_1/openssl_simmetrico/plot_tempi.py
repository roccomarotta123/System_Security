import pandas as pd
import matplotlib.pyplot as plt

# Carica i dati dal file CSV
# Assicurati che il file sia nella stessa cartella dello script Python
csv_path = 'tempi_algoritmi.csv'
df = pd.read_csv(csv_path, names=['Algoritmo', 'Operazione', 'Tempo'])

# Grafico per la cifratura
df_cifratura = df[df['Operazione'] == 'cifratura']
plt.figure(figsize=(10,6))
plt.bar(df_cifratura['Algoritmo'], df_cifratura['Tempo'], color='steelblue')
plt.ylabel('Tempo di cifratura (ms)')
plt.title('Tempi di cifratura per algoritmo')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Grafico per la decifratura
df_decifratura = df[df['Operazione'] == 'decifratura']
plt.figure(figsize=(10,6))
plt.bar(df_decifratura['Algoritmo'], df_decifratura['Tempo'], color='orange')
plt.ylabel('Tempo di decifratura (ms)')
plt.title('Tempi di decifratura per algoritmo')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
