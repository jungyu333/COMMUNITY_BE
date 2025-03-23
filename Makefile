.PHONY: run-local run-dev run-prod


kill-port-windows:
	@echo "Killing process on port 8000 (Windows)..."
	@powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./script/kill-port.ps1

run-local:
	poetry run python main.py --env local

run-dev:
	poetry run python main.py --env dev --debug

run-prod:
	poetry run python main.py --env prod
