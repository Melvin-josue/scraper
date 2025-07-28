#!/usr/bin/env bash

web="animekb.net"
url="$1"
anime="$2"
html="${web}.html"
output="${web}.txt"
final="url.${web}.${anime}.txt"

# Limpiar archivos
> "$html"
> "$output"
> "$final"

# Descargar HTML
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

# Palabras clave solo para enlaces de descarga
keywords=("fireload" "mediafire" "megaup" "zippyshare" "1fichier" "fileblade" "terabox" "worlduploads" "yourupload" "burstcloud")

# Filtrar líneas con posibles enlaces de descarga
for word in "${keywords[@]}"; do 
  grep -i "$word" "$html" >> "$output"
done

# Extraer href directos
grep -oP 'href="https?://[^"]+"' "$output" |
cut -d'"' -f2 |
sort -u > "$final"

# Mostrar resultados
echo "✅ Enlaces de descarga desde ${web}:"
cat "$final"

