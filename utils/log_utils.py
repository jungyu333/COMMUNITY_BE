import json
from datetime import datetime
from pathlib import Path

LOG_DIR = Path("logs")
LOG_DIR.mkdir(exist_ok=True)


def save_log_to_file(log_data: dict):
    today = datetime.utcnow().strftime("%Y-%m-%d")
    log_path = LOG_DIR / f"{today}.log"

    with log_path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(log_data, ensure_ascii=False) + "\n")
