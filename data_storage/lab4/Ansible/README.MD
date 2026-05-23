# Домашнее задание к занятию «Очереди RabbitMQ» Ершова А.О.



---

### Задание 1. Установка RabbitMQ

[](https://github.com/netology-code/sdb-homeworks/blob/main/11-04.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-1-%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-rabbitmq)

Используя Vagrant или VirtualBox, создайте виртуальную машину и установите RabbitMQ. Добавьте management plug-in и зайдите в веб-интерфейс.

_Итогом выполнения домашнего задания будет приложенный скриншот веб-интерфейса RabbitMQ._

---
### Решение 1
- Структура каталога
```bash
❯ tree -l
.
├── Vagrantfile
├── ansible.cfg
├── ansible.log
├── inventory.ini
├── playbook.yml
└── roles
    └── rabbitmq
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   └── main.yml
        └── vars
            └── main.yml # логин и пароль для внешнего подлкючения к веб интерфейсу

5 directories, 8 files
```

- vagrantfile, создает вириальную машину пробрасывает туда два публичных ключа windows и  wsl машины, и создает inventory.ini
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "my-debian13"
  config.ssh.insert_key = false
  win_key_path = "C:/Users/ersho/.ssh/id_ed25519.pub"
  wsl_key_path = "//wsl.localhost/Ubuntu-22.04/home/alex/.ssh/id_ed25519.pub"
  config.vm.define "RabbitMQ-host1" do |h1|
    vm_hostname = "RabbitMQ-host1"
    vm_ip = "192.168.88.10"
    h1.vm.hostname = vm_hostname
    h1.vm.network "public_network", ip: vm_ip, bridge: "Realtek PCIe GbE Family Controller"
    h1.vm.provider "virtualbox" do |vb|
      vb.name   = "RabbitMQ-host1"
      vb.memory = "2048"
      vb.cpus   = 2
    end
    # 1. Проброс SSH ключей
    [win_key_path, wsl_key_path].each do |path|
      if File.exist?(path)
        key = File.read(path).strip
        h1.vm.provision "shell", inline: <<-SHELL
          mkdir -p /home/vagrant/.ssh
          if ! grep -q "#{key}" /home/vagrant/.ssh/authorized_keys; then
            echo "#{key}" >> /home/vagrant/.ssh/authorized_keys
            echo "SSH key from #{path} added."
          fi
          chown -R vagrant:vagrant /home/vagrant/.ssh
          chmod 700 /home/vagrant/.ssh
          chmod 600 /home/vagrant/.ssh/authorized_keys
        SHELL
      else
        puts "--- WARNING: Key file not found at #{path} ---"
      end
    end

    # 2. Создание inventory.ini
    h1.trigger.after [:up, :reload] do |trigger|
      trigger.info = "Writing inventory.ini..."
      trigger.ruby do |env, machine|
        inventory_content = "[all]\n#{vm_hostname} ansible_host=#{vm_ip} ansible_user=vagrant\n"
        File.write("inventory.ini", inventory_content)
      end
    end
  end
end
```

- ansible roles rabbitmq , я решил изначально попробовать поднять все через [[Ansible]]
```yml
---
- name: Устанока зависимостей для RabbitMQ
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes
  loop:
    - curl
    - gnupg
    - apt-transport-https

- name: Подготовка RabbitMQ GPG key
  block:
    - name: Скачиваем временный ASCII ключ
      ansible.builtin.get_url:
        url: "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA"
        dest: /tmp/rabbitmq-key.asc
        mode: '0644'

    - name: Деарморинг ключа (превращаем в .gpg формат)
      ansible.builtin.shell:
        cmd: gpg --dearmor < /tmp/rabbitmq-key.asc > /usr/share/keyrings/com.rabbitmq.team.gpg
        creates: /usr/share/keyrings/com.rabbitmq.team.gpg
     

    - name: Удаляем временный файл
      ansible.builtin.file:
        path: /tmp/rabbitmq-key.asc
        state: absent


- name: Добавляем репозиторий RabbitMQ
  copy:
    dest: /etc/apt/sources.list.d/rabbitmq.list
    content: |
      deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/debian/trixie trixie main
      deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/debian/trixie trixie main
    owner: root
    group: root
    mode: '0644'


- name: Установка зависимостей из репозитория +  RabbitMQ
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes
  loop:
    - erlang-base
    - erlang-asn1
    - erlang-crypto
    - erlang-eldap
    - erlang-ftp
    - erlang-inets
    - erlang-mnesia
    - erlang-os-mon
    - erlang-parsetools
    - erlang-public-key
    - erlang-runtime-tools
    - erlang-snmp
    - erlang-ssl
    - erlang-syntax-tools
    - erlang-tftp
    - erlang-tools
    - erlang-xmerl
    - rabbitmq-server


- name: Включаем и запускаем сервис RabbitMQ
  systemd:
    name: rabbitmq-server
    enabled: yes
    state: started

- name: Соберем данные о службах
  service_facts:

- name: Выводим статус службы RabbitMQ
  debug:
    msg: "Статус службы RabbitMQ: {{ services['rabbitmq-server'].state }}"


- name: Активируем плагин rabbitmq_management (Web Интерфейс)
  community.rabbitmq.rabbitmq_plugin:                        # Специальный модуль для управления плагинами RabbitMQ
    names: rabbitmq_management
    state: enabled
  notify: Restart RabbitMQ


- name: Создаем пользователя-администратора для удаленного входа
  community.rabbitmq.rabbitmq_user:                           # Специальный модуль для управления пользователями RabbitMQ
    user: "{{ user }}"                                        # Имя пользователя, переданное через переменную
    password: "{{ password }}"                                # Пароль для пользователя, переданный через переменную
    tags: administrator                                       # Назначение роли пользователя (администратор) чере тег
    vhost: /                                                  # Виртуальный хост, к которому будет привязан пользователь
    configure_priv: .*                                        # Разрешаем пользователю настраивать все ресурсы
    read_priv: .*                                            
    write_priv: .*
    state: present
```

- Основной playbook
```yml
---
- name: Установка RabbitMQ
  hosts: all
  become: true
  roles:
    - rabbitmq
```

- Скрин веб интерфейса

![](.scrin/1.png)

---
### Задание 2. Отправка и получение сообщений

[](https://github.com/netology-code/sdb-homeworks/blob/main/11-04.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-2-%D0%BE%D1%82%D0%BF%D1%80%D0%B0%D0%B2%D0%BA%D0%B0-%D0%B8-%D0%BF%D0%BE%D0%BB%D1%83%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D1%81%D0%BE%D0%BE%D0%B1%D1%89%D0%B5%D0%BD%D0%B8%D0%B9)

Используя приложенные скрипты, проведите тестовую отправку и получение сообщения. Для отправки сообщений необходимо запустить скрипт producer.py.

Для работы скриптов вам необходимо установить Python версии 3 и библиотеку Pika. Также в скриптах нужно указать IP-адрес машины, на которой запущен RabbitMQ, заменив localhost на нужный IP.

```shell
$ pip install pika
```

Зайдите в веб-интерфейс, найдите очередь под названием hello и сделайте скриншот. После чего запустите второй скрипт consumer.py и сделайте скриншот результата выполнения скрипта

_В качестве решения домашнего задания приложите оба скриншота, сделанных на этапе выполнения._

Для закрепления материала можете попробовать модифицировать скрипты, чтобы поменять название очереди и отправляемое сообщение.

---
### Решение 2
- структура каталога
```bash
❯ tree -l
.
├── Vagrantfile
├── ansible.cfg
├── ansible.log
├── inventory.ini
├── playbook.yml
├── roles
│   ├── pika                # Уставновка pip pika
│   │   └── tasks
│   │       └── main.yml
│   └── rabbitmq
│       ├── handlers
│       │   └── main.yml
│       ├── tasks
│       │   └── main.yml
│       └── vars
│           └── main.yml
└── scripts
    ├── consumer.py
    ├── producer_single.py
    └── settings.py

8 directories, 12 files
```

- Роль pika
```yml
---
- name: Установка системного pip3
  apt:
    name: python3-pip
    state: present
    update_cache: yes


- name: Установка pika через pip
  pip:
    name: pika
    state: present
    executable: pip3
    extra_args: --break-system-packages  # Необходимо для современных версий Debian для обхода защиты Debian (PEP 668). Намучался пока не нашел информацию на форуме.

- name: Создаем директорию для скриптов
  file:
    path: /home/vagrant/scripts
    state: directory
    owner: vagrant
    group: vagrant
    mode: '0755'

- name: Копируем скрипт producer_single.py На сервер
  copy:
    src: ./scripts/producer_single.py
    dest: /home/vagrant/scripts/producer_single.py
    owner: vagrant
    group: vagrant
    mode: '0755'

- name: Копируем скрипт consumer.py На сервер
  copy:
    src: ./scripts/consumer.py
    dest: /home/vagrant/scripts/consumer.py
    owner: vagrant
    group: vagrant
    mode: '0755'

- name: Копируем скрипт settings.py На сервер
  copy:
    src: ./scripts/settings.py
    dest: /home/vagrant/scripts/settings.py
    owner: vagrant
    group: vagrant
    mode: '0755'
```

- consumer.py
```python
import pika
import time

from settings import URI

params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

channel.queue_declare(queue="test_ershov", durable=True)

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

if __name__ == "__main__":
    channel.start_consuming()
```

- producer_single.py
```python
import pika

from settings import URI

# params = pika.ConnectionParameters('localhost')
params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

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
```

- settings.py
```python
URI = 'amqp://admin:admin@192.168.88.10:5672/'
```

---
### Задание 3. Подготовка HA кластера

[](https://github.com/netology-code/sdb-homeworks/blob/main/11-04.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-3-%D0%BF%D0%BE%D0%B4%D0%B3%D0%BE%D1%82%D0%BE%D0%B2%D0%BA%D0%B0-ha-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0)

Используя Vagrant или VirtualBox, создайте вторую виртуальную машину и установите RabbitMQ. Добавьте в файл hosts название и IP-адрес каждой машины, чтобы машины могли видеть друг друга по имени.

Пример содержимого hosts файла:

```shell
$ cat /etc/hosts
192.168.0.10 rmq01
192.168.0.11 rmq02
```

После этого ваши машины могут пинговаться по имени.

Затем объедините две машины в кластер и создайте политику ha-all на все очереди.

_В качестве решения домашнего задания приложите скриншоты из веб-интерфейса с информацией о доступных нодах в кластере и включённой политикой._

Также приложите вывод команды с двух нод:

```shell
$ rabbitmqctl cluster_status
```

Для закрепления материала снова запустите скрипт producer.py и приложите скриншот выполнения команды на каждой из нод:

```shell
$ rabbitmqadmin get queue='hello'
```

После чего попробуйте отключить одну из нод, желательно ту, к которой подключались из скрипта, затем поправьте параметры подключения в скрипте consumer.py на вторую ноду и запустите его.

_Приложите скриншот результата работы второго скрипта._

---
## Решение 3
 - структура каталога
```bash
 ❯ tree -l                                                                                                                                                                1 ⚙
.
├── Vagrantfile
├── ansible.cfg
├── ansible.log
├── inventory.ini
├── playbook.yml
├── roles
│   ├── pika
│   │   └── tasks
│   │       └── main.yml
│   ├── rabbitmq
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main.yml
│   └── rabbitmq_cluster                # Роль для обьединение двух нод в кластер
│       └── tasks
│           ├── main.yml
│           ├── master_cookie.yml
│           └── worker.yml
└── scripts
    ├── consumer.py
    ├── producer_cluster.py             # Скрипт для каластера
    ├── producer_single.py
    └── settings.py

10 directories, 16 files
```

- Добавление hostname  в /etc/hosts я выполнил при помощи vagrantfile
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "my-debian13"
  config.ssh.insert_key = false

  win_key_path = "C:/Users/ersho/.ssh/id_ed25519.pub"
  wsl_key_path = "//wsl.localhost/Ubuntu-22.04/home/alex/.ssh/id_ed25519.pub"

  # Описываем конфигурацию хостов в виде массива, чтобы использовать её и для создания машин, и для настройки /etc/hosts
  hosts = [
    { name: "RabbitMQ-host1", ip: "192.168.88.10" },
    { name: "RabbitMQ-host2", ip: "192.168.88.20" }
  ]

  # Основной цикл создания и настройки машин
  hosts.each do |host|
    config.vm.define host[:name] do |node|
      node.vm.hostname = host[:name]
      node.vm.network "public_network", ip: host[:ip], bridge: "Realtek PCIe GbE Family Controller"

      node.vm.provider "virtualbox" do |vb|
        vb.name   = host[:name]
        vb.memory = "2048"
        vb.cpus   = 2
      end

      # 1. Проброс SSH ключей
      [win_key_path, wsl_key_path].each do |path|
        if File.exist?(path)
          key = File.read(path).strip
          node.vm.provision "shell", inline: <<-SHELL
            mkdir -p /home/vagrant/.ssh
            if ! grep -q "#{key}" /home/vagrant/.ssh/authorized_keys; then
              echo "#{key}" >> /home/vagrant/.ssh/authorized_keys
              echo "SSH key from #{path} added to #{host[:name]}."
            fi
            chown -R vagrant:vagrant /home/vagrant/.ssh
            chmod 700 /home/vagrant/.ssh
            chmod 600 /home/vagrant/.ssh/authorized_keys
          SHELL
        else
          puts "--- WARNING: Key file not found at #{path} ---"
        end
      end



      # 2. Настройка /etc/hosts на каждой машине для всех остальных хостов

      hosts.each do |target_host|
        node.vm.provision "shell", inline: <<-SHELL
          if ! grep -q "#{target_host[:name]}" /etc/hosts; then
            echo "#{target_host[:ip]} #{target_host[:name]}" | sudo tee -a /etc/hosts
            echo "Added #{target_host[:name]} to /etc/hosts on #{host[:name]}"
          fi
        SHELL
      end
    end
  end
  # 3. Создание общего inventory.ini для Ansible
  config.trigger.after [:up, :reload] do |trigger|
    trigger.info = "Writing combined inventory.ini..."
    trigger.ruby do |env, machine|
      inventory_content = "[all]\n"
      hosts.each do |host|
        inventory_content += "#{host[:name]} ansible_host=#{host[:ip]} ansible_user=vagrant\n"
      end
      File.write("inventory.ini", inventory_content)
    end
  end
end

```

- inventory
```ini
[master]
RabbitMQ-host1 ansible_host=192.168.88.10 ansible_user=vagrant

[worker]
RabbitMQ-host2 ansible_host=192.168.88.20 ansible_user=vagrant
```

- Роль rabbitmq_cluster. Я долго думал как это правильно реализовать, подсмотрел в какой то из статей что можно в основном main.yml указать какие .yml будут использоваться и решил это попробовать. Возможно было проще это реализовать в одном, но так как я учусь, а этот репозиторий для меня будет как эталонный, почему бы не пойти немного другим путем?)
- main..yml
```yml
---
- name: Сбор cookie с мастера
  include_tasks: master_cookie.yml
  when: inventory_hostname in groups['master']

- name: Настройка worker нод и обьединение в кластер
  include_tasks: worker.yml
  when: inventory_hostname in groups['worker']
```

