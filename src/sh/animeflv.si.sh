#!/usr/bin/env bash

# Variables
web="animeflv.si"
url="$1"
anime="$2"
html="${web}.html"
output="${web}.txt"
final="url.${web}.${anime}.txt"
json="embeds.json"

# Limpiar archivos
> "$html"
> "$output"
> "$final"

# Descargar HTML
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

# Palabras clave a buscar en líneas
keywords=("descargar" "embed" "https://" "voe" "filemoon" "movearnpre" "hglink" "dhtpre" "savefiles" "listeamed" "mp4upload" "mxdrop" "powvideo" "streanplay" "upload" "hqq" "mega" "mediafire" "worlduploads" "fileblade" "megaup" "yourupload" "burstcloud" "terabox" "zippyshare" "1fichier" "4funbox" "fireload")

# Sitios de descarga válidos
sites=("mega.nz" "mediafire.com" "burstcloud.co" "fileblade.com" "mp4upload.com" "voe.sx" "filemoon.sx" "megaup.net" "upload.sx" "powvideo.org" "mxdrop.org" "hglink.to" "hqq.to" "streanplay.to" "movearnpre.com" "dhtpre.com" "savefiles.com" "listeamed.net" "worlduploads.com" "yourupload.com" "zippyshare.com" "1fichier.com" "terabox.com" "4funbox.com" "fireload.com")

# Buscar líneas que contengan cualquier palabra clave
for word in "${keywords[@]}"; do
    grep -i "$word" "$html" >> "$output"
done

# Extraer los hrefs y filtrar por dominios conocidos
grep -oP 'href="https?://[^"]+"' "$output" |
cut -d'"' -f2 |
grep -Ei "$(IFS="|"; echo "${sites[*]}")" |
sort -u > "$final"


# Suponiendo que ya descargaste el HTML y lo tienes en animeflv.si.html
grep -oP 'var videos = \K\{.*?\}(?=</script>)' $html  > $json

cat $json | jq -r '.. | .url? // empty' | sort -u >> "$final"

# Mostrar resultados
echo "✅ URLs filtradas desde $web:"
cat "$final"
