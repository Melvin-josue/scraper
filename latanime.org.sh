#!/usr/bin/env bash

# === Datos base ===
web="ejemplo.com"
url="$1"
anime="$2"
html="${web}.html"
output="${web}.txt"
final="url.${web}.${anime}.txt"

# === Inicializar archivos ===
> "$html"
> "$output"
> "$final"

# === User Agent y descarga ===
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

# === Palabras clave para reducir búsqueda ===
keywords=("descargar" "embed" "data-player" "href" "iframe")

# === Sitios de descarga conocidos (puedes agregar más) ===
sites=("mega.nz" "mediafire.com" "burstcloud.co" "fileblade.com" "mp4upload.com" "voe.sx" "filemoon.sx" "megaup.net" "upload.sx" "powvideo.org" "mxdrop.org" "hglink.to" "hqq.to" "streanplay.to" "movearnpre.com" "dhtpre.com" "savefiles.com" "listeamed.net" "worlduploads.com" "yourupload.com" "zippyshare.com" "1fichier.com" "terabox.com" "4funbox.com" "sendvid.com" "ok.ru" "hlswish.com" "vidhideplus.com" "pixeldrain.com" "uptobox.com" "doodstream.com" "mixdrop.co" "embedwish.com")

# === Buscar líneas relevantes ===
for word in "${keywords[@]}"; do
    grep -i "$word" "$html" >> "$output"
done

# === 1. Extraer href="..." normales ===
grep -oP 'href=["'\''](https?://[^"'\'' >]+)' "$output" |
cut -d'"' -f2 |
grep -E "$(IFS="|"; echo "${sites[*]}" | sed 's/\./\\./g')" >> "$final"

# === 2. Extraer iframe src="..." normales ===
grep -oP '<iframe[^>]+src=["'\''](https?://[^"'\'' >]+)' "$output" |
cut -d'"' -f2 |
grep -E "$(IFS="|"; echo "${sites[*]}" | sed 's/\./\\./g')" >> "$final"

# === 3. Extraer embeds desde data-player="..." en base64 ===
grep -oP 'data-player="[^"]+"' "$output" |
cut -d'"' -f2 |
while read -r encoded; do
    decoded=$(echo "$encoded" | base64 -d 2>/dev/null)
    echo "$decoded"
done | grep -E "$(IFS="|"; echo "${sites[*]}" | sed 's/\./\\./g')" >> "$final"

# === Eliminar duplicados ===
sort -u "$final" -o "$final"

# === Mostrar resultado ===
echo "✅ Todos los enlaces filtrados del sitio ${web}:"
cat "$final"
