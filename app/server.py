from typing import List

from fastapi import FastAPI
from fastapi.middleware import Middleware
from fastapi.middleware.cors import CORSMiddleware


def make_middleware() -> List[Middleware]:
    middleware = [
        Middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
    ]
    return middleware


def create_app() -> FastAPI:
    app_ = FastAPI(
        title="Community Be",
        description="Community Be",
        version="0.1.0",
        docs_url="/docs",
        redoc_url="/redoc",
        middleware=make_middleware(),
    )

    return app_


app = create_app()
