import os
import shutil
import subprocess
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

SRC_DIR = Path("/music")
DST_DIR = Path("/music_mp3")
COPY_EXTENSIONS = {
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "cue",
    "log",
    "txt",
    "nfo",
    "mp3",
}


def convert_flac(src_file: Path):
    rel_path = src_file.relative_to(SRC_DIR)
    out_path = DST_DIR / rel_path.with_suffix(".mp3")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    if not out_path.exists():
        print(f"[INFO] Converting: {rel_path}")
        subprocess.run(
            [
                "ffmpeg",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(src_file),
                "-ab",
                "320k",
                str(out_path),
            ]
        )
        print(f"[INFO] Done: {out_path}")
    else:
        print(f"[SKIP] Already exists: {out_path}")


def copy_file(src_file: Path):
    rel_path = src_file.relative_to(SRC_DIR)
    out_path = DST_DIR / rel_path
    out_path.parent.mkdir(parents=True, exist_ok=True)

    if not out_path.exists():
        shutil.copy2(src_file, out_path)
        print(f"[COPY] {rel_path}")
    else:
        print(f"[SKIP] Already exists: {rel_path}")


def initial_scan():
    print(f"[INIT] Initial scan of {SRC_DIR}")
    for path in SRC_DIR.rglob("*"):
        if path.is_file():
            ext = path.suffix.lower().lstrip(".")
            if ext == "flac":
                convert_flac(path)
            elif ext in COPY_EXTENSIONS:
                copy_file(path)
    print("[INIT] Initial scan complete.")


class WatcherHandler(FileSystemEventHandler):
    def on_created(self, event):
        if not event.is_directory:
            self.process(Path(event.src_path))

    def on_moved(self, event):
        if not event.is_directory:
            self.process(Path(event.dest_path))

    def on_modified(self, event):
        if not event.is_directory:
            self.process(Path(event.src_path))

    def process(self, path: Path):
        if not path.exists():
            return
        ext = path.suffix.lower().lstrip(".")
        if ext == "flac":
            convert_flac(path)
        elif ext in COPY_EXTENSIONS:
            copy_file(path)


def watch():
    print(f"[WATCH] Watching {SRC_DIR} for new files...")
    observer = Observer()
    observer.schedule(WatcherHandler(), str(SRC_DIR), recursive=True)
    observer.start()
    try:
        while True:
            pass  # Replace with sleep(1) or signal.pause() for better efficiency
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    initial_scan()
    watch()
