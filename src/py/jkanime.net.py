#!/usr/bin/env python3
import re
import sys
import json
import base64
from curl_cffi import requests
from bs4 import BeautifulSoup

def extract_jkanime_links(html):
    """Extrae todos los enlaces de video de JKAnime"""
    results = []
    
    # 1. Extraer iframes directos
    iframe_pattern = re.compile(r'video\[\d+\]\s*=\s*[\'"]<iframe[^>]+src=[\'"]([^\'"]+)')
    iframe_matches = iframe_pattern.findall(html)
    results.extend(iframe_matches)
    
    # 2. Extraer el objeto servers con enlaces codificados
    servers_match = re.search(r'var\s+servers\s*=\s*(\[.*?\]);', html, re.DOTALL)
    if servers_match:
        try:
            servers = json.loads(servers_match.group(1))
            for server in servers:
                try:
                    decoded_url = base64.b64decode(server['remote']).decode('utf-8')
                    results.append(decoded_url)
                except:
                    continue
        except json.JSONDecodeError:
            pass
    
    # 3. Extraer enlaces de reproductores JKAnime
    jkplayer_pattern = re.compile(r'src="https://jkanime\.net/jkplayer/(?:um|umv|c1)\?[^"]+')
    jkplayer_matches = jkplayer_pattern.findall(html)
    results.extend(match.replace('src="', '') for match in jkplayer_matches)
    
    return sorted(set(results))

def main():
    if len(sys.argv) < 2:
        print("Uso: python jkanime_scraper.py <URL> [--full]")
        print("Ejemplo: python jkanime_scraper.py https://jkanime.net/demon-slayer/1/")
        sys.exit(1)
    
    url = sys.argv[1]
    show_full = len(sys.argv) > 2 and sys.argv[2] == "--full"
    
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
            "Referer": "https://jkanime.net/"
        }
        
        print(f"🔍 Conectando con {url}...")
        response = requests.get(url, headers=headers, impersonate="chrome")
        response.raise_for_status()
        
        links = extract_jkanime_links(response.text)
        
        if not links:
            print("⚠️ No se encontraron enlaces de video")
            sys.exit(1)
        
        print("\n✅ Enlaces encontrados:")
        for i, link in enumerate(links, 1):
            print(f"{i}. {link}")
            
            # Mostrar detalles adicionales para enlaces JKPlayer
            if show_full and 'jkplayer' in link:
                try:
                    params = dict(pair.split('=') for pair in link.split('?')[1].split('&'))
                    if 'e' in params:
                        decoded = base64.b64decode(params['e']).decode('utf-8')
                        print(f"   Decodificado: {decoded}")
                except:
                    pass
        
        # Guardar opcional
        if input("\n¿Guardar en archivo? (s/n): ").lower() == 's':
            filename = f"jkanime_links_{url.split('/')[-2]}.txt"
            with open(filename, 'w') as f:
                f.write("\n".join(links))
            print(f"💾 Guardado en {filename}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
