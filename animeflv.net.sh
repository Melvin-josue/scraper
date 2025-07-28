#!/usr/bin/env bash

web="animeflv.net"
anime="$2"
url="$1"
html="${web}.html"
output="url.${web}.${anime}.txt"

# Limpieza previa
> "$html"
> "$output"

# Agente de navegador
ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/114.0.0.0 Safari/537.36"

# Descargar HTML
curl -A "$ua" -sL "$url" -o "$html"

# ----------------------------------------
# 1. Extraer todos los links de descarga directos
# ----------------------------------------
grep -oP 'href="https?://[^"]+"' "$html" |
grep -E "mega\.nz|1fichier\.com|streamtape\.com|mediafire\.com|zippyshare\.com|fireload\.com|terabox|gofile\.io" |
sed 's/href="//;s/"$//' >> "$output"

# ----------------------------------------
# 2. Extraer la línea con `var videos = {...}` y parsear JSON
# ----------------------------------------
json=$(grep -oP 'var\s+videos\s*=\s*\{.*?\};' "$html" | sed -E 's/^var videos = //' | sed 's/;$//')

if [[ -n "$json" ]]; then
    # Parsear el JSON con jq (requiere tener jq instalado)
    echo "$json" | jq -r '.SUB[] | select(.url != null) | .url' >> "$output"
    echo "$json" | jq -r '.SUB[] | select(.code != null) | .code' >> "$output"
fi

# ----------------------------------------
# Ordenar y mostrar resultados
# ----------------------------------------
sort -u "$output" -o "$output"

echo "✅ URLs extraídas de ${web} para '$anime':"
cat "$output"

