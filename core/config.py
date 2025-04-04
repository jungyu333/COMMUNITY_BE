import os

from pydantic_settings import BaseSettings


class Config(BaseSettings):
    ENV: str = "development"
    DEBUG: bool = True
    APP_HOST: str = "127.0.0.1"
    APP_PORT: int = 8000
    WRITER_DB_URL: str = "mysql+aiomysql://root:community@localhost:33306/community"
    READER_DB_URL: str = "mysql+aiomysql://root:community@localhost:33307/community"


class LocalConfig(Config):
    ...


class ProductionConfig(Config):
    ENV: str = "production"
    DEBUG: bool = False


def get_config(env: str | None = None) -> Config:
    actual_env = env if env else os.environ.get("ENV", "local")

    config_type = {
        "local": LocalConfig,
        "prod": ProductionConfig,
    }

    return config_type.get(actual_env, LocalConfig)()
