#!/bin/env bash

#Reconstructor de url de busqueda

#agente
agent="Mozilla/5.0"

#webs a buscar
aniyt="https://animeytx.com/?s="

#Resultante
web1="animeytx.com"

#haciendo la peticion
ur1="${aniyt}${line}"

#Donde se guarda todo
final="./web/result_html/"
log="./cache/"

#Donde sale
rout="./web/result_json_jikan/jikan.names.txt"

while IFS= read -r line;
do
  echo "buscando ${line}"
  clean_name=$(echo ${line} | tr '' '_' | tr -dc '[:alnum:]_')
  res=$(curl -s -A "${agent}" "${ur1}")
  final2="${final}/${web1}.${clean_name}.html"

  if [[ -n "${res}" ]] && ! echo ${res} | grep -qi "No found"; then
    echo "${res}" > "${final2}"
    echo "Guardado como ${final2}"
  else
    echo "Fallo o no existe..."
    echo "${line}" >> "./${log}/${web1}.${clean_name}.log"
  fi

  echo "esperando 5 segundos"
  sleep 5
done < "${rout}"

echo "Terminado satisfactoriamente"