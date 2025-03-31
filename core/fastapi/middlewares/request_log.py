from datetime import datetime
from typing import Optional

from fastapi import Request
from nanoid import generate
from pydantic import BaseModel, ConfigDict, Field
from starlette.datastructures import Headers
from starlette.middleware.base import BaseHTTPMiddleware

from utils.log_utils import save_log_to_file


class RequestInfo(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)

    method: str = Field(title="HTTP Method")
    url: str = Field(title="Request URL")
    client: Optional[str] = Field(default=None, title="Client IP")
    headers: Headers | None = Field(default=None, title="Request Headers")
    body: str = Field(default="", title="Request Body")


class RequestLogMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        trace_id = generate()
        request.state.trace_id = trace_id

        body = await request.body()

        request_info = RequestInfo(
            method=request.method,
            url=str(request.url),
            headers=request.headers,
            client=request.client.host if request.client else None,
            body=body.decode("utf-8", errors="ignore"),
        )

        save_log_to_file(
            {
                "type": "request",
                "trace_id": trace_id,
                "timestamp": datetime.utcnow().isoformat(),
                "request": request_info.model_dump(),
            }
        )

        return await call_next(request)