- master_cookie.yml
```yml
 ---
- name: Чтение .erlang.cookie с мастера
  slurp:
    src: /var/lib/rabbitmq/.erlang.cookie
  register: master_cookie_res                 # Сохраняем результат в переменную

- name: Расшариваем cookie на все worker ноды в рамках текущей сессии
  set_fact:
    rabbitmq_master_cookie: "{{ master_cookie_res['content'] | b64decode }}" # Декодируем содержимое cookie из base64
  delegate_to: localhost                                       # Выполняем на локальной машине, так как cookie нужно передать на worker ноды
  delegate_facts: true                                         # Разрешаем сохранять факты, чтобы они были доступны на всех нодах
```

- worker.yml - тут вообще застрял на долго, не понимал почему не работает что не так, оказалось что в новых версиях RabbitMQ Удалили поддержку HA в Кластических очередях в место него используют  Очередь quorum в которой HA режим включен по умолчанию. Эта очередь прописывается в коде, из за этого пришлось в скрипты добавить аргументы
```yml
- name: Проверим, что cookie с мастера успешно получен
  assert:
    that:
      - hostvars['localhost']['rabbitmq_master_cookie'] is defined
    fail_msg: "Cookie мастера не были получены. Проверь инвентарь и доступность мастер-ноды."


- name: Остановка службы RabbitMQ на worker ноде перед изменением cookie
  systemd:
    name: rabbitmq-server
    state: stopped


- name: Копирование cookie с мастера на worker Ноду с правами 400
  copy:
    content: "{{ hostvars['localhost']['rabbitmq_master_cookie'] }}"
    dest: /var/lib/rabbitmq/.erlang.cookie
    owner: rabbitmq
    group: rabbitmq
    mode: '0400'

- name: Запуск службы RabbitMQ на worker после изменения cookie
  systemd:
    name: rabbitmq-server
    state: started

- name: Остановка приложения внутри RabbitMQ на worker для кластеризации
  command: rabbitmqctl stop_app

- name: Сброс состояния ноды для корректного присоединения к кластеру
  command: rabbitmqctl reset


- name: Присоединение worker к кластеру
  command: "rabbitmqctl join_cluster rabbit@{{ hostvars[groups['master'][0]]['ansible_hostname'] }}"

- name: Запуск приложения внутри RabbitMQ на worker после присоединения к кластеру
  command: rabbitmqctl start_app

# Не работает в новых версиях RabbitMQ, так как был удален механизм зеркалирования классических очередей - обьявлен устаревшим, теперь нужно использовать quorum очереди, которые синхронизируются между нodами по умолчанию, без необходимости настройки политики HA

# - name: Подключение HA policy для синхронизации очередей между нodами
#   command: rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"all","ha-sync-mode":"automatic"}'
#   run_once: true                               # Выполнить только 1 раз
#   changed_when: false                          # Что бы не читал изменения

```

