# Домашнее задание к занятию «Система мониторинга Zabbix»
[smon-homeworks/hw-02.md at main · netology-code/smon-homeworks · GitHub](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md)
#zabbix 
[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%B4%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D0%B5%D0%B5-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA-%D0%B7%D0%B0%D0%BD%D1%8F%D1%82%D0%B8%D1%8E-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D0%B0-%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%D0%B0-zabbix)

В практике есть 2 основных и 1 дополнительное (со звездочкой) задания. Первые два нужно выполнять обязательно, третье - по желанию и его решение никак не повлияет на получение вами зачета по этому домашнему заданию, при этом вы сможете глубже и/или шире разобраться в материале.

Пожалуйста, присылайте на проверку всю задачу сразу. Любые вопросы по решению задач задавайте в разделе "Вопросы по заданию".

### Цели задания

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D1%86%D0%B5%D0%BB%D0%B8-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8F)

1. Научиться устанавливать Zabbix Server c веб-интерфейсом
2. Научиться устанавливать Zabbix Agent на хосты
3. Научиться устанавливать Zabbix Agent на компьютер и подключать его к серверу Zabbix

### Чеклист готовности к домашнему заданию

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D1%87%D0%B5%D0%BA%D0%BB%D0%B8%D1%81%D1%82-%D0%B3%D0%BE%D1%82%D0%BE%D0%B2%D0%BD%D0%BE%D1%81%D1%82%D0%B8-%D0%BA-%D0%B4%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D0%B5%D0%BC%D1%83-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8E)

- [ ]  Просмотрите в личном кабинете занятие "Система мониторинга Zabbix"

### Инструкция по выполнению домашнего задания

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%B8%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%86%D0%B8%D1%8F-%D0%BF%D0%BE-%D0%B2%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D1%8E-%D0%B4%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D0%B5%D0%B3%D0%BE-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8F)

