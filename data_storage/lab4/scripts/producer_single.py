import pika

from settings import URI

# params = pika.ConnectionParameters('localhost')
params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

#channel.queue_declare(queue="test_q")             # в новой версии rabbitmq  выключено по умолчанию, нужно указать durable=True
channel.queue_declare(queue="test_ershov", durable=True)
if __name__ == "__main__":

    channel.basic_publish(
        exchange="",
        routing_key="test_ershov",
        body="Hello, Ershov! - 19.05.2026",
    )
    print(" [x] Сообщение успешно отправлено в 'test_ershov'")

    # Закрываем соединение, чтобы скрипт корректно завершался
    conn.close()
