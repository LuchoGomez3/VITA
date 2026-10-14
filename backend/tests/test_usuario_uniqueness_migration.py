"""Pruebas de la migración que protege email y CUIT en usuarios."""

import importlib.util
from pathlib import Path

import pytest
import sqlalchemy as sa
from sqlalchemy.exc import IntegrityError

_MIGRATION_PATH = (
    Path(__file__).parents[1]
    / "alembic"
    / "versions"
    / "20260819_01_unicidad_usuarios.py"
)


def _load_migration():
    spec = importlib.util.spec_from_file_location(
        "usuario_uniqueness_migration", _MIGRATION_PATH
    )
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class _Operations:
    """Adaptador mínimo para ejecutar la migración contra SQLite en memoria."""

    def __init__(self, connection: sa.Connection) -> None:
        self.connection = connection

    def get_bind(self) -> sa.Connection:
        return self.connection

    def create_index(
        self,
        name: str,
        table_name: str,
        columns: list[str],
        *,
        unique: bool,
        **_: object,
    ) -> None:
        uniqueness = "UNIQUE " if unique else ""
        self.connection.execute(
            sa.text(
                f"CREATE {uniqueness}INDEX {name} "
                f"ON {table_name} ({', '.join(columns)})"
            )
        )

    def drop_index(self, name: str, *, table_name: str) -> None:
        del table_name
        self.connection.execute(sa.text(f"DROP INDEX {name}"))


def _create_usuarios(connection: sa.Connection) -> None:
    connection.execute(
        sa.text(
            """
            CREATE TABLE usuarios (
                id TEXT PRIMARY KEY,
                email TEXT NOT NULL,
                cuit TEXT
            )
            """
        )
    )


def test_migration_normalizes_and_protects_unique_values(monkeypatch):
    migration = _load_migration()
    engine = sa.create_engine("sqlite:///:memory:")

    with engine.begin() as connection:
        _create_usuarios(connection)
        connection.execute(
            sa.text(
                "INSERT INTO usuarios (id, email, cuit) "
                "VALUES ('1', ' Usuario@Campo.com ', '20111111112')"
            )
        )
        monkeypatch.setattr(migration, "op", _Operations(connection))

        migration.upgrade()
        # Una segunda ejecución adopta los índices existentes sin fallar.
        migration.upgrade()

        email = connection.execute(
            sa.text("SELECT email FROM usuarios WHERE id = '1'")
        ).scalar_one()
        assert email == "usuario@campo.com"

        indexes = {
            index["name"]: index
            for index in sa.inspect(connection).get_indexes("usuarios")
        }
        assert indexes["uq_usuarios_email"]["unique"] == 1
        assert indexes["uq_usuarios_cuit"]["unique"] == 1

        with pytest.raises(IntegrityError):
            connection.execute(
                sa.text(
                    "INSERT INTO usuarios (id, email, cuit) "
                    "VALUES ('2', 'otro@campo.com', '20111111112')"
                )
            )


@pytest.mark.parametrize(
    ("rows", "expected_message"),
    [
        (
            [
                ("1", "Usuario@Campo.com", "20111111112"),
                ("2", " usuario@campo.com ", "20111111120"),
            ],
            "emails duplicados",
        ),
        (
            [
                ("1", "uno@campo.com", "20111111112"),
                ("2", "dos@campo.com", "20111111112"),
            ],
            "CUIT duplicados",
        ),
    ],
)
def test_migration_stops_before_creating_indexes_on_duplicates(
    monkeypatch,
    rows,
    expected_message,
):
    migration = _load_migration()
    engine = sa.create_engine("sqlite:///:memory:")

    with engine.begin() as connection:
        _create_usuarios(connection)
        connection.execute(
            sa.text(
                "INSERT INTO usuarios (id, email, cuit) VALUES (:id, :email, :cuit)"
            ),
            [dict(zip(("id", "email", "cuit"), row, strict=True)) for row in rows],
        )
        monkeypatch.setattr(migration, "op", _Operations(connection))

        with pytest.raises(RuntimeError, match=expected_message):
            migration.upgrade()

        assert sa.inspect(connection).get_indexes("usuarios") == []
