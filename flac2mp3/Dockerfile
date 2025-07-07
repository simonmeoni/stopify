FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y ffmpeg inotify-tools && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY convert.sh /app/convert.sh
RUN chmod +x /app/convert.sh

CMD ["/app/convert.sh"]
