"""Excepciones de dominio del módulo establecimientos."""

from api.shared.exceptions import ConflictError, NotFoundError, ValidationError


class RenspaDuplicadoError(ConflictError):
    code = "renspa_duplicado"

    def __init__(self, nro_renspa: str) -> None:
        super().__init__(f"El RENSPA '{nro_renspa}' ya está registrado")


class RenspaVacioError(ValidationError):
    code = "renspa_vacio"

    def __init__(self) -> None:
        super().__init__("El RENSPA es obligatorio y no puede estar vacío")


class EstablecimientoNoEncontradoError(NotFoundError):
    code = "establecimiento_no_encontrado"

    def __init__(self) -> None:
        super().__init__("Establecimiento no encontrado o sin acceso")


class RenspaFormatoInvalidoError(ValidationError):
    code = "renspa_formato_invalido"

    def __init__(self, nro_renspa: str) -> None:
        super().__init__(
            f"El RENSPA '{nro_renspa}' no tiene el formato esperado (NN.NNN.N.NNNNN/NN)"
        )


class SuperficieInvalidaError(ValidationError):
    code = "superficie_invalida"

    def __init__(self) -> None:
        super().__init__("La superficie debe ser mayor a cero")
