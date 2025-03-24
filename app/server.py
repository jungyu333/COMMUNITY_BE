from typing import List

from fastapi import FastAPI, Request
from fastapi.middleware import Middleware
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from core.exceptions.base import BaseCustomException


def init_listeners(app_: FastAPI) -> None:
    @app_.exception_handler(BaseCustomException)
    async def custom_exception_handler(request: Request, exc: BaseCustomException):
        return JSONResponse(
            status_code=exc.code,
            content={
                "code": exc.code,
                "message": exc.message,
                "data": exc.data,
            },
        )


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
    init_listeners(app_=app_)

    return app_


app = create_app()