- playbook.yml
```yml
---
- name: Установка RabbitMQ
  hosts: all
  become: true
  roles:
    - rabbitmq

- name: Установка pika и копирования скриптов на сервер
  hosts: all
  become: true
  roles:
    - pika

- name: Сборка и присоединение кластера RabbitMQ
  hosts: all
  become: true
  roles:
    - rabbitmq_cluster
```

- На серверах создается папка scripts и в ней изменённые скрипты
- producer_cluster.py
```python
import pika
from settings import URI
# params = pika.ConnectionParameters('localhost')
params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()

# В новых версиях RabbitMQ необходимо указывать quorum в коде что бы заработал HA, так как был удален механизм зеркалирования классических очередей - обьявлен устаревшим
channel.queue_declare(queue="test_ershov", durable=True, arguments={'x-queue-type': 'quorum'} )

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
```

- consumer.py
```python
import pika
import time

from settings import URI


params = pika.URLParameters(URI)
conn = pika.BlockingConnection(params)
channel = conn.channel()
# В новых версиях RabbitMQ необходимо указывать quorum в коде что бы заработал HA, так как был удален механизм зеркалирования классических очередей - обьявлен устаревшим
channel.queue_declare(queue="test_ershov", durable=True, arguments={'x-queue-type': 'quorum'} )


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
```

- Скрины результата
Объединённые в кластер

![](.scrin/3_1.png)

- Запуск producer_cluster.py

![](.scrin/3_producer.png)

![](.scrin/3_producer2.png)


- Запуск consumer.py

![](.scrin/3_consumer.png)

![](.scrin/3_consumer2.png)


---
## Дополнительные задания (со звёздочкой*)

[](https://github.com/netology-code/sdb-homeworks/blob/main/11-04.md#%D0%B4%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B5-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8F-%D1%81%D0%BE-%D0%B7%D0%B2%D1%91%D0%B7%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B9)

Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### * Задание 4. Ansible playbook

[](https://github.com/netology-code/sdb-homeworks/blob/main/11-04.md#-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-4-ansible-playbook)

Напишите плейбук, который будет производить установку RabbitMQ на любое количество нод и объединять их в кластер. При этом будет автоматически создавать политику ha-all.

_Готовый плейбук разместите в своём репозитории._

---
Вся домашняя работа выполнена была через Ansible