import os
import time

from watchdog.events import PatternMatchingEventHandler
from watchdog.observers import Observer


def on_modified(event):

    print(f"File: {event.src_path} has been changed")
    os.system(f"cd ../; bin/compile.sh flush_cache;") # Comes from Bash script


if __name__ == '__main__':
    patterns = ["*"]
    ignore_patterns = None
    ignore_directories = False
    case_sensitive = True
    my_event_handler = PatternMatchingEventHandler(patterns, ignore_patterns, ignore_directories, case_sensitive)
    my_event_handler.on_modified = on_modified

    path = f"../app/design/frontend/Kommerce/base/Magento_Theme/templates/html"
    go_recursively = True
    my_observer = Observer()
    my_observer.schedule(my_event_handler, path, recursive=go_recursively)

    my_observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        my_observer.stop()
        my_observer.join()
