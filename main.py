import uvicorn


def main():
    uvicorn.run(
        app="app.server:app",
        host="0.0.0.0",
        port=8000,
        workers=4,
    )


if __name__ == "__main__":
    main()
