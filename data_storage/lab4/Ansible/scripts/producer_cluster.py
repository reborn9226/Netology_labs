import pika

from settings import URI

# params = pika.ConnectionParameters('localhost')
params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

channel.queue_declare(queue="test_ershov", durable=True, arguments={'x-queue-type': 'quorum'} ) # В новых версиях RabbitMQ необходимо указывать quorum в коде что бы заработал HA, так как был удален механизм зеркалирования классических очередей - обьявлен устаревшим

if __name__ == "__main__":

    count = 0

    while True:
        channel.basic_publish(
            exchange="",
            routing_key="test_ershov",
            body=f"Hello, Ershov! - {count}",
        )
        print(f" [x] Сообщение {count} успешно отправлено в 'test_ershov'")
        count += 1
