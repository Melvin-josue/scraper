import re
import base64
from bs4 import BeautifulSoup
from curl_cffi import requests

def decodificar_base64_recursivo(s, max_intentos=10):
    intento = 0
    while intento < max_intentos:
        try:
            s_bytes = base64.b64decode(s)
            nuevo = s_bytes.decode('utf-8')
            if nuevo == s:
                break
            s = nuevo
            intento += 1
        except Exception:
            break
    return s

headers = {
    "user-agent": "Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-G973U)"
}

# Paso 1: Obtener links pastelinks desde animecompleto.com/toradora/
url_inicial = "https://animecompleto.com/toradora"
res = requests.get(url_inicial, headers=headers, impersonate="chrome")
soup = BeautifulSoup(res.text, "html.parser")

links = soup.find_all('a', {"class": "btn_icon_desc btn_animacion"}, href=True)

pastelink = None
for link in links:
    link_candidado = link['href']
    print(f"🔎 Probando → {link_candidado}")
    try:
        res2 = requests.get(link_candidado, headers=headers, impersonate="chrome", allow_redirects=True)
        if res2.status_code == 200:
            pastelink = link_candidado
            print(f"✅ Link válido encontrado: {pastelink}")
            break
    except Exception:
        pass  # Ignorar errores y seguir probando

if not pastelink:
    print("❌ No se encontró link pastelinks válido.")
    exit(1)

# Paso 2: Usar pastelink para extraer el enlace gourlcero base64 y decodificarlo
response = requests.get(pastelink, headers=headers, impersonate="chrome", allow_redirects=True)
soup2 = BeautifulSoup(response.text, "html.parser")

gourl = soup2.find("a", href=re.compile(r"gourlcero\.com/o\.php\?l="))
if gourl:
    b64_part = gourl['href'].split("l=")[-1]
    enlace_final = decodificar_base64_recursivo(b64_part)
    print(f"🔑 Enlace final decodificado:\n{enlace_final}")
else:
    print("❌ No se encontró enlace base64 (gourlcero)")

