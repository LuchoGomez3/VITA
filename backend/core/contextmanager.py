from contextlib import asynccontextmanager

from fastapi import FastAPI
from sqlalchemy import text

from core.config import EnvironmentOption, settings
from database.database import create_tables, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Starting application...")

    # Verify connection to the database
    try:
        async with engine.begin() as conn:
            result = await conn.execute(text("SELECT version()"))
            version = result.scalar()
            print("✅ Connection to PostgreSQL established")
            print(f"📊 Version: {version}")

        # In production, Alembic handles schema migrations via pre-deploy command.
        # create_tables() is kept only as a dev/test fallback.
        if settings.ENVIRONMENT in (EnvironmentOption.LOCAL, EnvironmentOption.TEST):
            # Import the model registry so every table is registered in
            # SQLModel.metadata before create_all runs.
            import api.modules  # noqa: F401

            await create_tables()
            print("✅ Tables verified/created (dev fallback)")

    except Exception as e:
        print(f"❌ Error connecting to database: {e}")
        raise

    yield

    # Shutdown: Close connections
    print("🛑 Closing application...")
    await engine.dispose()
    print("✅ Connections closed")
