import pika

from settings import URI

# params = pika.ConnectionParameters('localhost')
params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

#channel.queue_declare(queue="test_q")             # в новой версии rabbitmq  выключено по умолчанию, нужно указать durable=True
channel.queue_declare(queue="test_q", durable=True) 
if __name__ == "__main__":

    channel.basic_publish(
        exchange="",
        routing_key="test_q",
        body="Hello, Ershov! - 19.05.2026",
    )