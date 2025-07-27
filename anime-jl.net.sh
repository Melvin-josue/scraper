#!/usr/bin/env bash

# Scraper para anime-jl.net
web="anime-jl.net"
anime="$2"
url="$1"
html="${web}.html"
output="${web}.txt"

> "$html"

# Descargar el HTML
curl -A "Mozilla/5.0" -sL "$url" -o "$html"

# Palabras clave (dominios o identificadores de enlaces)
keywords=("exe.io" "descargar" "embed" "https://" "voe" "filemoon" "movearnpre" "hglink" "dhtpre" "savefiles" "listeamed" "mp4upload" "mxdrop" "powvideo" "streanplay" "upload" "hqq" "mega" "mediafire" "worlduploads" "fileblade" "megaup" "yourupload" "burstcloud" "terabox" "zippyshare" "Burscloud" "1fichier" "4funbox" "sendvid" "ok" "hlswish" "vidhideplus")



# Limpiar archivo de salida
> "$output"
> url.${web}.${anime}.txt

# Buscar líneas con esas palabras
for word in "${keywords[@]}"; do
    grep -i "$word" "$html" >> "$output"
done

# Extraer solo las URLs de los href
grep -oP "href='\K[^']+" "$output" > urls.${web}.txt

# Filtrar solo los sitios de descarga conocidos
sites=("mega.nz" "mediafire.com" "burstcloud.co" "fileblade.com" "mp4upload.com" "voe.sx" "filemoon.sx" "megaup.net" "upload.sx" "powvideo.org" "mxdrop.org" "hglink.to" "hqq.to" "streanplay.to" "movearnpre.com" "dhtpre.com" "savefiles.com" "listeamed.net" "hqq.to" "worlduploads.com" "yourupload.com" "zippyshare.com" "1fichier.com" "terabox.com" "4funbox.com" "sendvid" "ok" "hlswish" "vidhideplus")

#grep -oP "href='\K[^']+" "$output" | grep -E "$(IFS="|"; echo "${sites[*]}")" | cut -d'=' -f3- > final_url.txt
# Extraer y filtrar sin duplicados
#grep -oP "href='(https?://[^']+)'" "$output" | grep -E "$(IFS="|"; echo "${sites[*]}")" | cut -d"'" -f2- | sort -u > url.${web}.${anime}.txt

# Extraer URLs desde iframes en variables tipo video[0] = '<iframe src="...">'
#grep -oP "video\[\d+\]\s*=\s*'<iframe src=\"\K[^\"]+" "$html" | sort -u >> url.${web}.${anime}.txt

# Extraer URLs desde href en HTML
grep -oP "href='(https?://[^']+)'" "$output" |
grep -E "$(IFS="|"; echo "${sites[*]}")" |
cut -d"'" -f2- >> url.${web}.${anime}.txt

# Extraer URLs desde iframes incrustados en variables video[]
grep -oP "video\[\d+\]\s*=\s*'<iframe src=\"\K[^\"]+" "$html" >> url.${web}.${anime}.txt

# Eliminar duplicados
sort -u url.${web}.${anime}.txt -o url.${web}.${anime}.txt



echo "URLs filtradas del el antibots de la pagina ${web}:"
cat url.${web}.${anime}.txt | cut -d'=' -f3-
#grep -E "$(IFS="|"; echo "${sites[*]}")" urls.txt | cut -d'=' -f3-

