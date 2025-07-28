#!/usr/bin/env bash

web="animeytx.com"
anime="$2"
url="$1"
html="${web}.html"
final="url.${web}.${anime}.txt"

> "$html"
> "$final"

# Descargar la página
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

echo "[*] Extrayendo enlaces base64 decodificados..."

grep '<option value="' "$html" | while read -r line; do
    b64=$(echo "$line" | grep -oP 'value="[^"]+"' | cut -d'"' -f2)
    decoded=$(echo "$b64" | base64 -d 2>/dev/null)

    label=$(echo "$line" | sed -n 's/.*<option[^>]*>\(.*\)<\/option>.*/\1/p' | tr -d '\r\n' | sed 's/^[ \t]*//;s/[ \t]*$//')

    url_decoded=$(echo "$decoded" | grep -oP 'src="([^"]+)"' | head -1 | cut -d'"' -f2)
    if [[ -z "$url_decoded" ]]; then
        url_decoded=$(echo "$decoded" | grep -oP 'href="([^"]+)"' | head -1 | cut -d'"' -f2)
    fi
    if [[ -z "$url_decoded" ]]; then
        url_decoded="$decoded"
    fi

    if [[ -n "$url_decoded" ]]; then
        echo -e "${label}\t${url_decoded}" >> "$final"
    fi
done

echo "[*] Extrayendo enlaces directos href..."

# Extraer links directos comunes (mega, mediafire, etc)
grep -oP 'href="https?://[^"]+"' "$html" | cut -d'"' -f2 | grep -E 'mega.nz|mediafire.com|fireload.com|filemoon.sx|gofile.io|burstcloud.co|yourupload.com|ytlinker.online|ok.ru|1024terabox.com' >> "$final"

# Quitar duplicados y ordenar
sort -u "$final" -o "$final"

echo "✅ URLs filtradas y limpias para ${web}:"
 cat "$final"