1. Сделайте fork [репозитория c шаблоном решения](https://github.com/netology-code/sys-pattern-homework) к себе в Github и переименуйте его по названию или номеру занятия, например, [https://github.com/имя-вашего-репозитория/gitlab-hw](https://github.com/%D0%B8%D0%BC%D1%8F-%D0%B2%D0%B0%D1%88%D0%B5%D0%B3%D0%BE-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F/gitlab-hw) или [https://github.com/имя-вашего-репозитория/8-03-hw](https://github.com/%D0%B8%D0%BC%D1%8F-%D0%B2%D0%B0%D1%88%D0%B5%D0%B3%D0%BE-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F/8-03-hw)).
2. Выполните клонирование этого репозитория к себе на ПК с помощью команды `git clone`.
3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
    - впишите вверху название занятия и ваши фамилию и имя;
    - в каждом задании добавьте решение в требуемом виде: текст/код/скриншоты/ссылка;
    - для корректного добавления скриншотов воспользуйтесь инструкцией [«Как вставить скриншот в шаблон с решением»](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md);
    - при оформлении используйте возможности языка разметки md. Коротко об этом можно посмотреть в [инструкции по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md).
4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`).
5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
6. Любые вопросы задавайте в разделе «Вопросы по заданию» в личном кабинете.

---

### Задание 1

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-1)

Установите Zabbix Server с веб-интерфейсом.

#### Процесс выполнения

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81-%D0%B2%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F)

1. Выполняя ДЗ, сверяйтесь с процессом отражённым в записи лекции.
2. Установите PostgreSQL. Для установки достаточна та версия, что есть в системном репозитороии Debian 11.
3. Пользуясь конфигуратором команд с официального сайта, составьте набор команд для установки последней версии Zabbix с поддержкой PostgreSQL и Apache.
4. Выполните все необходимые команды для установки Zabbix Server и Zabbix Web Server.

#### Требования к результатам

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D1%82%D1%80%D0%B5%D0%B1%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F-%D0%BA-%D1%80%D0%B5%D0%B7%D1%83%D0%BB%D1%8C%D1%82%D0%B0%D1%82%D0%B0%D0%BC)

1. Прикрепите в файл README.md скриншот авторизации в админке.
2. Приложите в файл README.md текст использованных команд в GitHub.

---
### Решение задания 1
Я решил выполнять домашнее задание при помощи комбинации vagrant(windows) + ansible(wsl).
- Структура проета
```bash
tree -L 4 ~/git/Netology_labs/monitoring/zabbix/lab1 
/home/alex/git/Netology_labs/monitoring/zabbix/lab1
├── Vagrantfile            # Конфигруация ВМ на virtualbox (Windows)
├── ansible.cfg            # Конфигурация Ansible
├── ansible.log
├── inventory.ini          # Список ВМ Хостов 
├── playbook.yml           # Основной Playbook
└── roles                  # Папка с ролями
    ├── postgresql         # Установка PostgreSQL
    │   ├── tasks
    │   │   └── main.yml   # Задача на  установку PostgreSQL
    │   └── vars
    │       └── main.yml   # Переменные верия PostgreSQL
    ├── zabbix_agent       # Установка Zabbix-Agent
    │   ├── handlers
    │   │   └── main.yml
    │   └── tasks
    │       └── main.yml   # Задача на  установку Zabbix-Agent
    └── zabbix_server      # Установка Zabbix-Server
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   └── main.yml   # Задача на  установку Zabbix-Server + Настройка базы PostgreSQL
        └── vars
            └── pgsl_db.yml # Зашифрованные Переменные пользователя zabbix для СУБД PostgreSQL

11 directories, 12 files
```

- #### Вот мой Vagrantfile
```ruby
Vagrant.configure("2") do |config|

   # Образ виртуальной машины
  config.vm.box = "my-debian13" 
  # если выставлен в false, то vagrant не будет автоматически создавать и использовать собственные SSH ключи
  config.ssh.insert_key = false

  # Настройка виртальной машина Zabbix Server
  config.vm.define "zabbix-server" do |server|
   server.vm.hostname = "zabbix-server"
  # Настройка сети
  server.vm.network "public_network", ip: "192.168.88.50", bridge: "Realtek PCIe GbE Family Controller"
  # Настройка провайлдера и параметров ВМ
  server.vm.provider "virtualbox" do |vb|
    vb.name= "zabbix-server"
    vb.memory = "4096"
    vb.cpus = 4
  end
  end

  # Настройка виртальной машина Zabbix agent
  config.vm.define "zabbix_agent" do |agent|
   agent.vm.hostname = "zabbix-agent"
  # Настройка сети
  agent.vm.network "public_network", ip: "192.168.88.51", bridge: "Realtek PCIe GbE Family Controller"
  # Настройка провайлдера и параметров ВМ
  agent.vm.provider "virtualbox" do |vb|
    vb.name= "zabbix-agent"
    vb.memory = "4096"
    vb.cpus = 4
  end
  end
end

```

- Скрин развертывания ВМ
![](./scrin/vagrant_up.png)

![](./scrin/vagrant_status.png)

- #### Роль установки PostgreSQL
```yml
- name: Установка пакетов для Postgres
  apt:
    name:
      - wget
      - curl
      - postgresql-common
      - ca-certificates
      - gnupg
    state: present          # гарантирует, что пакеты будут установлены, если их нет.

- name: Создаем директорию pgdg
  file:
    path: /usr/share/postgresql-common/pgdg   # путь к директории, которую нужно создать
    state: directory                          # гарантирует, что директория будет создана, если ее нет.
    owner: root                               # владелец директории
    group: root                               # группа директории
    mode: '0755'

- name: Добавление ключа репозитория Postgres
  get_url:
    url: https://www.postgresql.org/media/keys/ACCC4CF8.asc # Адрес ключа репозитория
    dest: /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc # Путь куда будет сохранен ключ
    mode: '0644' # права доступа к файлу ключа
    owner: root
    group: root
    validate_certs: yes # проверка ssl сертификата при запуске ключа

- name:  Добавить репозиторий PGDG
  apt_repository:
    #  repo Указывает путь к скачанному ключу и url репозитория, который будет добавлен в систему
    #  {{ ansible_distribution_release }} - это переменная Ansible, которая автоматически подставляет кодовое имя текущего релиза операционной системы (например, buster для Debian 13 или focal для Ubuntu 20.04).
    repo: "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt {{ ansible_distribution_release }}-pgdg main"
    state: present
    filename: pgdg.list # имя файла, который будет создан в директории /etc/apt/sources.list.d/  для хранения информации о новом репозитории
    update_cache: yes # обновления кэша после добавления репозиторория

- name: Установка PostgresSQL
  apt:
    name: "postgresql-{{ postgresql_version }}" # установка пакета с указания версии которая указана в переменой в папке vars
    state: present
  
- name: Аатозапуск Postgresql
  service:
      name: postgresql
      state: started
      enabled: true
```

- #### Роль установки Zabbix-Server

- Tasks
```yml
   
- name: Указываем зашифрованные переменные логин и пароль от postgresql
  include_vars:                    #  указывает на конкретный файл в папке vars самой роли
    file: pgsl_db.yml
  
  
- name: Создаем директорию install
  file:
    path: /home/vagrant/install   # путь к директории, которую нужно создать
    state: directory                          # гарантирует, что директория будет создана, если ее нет.


- name: Скачиваем репозиторий с zabbix 7.4
  get_url:
    url: https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb # Адрес ключа репозитория
    dest: /home/vagrant/install/ # Путь куда будет пакет


- name: Установка репозитория
  apt:
    deb: /home/vagrant/install/zabbix-release_latest_7.4+debian13_all.deb # установка пакета с указанного пути
  register: zabbix_repo_install # Запоминаем что репозиторий был установлен.


- name: Обновление кэша пакетов после добавления репозитория
  ansible.builtin.apt:
    update_cache: yes
    cache_valid_time: 0  # Принудительно обновить, даже если кэш "свежий"
  when: zabbix_repo_install is changed  # Обновляем только если репозиторий только что установлен


- name: Установка пакетов для zabbix-server
  ansible.builtin.apt:
    name:
      - zabbix-server-pgsql
      - zabbix-frontend-php
      - php8.4-pgsql
      - zabbix-apache-conf
      - zabbix-sql-scripts
      - zabbix-agent
      - acl
      - python3-psycopg2
    state: present


- name: Включить и запустить сервисы Zabbix и Apache
  ansible.builtin.systemd:
    name: "{{ item }}"                # Специальная переменная цикла loop. Она принимает значение текущего элемента по очереди из списка
    enabled: yes
    state: started
  loop:                               # Цикл loop
    - zabbix-server
    - zabbix-agent
    - apache2


- name: Создание пользователя в PostgreSQL
  community.postgresql.postgresql_user:    # Специальный модуль для управления postgres
    name: "{{ postgres_db_user }}"         # переменная зашифрованная в pgsl_db.yml
    password: "{{ postgres_db_password }}" # переменная зашифрованная в pgsl_db.yml
    state: present
  become: true
  become_user: postgres                    # от имени какого пользователя идет повышение прав


- name: Создание базы данный в PostgreSQL
  community.postgresql.postgresql_db:      # Специальный модуль для управления postgres
    name: zabbix
    owner: zabbix
    encoding: UTF-8
    template: template0                    # Гарантирует, что база будет создана с чистой кодировкой
  become: true
  become_user: postgres                    # База создается под postgres


- name: Проверка, импортирована ли схема Zabbix
  community.postgresql.postgresql_query:
    db: zabbix
    login_user: postgres
    query: |                                           # Использует SQL запрос для провеки наличия таблицы hosts в базе zabbix.
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'hosts'
      );
  register: zabbix_schema_check                         # Сохраняет результат проверки в переменную zabbix_schema_check  для дальнейшего использоватя в условии when
  become: true
  become_user: postgres
  
  
