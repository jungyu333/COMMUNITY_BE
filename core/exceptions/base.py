class BaseCustomException(Exception):
    def __init__(self, code: int = 400, message: str = "", data: dict | None = None):
        self.code = code
        self.message = message
        self.data = data or {}


class NotFoundException(BaseCustomException):
    def __init__(self, message="Not Found", data=None):
        super().__init__(code=404, message=message, data=data)


class UnauthorizedException(BaseCustomException):
    def __init__(self, message="Unauthorized", data=None):
        super().__init__(code=401, message=message, data=data)


class ForbiddenException(BaseCustomException):
    def __init__(self, message="Forbidden", data=None):
        super().__init__(code=403, message=message, data=data)


class BadRequestException(BaseCustomException):
    def __init__(self, message="Bad Request", data=None):
        super().__init__(code=400, message=message, data=data)


class ServerErrorException(BaseCustomException):
    def __init__(self, message="Internal Server Error", data=None):
        super().__init__(code=500, message=message, data=data)
