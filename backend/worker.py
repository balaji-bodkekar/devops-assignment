from celery import Celery
import time

# Configure Celery to use Redis as the message broker
celery = Celery(
    "worker",  # This is the name of your Celery application
    broker="redis://localhost:6379/0",  # This is the Redis connection string
    backend="redis://localhost:6379/0",  # for storing task results
)


@celery.task
def write_log_celery(message: str):
    time.sleep(10)
    with open("log_celery.txt", "a") as f:
        f.write(f"{message}\n")
    return f"Task completed: {message}"

