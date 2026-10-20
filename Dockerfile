FROM python:3.11-slim-bookworm

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install a CPU-only torch build first so the unpinned "torch" entry in
# requirements.txt (pulled in for the optional GPU code path) doesn't drag in
# a multi-GB CUDA build on machines/images without a GPU.
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

WORKDIR /app/src

EXPOSE 8006 7860

CMD ["uvicorn", "quran_api:app", "--host", "0.0.0.0", "--port", "8006"]
