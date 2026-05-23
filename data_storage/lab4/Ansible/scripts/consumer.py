import pika
import time

from settings import URI

params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

channel.queue_declare(queue="test_ershov", durable=True, arguments={'x-queue-type': 'quorum'} ) # В новых версиях RabbitMQ необходимо указывать quorum в коде что бы заработал HA, так как был удален механизм зеркалирования классических очередей - обьявлен устаревшим

def callback(ch, method, properties, body) -> None:
    # print(ch, method, properties, body)
    time.sleep(1)
    print(body)


channel.basic_consume(
    queue="test_ershov",
    on_message_callback=callback,
    auto_ack=True,
    consumer_tag="netology_consumer",
)
print(" [*] Ожидание сообщений в 'test_ershov'. Для выхода нажмите CTRL+C")

if __name__ == "__main__":
    channel.start_consuming()