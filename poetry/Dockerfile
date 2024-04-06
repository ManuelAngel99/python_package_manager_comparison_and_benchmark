FROM python:3.12.2

WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN PYTHONDONTWRITEBYTECODE=1 pip install poetry==1.8.2 && poetry install

COPY src .
ENTRYPOINT  ["poetry","run","python"]