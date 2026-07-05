from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy import DateTime, func
from sqlmodel import Field, SQLModel


class Base(SQLModel):
    __abstract__ = True

    # PK = UUID generada en cliente (offline-first; last-write-wins por updated_at).
    # La PK ya está indexada por definición -> sin index=True redundante.
    id: UUID = Field(default_factory=uuid4, primary_key=True)

    created_at: datetime = Field(
        default_factory=lambda: datetime.now(UTC),
        sa_type=DateTime(timezone=True),
        sa_column_kwargs={"server_default": func.now()},
        nullable=False,
    )

    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(UTC),
        sa_type=DateTime(timezone=True),
        sa_column_kwargs={"onupdate": func.now(), "server_default": func.now()},
        nullable=False,
    )


class SoftDeleteMixin(SQLModel):
    """Mixin para entidades sincronizables: el borrado se propaga como soft delete."""

    deleted_at: datetime | None = Field(
        default=None,
        sa_type=DateTime(timezone=True),
        nullable=True,
    )
