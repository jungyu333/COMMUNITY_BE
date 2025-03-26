from pydantic_settings import BaseSettings


class Config(BaseSettings):
    ENV: str = "development"
    DEBUG: bool = True
    APP_HOST: str = "127.0.0.1"
    APP_PORT: int = 8000


class LocalConfig(Config):
    ...


class ProductionConfig(Config):
    ENV: str = "production"
    DEBUG: bool = False


def get_config(env: str) -> Config:
    config_type = {
        "local": LocalConfig,
        "prod": ProductionConfig,
    }

    return config_type.get(env, LocalConfig)()