- name: Импорт схемы и данных в базу Zabbix
  ansible.builtin.shell:                                # Не нашел подходящий модуль, по этому делают все через shell
    cmd: zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | psql zabbix
  become: true
  become_user: zabbix                                   # А тут уже через пользователя zabbix, что бы создаваемые таблицы и другие объекты принадлежали пользователю zabbix
  register: schema_import                               # Сохраняем результат в переменную schema_import, что бы понять были ли изменения
  changed_when: "'CREATE' in schema_import.stdout or 'ALTER' in schema_import.stdout" #  # Условие при котором задача будет считаться Изменившее сотояние. Если вывод содедердит слова CREATE или ALTER, то считается что данные были изменены
  when: not zabbix_schema_check.query_result[0].exists  # Условие при котором будет выполняться задача. Если в результате проверки схемы не существует таблицы hosts, то выполняетмся ипорт схемы и данных.
  notify: Перезагрузка zabbix и apache2


- name: Замена DBPassword=пароль в zabbix_server.conf
  ansible.builtin.lineinfile:
    path: /etc/zabbix/zabbix_server.conf          # Указываем расположение
    regexp: '^#\s*DBPassword=.*'                  # Ищем закомментированную строку. Строка начинается с #, затем любое количество пробелов, затем DBPassword= и любой остаток
    line: 'DBPassword={{ postgres_db_password }}' # Заменяем строку
    backrefs: yes                                 # заменять только если regex найден
    backup: yes                                   # создать резервную копию с временной меткой перед изменением
  notify: Перезагрузка zabbix и apache2   # перезапуск только при изменении
