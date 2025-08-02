#scritp para scrapear algunas webs

from curl_cffi import requests
from bs4 import Beautifulsoup

#Definimos la web
url = input("Ingresa la web: \n")

#Obtenemos el html
re = requests.get(url, impersonate="chrome")

soup = Beautifulsoup(re.txt, "html.parser")
