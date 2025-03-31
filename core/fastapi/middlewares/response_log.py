from datetime import datetime
from typing import Optional

from fastapi import Request, Response
from pydantic import BaseModel, ConfigDict, Field
from starlette.datastructures import Headers
from starlette.middleware.base import BaseHTTPMiddleware

from utils.log_utils import save_log_to_file


class ResponseInfo(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)

    headers: Headers | None = Field(None, title="Response headers")
    body: str = Field("", title="Response body")
    status_code: Optional[int] = Field(default=None, title="Status code")


class ResponseLogMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start = datetime.utcnow()
        response = await call_next(request)

        body = b""
        async for chunk in response.body_iterator:
            body += chunk

        trace_id = getattr(request.state, "trace_id", "unknown")

        response_info = ResponseInfo(
            headers=response.headers,
            status_code=response.status_code,
            body=body.decode("utf-8", errors="ignore"),
        )

        save_log_to_file(
            {
                "type": "response",
                "trace_id": trace_id,
                "timestamp": datetime.utcnow().isoformat(),
                "duration_ms": round(
                    (datetime.utcnow() - start).total_seconds() * 1000, 2
                ),
                "response": response_info.model_dump(),
            }
        )

        response = Response(
            content=body,
            status_code=response.status_code,
            headers=dict(response.headers),
            media_type=response.media_type,
        )

        response.headers["X-Trace_Id"] = trace_id
        return response
