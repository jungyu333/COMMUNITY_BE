import click
import uvicorn

from core.config import get_config


@click.command()
@click.option(
    "--env",
    type=click.Choice(["local", "dev", "prod"], case_sensitive=False),
    default="local",
)
@click.option(
    "--debug",
    type=click.BOOL,
    is_flag=True,
    default=False,
)
def main(env: str, debug: bool):
    config = get_config(env)

    config.DEBUG = debug or config.DEBUG

    uvicorn.run(
        app="app.server:app",
        host="localhost",
        port=8000,
        reload=True if config.ENV != "production" else False,
        workers=1,
    )


if __name__ == "__main__":
    main()
