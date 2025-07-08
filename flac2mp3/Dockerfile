FROM python:3.11-slim

# Install ffmpeg
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy Python script
COPY convert.py /app/convert.py

# Install watchdog
RUN pip install watchdog

# Entrypoint
CMD ["python", "/app/convert.py"]
