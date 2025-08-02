#!/usr/bin/env bash

web="tioanime.com"
url="$1"
anime="$2"
html="${web}.html"
output="${web}.txt"
final="url.${web}.${anime}.txt"

> "$html"
> "$output"
> "$final"

# Descargar HTML
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

# Sitios de interés (puedes añadir más)
sites=("mega.nz" "mediafire.com" "voe.sx" "yourupload.com" "hqq.tv" "vgfplay.com")

# === Extraer href normales ===
grep -oP 'href="https?://[^"]+' "$html" |
cut -d'"' -f2 |
grep -Ei "$(IFS="|"; echo "${sites[*]}" | sed 's/\./\\./g')" >> "$final"

# === Extraer URLs desde `var videos = [...]` ===
# 1. Buscar la línea que contiene la variable
grep -oP 'var videos = \[\[.*?\]\];' "$html" |
# 2. Extraer solo las URLs escapadas entre comillas dobles
grep -oP '"https:\\/\\/[^"]+"' |
# 3. Reemplazar \/ por / y quitar comillas
sed 's#\\/#/#g' | sed 's/"//g' |
# 4. Filtrar por sitios conocidos
grep -Ei "$(IFS="|"; echo "${sites[*]}" | sed 's/\./\\./g')" >> "$final"

# === Eliminar duplicados ===
sort -u "$final" -o "$final"

# === Mostrar resultado ===
echo "✅ Enlaces extraídos de $web:"
cat "$final"

