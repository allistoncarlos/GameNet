#!/usr/bin/env python3
"""Próximo número de build (CFBundleVersion) para a versão de marketing atual.

O TestFlight só exige que o build seja único *dentro* de uma mesma versão de
marketing — não há motivo para o número crescer para sempre. Em vez de usar o
contador de execuções do GitHub (que nunca reinicia), este script pergunta à
App Store Connect quais builds já existem para esta versão nesta plataforma e
devolve o maior + 1. Versão que ainda não tem nenhum build começa do 1, então
todo bump de versão recomeça a contagem.

Lê da env: APPSTORE_KEY_ID, APPSTORE_ISSUER_ID, AUTH_KEY_PATH (o .p8),
BUNDLE_ID, VERSION e PLATFORM. Imprime só o número no stdout.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import jwt

API = "https://api.appstoreconnect.apple.com/v1"

# Nomes que a App Store Connect usa no filtro de plataforma.
PLATFORMS = {
    "iOS": "IOS",
    "macOS": "MAC_OS",
    "tvOS": "TV_OS",
    "visionOS": "VISION_OS",
}


def die(message: str) -> None:
    print(f"::error::{message}", file=sys.stderr)
    raise SystemExit(1)


def require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        die(f"Variável {name} vazia — não dá para calcular o número do build.")
    return value


def make_token(key_id: str, issuer_id: str, key_path: str) -> str:
    try:
        with open(key_path, "r", encoding="utf-8") as handle:
            private_key = handle.read()
    except OSError as error:
        die(f"Não consegui ler a chave da API em {key_path}: {error}")

    now = int(time.time())

    return jwt.encode(
        {
            "iss": issuer_id,
            "iat": now,
            "exp": now + 600,
            "aud": "appstoreconnect-v1",
        },
        private_key,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )


def get(url: str, token: str) -> dict:
    request = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})

    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        body = error.read().decode("utf-8", errors="replace")[:400]
        die(f"App Store Connect respondeu {error.code}: {body}")
    except urllib.error.URLError as error:
        die(f"Não consegui falar com a App Store Connect: {error.reason}")

    return {}


def endpoint(path: str, params: dict) -> str:
    return f"{API}/{path}?{urllib.parse.urlencode(params)}"


def find_app_id(bundle_id: str, token: str) -> str:
    payload = get(endpoint("apps", {"filter[bundleId]": bundle_id, "limit": 200}), token)
    apps = payload.get("data") or []

    if not apps:
        die(
            f"Nenhum app com bundle {bundle_id} nesta conta da App Store Connect. "
            "Confira o PRODUCT_BUNDLE_IDENTIFIER e a chave da API."
        )

    return apps[0]["id"]


def existing_build_numbers(app_id: str, version: str, platform: str, token: str) -> list:
    url = endpoint(
        "builds",
        {
            "filter[app]": app_id,
            "filter[preReleaseVersion.version]": version,
            "filter[preReleaseVersion.platform]": platform,
            "fields[builds]": "version",
            "limit": 200,
        },
    )

    numbers = []

    # A App Store Connect pagina em `links.next`; uma versão dificilmente passa
    # de uma página, mas seguir o link sai mais barato do que descobrir do jeito
    # difícil que o build 201 virou build 1 de novo.
    while url:
        payload = get(url, token)

        for build in payload.get("data") or []:
            raw = (build.get("attributes") or {}).get("version")
            try:
                numbers.append(int(str(raw).strip()))
            except (TypeError, ValueError):
                print(f"Ignorando build com número não-numérico: {raw!r}", file=sys.stderr)

        url = (payload.get("links") or {}).get("next")

    return numbers


def main() -> None:
    key_id = require_env("APPSTORE_KEY_ID")
    issuer_id = require_env("APPSTORE_ISSUER_ID")
    key_path = require_env("AUTH_KEY_PATH")
    bundle_id = require_env("BUNDLE_ID")
    version = require_env("VERSION")
    platform_name = require_env("PLATFORM")

    platform = PLATFORMS.get(platform_name)
    if platform is None:
        die(f"Plataforma desconhecida: {platform_name}. Esperado uma de {', '.join(PLATFORMS)}.")

    token = make_token(key_id, issuer_id, key_path)
    app_id = find_app_id(bundle_id, token)
    numbers = existing_build_numbers(app_id, version, platform, token)

    if numbers:
        next_build = max(numbers) + 1
        print(
            f"{platform_name} {version}: builds existentes {sorted(numbers)} → próximo {next_build}",
            file=sys.stderr,
        )
    else:
        next_build = 1
        print(f"{platform_name} {version}: primeira build desta versão → 1", file=sys.stderr)

    print(next_build)


if __name__ == "__main__":
    main()
