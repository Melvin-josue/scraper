#!/usr/bin/env bash

web="animeuno"
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

# Palabras clave para encontrar líneas con iframes útiles
keywords=("iframe" "embed" "mega" "sendvid" "videas.fr" "hqq" "voe" "filemoon" "uqload")

for word in "${keywords[@]}"; do 
  grep -i "$word" "$html" >> "$output"
done

# Extraer src de iframe (https://...)
grep -oP '<iframe[^>]+src="\Khttps?://[^"]+' "$output" |
grep -E "mega|sendvid|videas\.fr|filemoon|voe|uqload|hqq" |
sort -u > "$final"

# Mostrar resultados
echo "🎯 Enlaces extraídos desde ${web}:"
cat "$final"