```

- handlers
```yml
---
- name: Перезагрузка zabbix и apache2
  ansible.builtin.systemd:
    name: "{{ item }}"    # Специальная переменная цикла loop. Она принимает значение текущего элемента по очереди из списка
    state: restarted
  loop:                   # Цикл loop
    - zabbix-server
    - zabbix-agent
    - apache2
```

- #### Inventory.ini
``` ini
[hosts]
zabbix-server ansible_host=192.168.88.50 ansible_user=vagrant
zabbix-agent ansible_host=192.168.88.51 ansible_user=vagrant
```

- #### Основной Playbook
```yml
---
- name: Установка PostgreSQL и zabbix-server
  hosts: zabbix-server
  become: yes
  roles:
    - postgresql
    - zabbix_server
      
- name: Установка zabbix-agent
  hosts: zabbix-agent
  become: yes
  roles:
    - zabbix_agent
```

Результат выполнения установки основного playbook
```python
❯ ansible-playbook playbook.yml --ask-vault-pass
Vault password: 

PLAY [Установка PostgreSQL и zabbix-server] *******************************************************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host zabbix-server is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix-server]

TASK [postgresql : Установка пакетов для Postgres] ************************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [postgresql : Создаем директорию pgdg] *******************************************************************************************************************************************************************************
ok: [zabbix-server]

TASK [postgresql : Добавление ключа репозитория Postgres] *****************************************************************************************************************************************************************
ok: [zabbix-server]

TASK [postgresql : Добавить репозиторий PGDG] *****************************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [postgresql : Установка PostgresSQL] *********************************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [postgresql : Аатозапуск Postgresql] *********************************************************************************************************************************************************************************
ok: [zabbix-server]

TASK [zabbix_server : Указываем зашифрованные переменные логин и пароль от postgresql] ************************************************************************************************************************************
ok: [zabbix-server]

TASK [zabbix_server : Создаем директорию install] *************************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [zabbix_server : Скачиваем репозиторий с zabbix 7.4] *****************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [zabbix_server : Установка репозитория] ******************************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [zabbix_server : Обновление кэша пакетов после добавления репозитория] ***********************************************************************************************************************************************
changed: [zabbix-server]

TASK [zabbix_server : Установка пакетов для zabbix-server] ****************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [zabbix_server : Включить и запустить сервисы Zabbix и Apache] *******************************************************************************************************************************************************
changed: [zabbix-server] => (item=zabbix-server)
ok: [zabbix-server] => (item=zabbix-agent)
ok: [zabbix-server] => (item=apache2)

TASK [zabbix_server : Создание пользователя в PostgreSQL] *****************************************************************************************************************************************************************
[WARNING]: Module remote_tmp /var/lib/postgresql/.ansible/tmp did not exist and was created with a mode of 0700, this may cause issues when running as another user. To avoid this, create the remote_tmp dir with the
correct permissions manually
changed: [zabbix-server]

TASK [zabbix_server : Создание базы данный в PostgreSQL] ******************************************************************************************************************************************************************
changed: [zabbix-server]

TASK [zabbix_server : Проверка, импортирована ли схема Zabbix] ************************************************************************************************************************************************************
ok: [zabbix-server]

TASK [zabbix_server : Импорт схемы и данных в базу Zabbix] ****************************************************************************************************************************************************************
[WARNING]: Unable to use /var/lib/zabbix/.ansible/tmp as temporary directory, failing back to system: [Errno 13] Отказано в доступе: '/var/lib/zabbix'
changed: [zabbix-server]

