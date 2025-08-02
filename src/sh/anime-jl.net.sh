#!/usr/bin/env bash

# Scraper para anime-jl.net
web="anime-jl.net"
url="$1"
anime="$2"
html="${web}.html"
output="${web}.txt"
final="url.${web}.${anime}.txt"

# Comprobación de argumentos
if [[ -z "$url" || -z "$anime" ]]; then
    echo "Uso: $0 <URL del episodio> <nombre_del_anime>"
    exit 1
fi

# Limpieza
> "$html"
> "$output"
> "$final"

# Descargar HTML
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

# Palabras clave
keywords=("exe.io" "descargar" "embed" "https://" "voe" "filemoon" "movearnpre" "hglink" "dhtpre" "savefiles" "listeamed" "mp4upload" "mxdrop" "powvideo" "streanplay" "upload" "hqq" "mega" "mediafire" "worlduploads" "fileblade" "megaup" "yourupload" "burstcloud" "terabox" "zippyshare" "Burscloud" "1fichier" "4funbox" "sendvid" "ok" "hlswish" "vidhideplus")

sites=("mega.nz" "mediafire.com" "burstcloud.co" "fileblade.com" "mp4upload.com" "voe.sx" "filemoon.sx" "megaup.net" "upload.sx" "powvideo.org" "mxdrop.org" "hglink.to" "hqq.to" "streanplay.to" "movearnpre.com" "dhtpre.com" "savefiles.com" "listeamed.net" "worlduploads.com" "yourupload.com" "zippyshare.com" "1fichier.com" "terabox.com" "4funbox.com" "sendvid" "ok" "hlswish" "vidhideplus")

# Buscar líneas relevantes
for word in "${keywords[@]}"; do
    grep -i "$word" "$html" >> "$output"
done

# Preparar regex escapada para sitios
escaped_sites=$(printf "%s\n" "${sites[@]}" | sed 's/\./\\./g' | paste -sd'|' -)

# Extraer hrefs válidos
grep -oP "href='(https?://[^']+)'" "$output" |
grep -Ei "$escaped_sites" >> "$final"

# Extraer iframes de JS (video[0] = '<iframe src="..."')
grep -oP "video\[\d+\]\s*=\s*'<iframe src=\"\K[^\"]+" "$html" >> "$final"

# Eliminar duplicados
sort -u "$final" -o "$final"

# Mostrar resultados
echo "✅ URLs filtradas del antibots de ${web}:"
cat "$final" | cut -d'=' -f3-

