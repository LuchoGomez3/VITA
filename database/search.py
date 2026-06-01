"""Helpers for safe ILIKE pattern construction in SQLAlchemy queries."""


def escape_like(value: str) -> str:
    """Escape backslash, percent, and underscore so they are treated as literals in ILIKE."""
    return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


def like_pattern(value: str, *, prefix: str = "%", suffix: str = "%") -> str:
    """Return a safe ILIKE pattern with special characters escaped.

    Use with ``ilike(pattern, escape="\\")`` to prevent user input from acting
    as wildcards.

    Example::

        Column.name.ilike(like_pattern(user_input), escape="\\\\")
    """
    return f"{prefix}{escape_like(value)}{suffix}"
