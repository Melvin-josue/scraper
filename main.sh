#!/bin/env bash

echo "iniciando descarga.."

trap 'echo -e "\n Detenido en la pagina $i. podes reanudar desde ahi mas tarde."; exit' SIGINT

for ((i=739;i<=1157;i++)); do
  echo "pagina $i"
  curl "https://api.jikan.moe/v4/anime?page=${i}" | jq '.data[].titles[] | select(.type == "Default") | {type, title}' >> ./web/result_json_jikan/jikan.json

  if ((i % 30 == 0)); then
    echo "Esperando 20 segundos para evitar bloqueo de la api..."
    sleep 30
  fi 
done

echo "descarga completa"