TASK [zabbix_server : Замена DBPassword=пароль в zabbix_server.conf] ******************************************************************************************************************************************************
changed: [zabbix-server]

RUNNING HANDLER [zabbix_server : Перезагрузка zabbix и apache2] ***********************************************************************************************************************************************************
changed: [zabbix-server] => (item=zabbix-server)
changed: [zabbix-server] => (item=zabbix-agent)
changed: [zabbix-server] => (item=apache2)

PLAY [Установка zabbix-agent] *********************************************************************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host zabbix-agent is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix-agent]

TASK [zabbix_agent : Создаем директорию install] **************************************************************************************************************************************************************************
changed: [zabbix-agent]

TASK [zabbix_agent : Скачиваем репозиторий с zabbix 7.4] ******************************************************************************************************************************************************************
changed: [zabbix-agent]

TASK [zabbix_agent : Установка репозитория] *******************************************************************************************************************************************************************************
changed: [zabbix-agent]

TASK [zabbix_agent : Установка пакетов для zabbix-server] *****************************************************************************************************************************************************************
changed: [zabbix-agent]

TASK [zabbix_agent : Включить и запустить сервисы Zabbix-Agent] ***********************************************************************************************************************************************************
ok: [zabbix-agent] => (item=zabbix-agent)

PLAY RECAP ****************************************************************************************************************************************************************************************************************
zabbix-agent               : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
zabbix-server              : ok=20   changed=14   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

- Скрины авторизации в Zabbix-Server
![](./scrin/zbbix_web1.png)

![](./scrin/zbbix_web2.png)

![](./scrin/zbbix_web3.png)

![](./scrin/zbbix_web4.png)

![](./scrin/zbbix_web5.png)

---
### Задание 2

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-2)

Установите Zabbix Agent на два хоста.

#### Процесс выполнения

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81-%D0%B2%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F-1)

1. Выполняя ДЗ, сверяйтесь с процессом отражённым в записи лекции.
2. Установите Zabbix Agent на 2 вирт.машины, одной из них может быть ваш Zabbix Server.
3. Добавьте Zabbix Server в список разрешенных серверов ваших Zabbix Agentов.
4. Добавьте Zabbix Agentов в раздел Configuration > Hosts вашего Zabbix Servera.
5. Проверьте, что в разделе Latest Data начали появляться данные с добавленных агентов.

#### Требования к результатам

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D1%82%D1%80%D0%B5%D0%B1%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F-%D0%BA-%D1%80%D0%B5%D0%B7%D1%83%D0%BB%D1%8C%D1%82%D0%B0%D1%82%D0%B0%D0%BC-1)

1. Приложите в файл README.md скриншот раздела Configuration > Hosts, где видно, что агенты подключены к серверу
2. Приложите в файл README.md скриншот лога zabbix agent, где видно, что он работает с сервером
3. Приложите в файл README.md скриншот раздела Monitoring > Latest data для обоих хостов, где видны поступающие от агентов данные.
4. Приложите в файл README.md текст использованных команд в GitHub

---

## Задание 3 со звёздочкой*

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-3-%D1%81%D0%BE-%D0%B7%D0%B2%D1%91%D0%B7%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B9)

Установите Zabbix Agent на Windows (компьютер) и подключите его к серверу Zabbix.

#### Требования к результатам

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D1%82%D1%80%D0%B5%D0%B1%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F-%D0%BA-%D1%80%D0%B5%D0%B7%D1%83%D0%BB%D1%8C%D1%82%D0%B0%D1%82%D0%B0%D0%BC-2)

1. Приложите в файл README.md скриншот раздела Latest Data, где видно свободное место на диске C:

---

## Критерии оценки

[](https://github.com/netology-code/smon-homeworks/blob/main/hw-02.md#%D0%BA%D1%80%D0%B8%D1%82%D0%B5%D1%80%D0%B8%D0%B8-%D0%BE%D1%86%D0%B5%D0%BD%D0%BA%D0%B8)

1. Выполнено минимум 2 обязательных задания
2. Прикреплены требуемые скриншоты и тексты
3. Задание оформлено в шаблоне с решением и опубликовано на GitHub