"""Tests unitarios de `api.shared.cuit` (red de seguridad de la migración de
código: la lógica vivía duplicada/inline en `usuarios` antes de esta extracción).
"""

import pytest

from api.shared.cuit import normalizar_cuit, validar_cuit


@pytest.mark.parametrize(
    "cuit",
    [
        "20111111112",
        "27000000006",
        "30000000007",
    ],
)
def test_validar_cuit_validos(cuit):
    assert validar_cuit(cuit) is True


@pytest.mark.parametrize(
    "cuit",
    [
        "20111111113",  # digito verificador equivocado
        "20-11111111-2",  # con guiones: exige solo digitos
        "2011111111",  # 10 digitos
        "",
    ],
)
def test_validar_cuit_invalidos(cuit):
    assert validar_cuit(cuit) is False


@pytest.mark.parametrize(
    ("valor", "esperado"),
    [
        ("20-11111111-2", "20111111112"),
        ("20 11111111 2", "20111111112"),
        ("20111111112", "20111111112"),
    ],
)
def test_normalizar_cuit_quita_separadores(valor, esperado):
    assert normalizar_cuit(valor) == esperado


@pytest.mark.parametrize("valor", ["123", "201111111123", "abcdefghijk"])
def test_normalizar_cuit_rechaza_formato_invalido(valor):
    with pytest.raises(ValueError):
        normalizar_cuit(valor)
