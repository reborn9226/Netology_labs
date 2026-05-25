import pika

from settings import URI

# params = pika.ConnectionParameters('localhost')
params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

channel.queue_declare(queue="test_ershov")

if __name__ == "__main__":

    count = 0

    while True:
        channel.basic_publish(
            exchange="",
            routing_key="test_ershov",
            body=f"Hello, Ershov! - {count}",
        )
        count += 1
