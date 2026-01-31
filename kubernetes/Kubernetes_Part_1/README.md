# Домашнее задание к занятию «Kubernetes. Часть 1» Ершова А.О.
### Задание 1

**Выполните действия:**

1. Запустите Kubernetes локально, используя k3s или minikube на свой выбор.
2. Добейтесь стабильной работы всех системных контейнеров.

### Решение 1
```
k get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS       AGE
kube-system   coredns-7f496c8d7d-gbxcw                  1/1     Running     17 (88m ago)   2d8h
kube-system   helm-install-traefik-crd-rwsz5            0/1     Completed   1              2d8h
kube-system   helm-install-traefik-khg45                0/1     Completed   1              2d8h
kube-system   local-path-provisioner-578895bd58-m8vgp   1/1     Running     18 (88m ago)   2d8h
kube-system   metrics-server-7b9c9c4b9c-b9kxn           1/1     Running     19 (88m ago)   2d8h
kube-system   svclb-nginx-service-e95c40b9-wkk2q        0/1     Pending     0              46h
kube-system   svclb-traefik-e322994f-lc6fj              2/2     Running     32 (88m ago)   2d8h
kube-system   traefik-6f5f87584-z57ps                   1/1     Running     16 (88m ago)   2d8h
```
### Задание 2

Есть файл с деплоем:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: master
        image: bitnami/redis
        env:
         - name: REDIS_PASSWORD
           value: password123
        ports:
        - containerPort: 6379
```

**Выполните действия:**

1. Измените файл с учётом условий:

- redis должен запускаться без пароля;
- создайте Service, который будет направлять трафик на этот Deployment;
- версия образа redis должна быть зафиксирована на 6.0.13.

1. Запустите Deployment в своём кластере и добейтесь его стабильной работы.

### Решение 2
Я создал манифест,  указал в нем версию образа redis:6.0. 13. Создал secret, и в манифесте указал в env параметры переменной окружения для подстановки пароля. Создал сервис балансировщик для перенаправление трафика во внутрь контейнера. Но он выдавал случайный внешний порт. Хотелось бы что бы из вне был доступен тот же порт что и внутри контейнера.

### Задание 3



**Выполните действия:**

1. Напишите команды kubectl для контейнера из предыдущего задания:

- выполнения команды ps aux внутри контейнера;
- просмотра логов контейнера за последние 5 минут;
- удаления контейнера;
- проброса порта локальной машины в контейнер для отладки.


### Решение 3
1.Напишите команды kubectl для контейнера из предыдущего задания:
- Создал secret
```bash
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k create secret generic redis-secret --from-literal=password=password123
secret/redis-secret created

 alex  de13  ~/git/Netology_labs/kubernetes
❯ k get secret redis-secret
NAME           TYPE     DATA   AGE
redis-secret   Opaque   1      53m

```

- Указал параметры переменной окружения в redis. yaml и применил
```
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k apply -f ~/git/Netology_labs/kubernetes/kuber1/redis.yaml
deployment.apps/redis-deployment configured
```

- Под запустился
```
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k get pod
NAME                               READY   STATUS    RESTARTS   AGE
redis-deployment-c6bdb9788-8n7vt   1/1     Running   0          9s
```

- Внутри контейнера проверил переменную
```
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k exec -it redis-deployment-c6bdb9788-8n7vt -- bash
root@redis-deployment-c6bdb9788-8n7vt:/data# echo $REDIS_PASSWORD
password123
root@redis-deployment-c6bdb9788-8n7vt:/data# exit
exit
```

- Создал сервис redis-service для перенаправление из вне внутрь контейнера
```
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k expose deployment redis-deployment --type=LoadBalancer --name=redis-service
service/redis-service exposed

 alex  de13  ~/git/Netology_labs/kubernetes
❯ k get services

NAME            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
kubernetes      ClusterIP      10.43.0.1      <none>          443/TCP          47h
redis-service   LoadBalancer   10.43.237.40   192.168.88.12   6379:31566/TCP   32s
```

2. Выполнения команды ps aux внутри контейнера.
- У нас контейнер версии redis 6.0. 13, собран на slim версия=и дистрибутива debian 12, выполнить команду ps aux не получится, так как она вырезана из дистрибутива ОС. Добавляем репозиторий для обновления и инстала и устанавливаем пакет procps и у нас появляется доступ к командам ps
```bash
❯ k exec -it redis-deployment-c6bdb9788-8n7vt -- bash
root@redis-deployment-c6bdb9788-8n7vt:/data# ps
bash: ps: command not found
root@redis-deployment-c6bdb9788-8n7vt:/data# uname -a
Linux redis-deployment-c6bdb9788-8n7vt 6.12.63+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.63-1 (2025-12-30) x86_64 GNU/Linux
root@redis-deployment-c6bdb9788-8n7vt:/data# sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list
root@redis-deployment-c6bdb9788-8n7vt:/data# sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list
root@redis-deployment-c6bdb9788-8n7vt:/data# sed -i '/stretch-updates/d' /etc/apt/sources.list
root@redis-deployment-c6bdb9788-8n7vt:/data# apt update -o Acquire::Check-Valid-Until=false
root@redis-deployment-c6bdb9788-8n7vt:/data# apt install -y procps
root@redis-deployment-c6bdb9788-8n7vt:/data# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
redis          1  0.0  0.2  52820 11368 ?        Ssl  18:14   0:05 redis-server *:6379
root          50  0.0  0.0   3872  3180 pts/0    Ss   19:19   0:00 bash
root         404  0.0  0.0   7644  2796 pts/0    R+   19:50   0:00 ps aux


```

3. просмотра логов контейнера за последние 5 минут
- При использовании флага --since=5 m ничего не происходит. Так как в контейнере стоит другое время отличное от моего хоста. Выполняя без этого флага я как раз вижу все логи, они вели запись примерно в течении 5, 5 минут после запуска.
```bash
 alex  de13  ~/git/Netology_labs/kubernetes
❯ kubectl logs redis-deployment-c6bdb9788-8n7vt --since=5m

 alex  de13  ~/git/Netology_labs/kubernetes
❯ kubectl logs redis-deployment-c6bdb9788-8n7vt
1:C 31 Jan 2026 18:14:36.131 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 31 Jan 2026 18:14:36.131 # Redis version=6.0.13, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 31 Jan 2026 18:14:36.131 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
1:M 31 Jan 2026 18:14:36.132 * Running mode=standalone, port=6379.
1:M 31 Jan 2026 18:14:36.132 # Server initialized
1:M 31 Jan 2026 18:14:36.132 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo madvise > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled (set to 'madvise' or 'never').
1:M 31 Jan 2026 18:14:36.132 * Ready to accept connections
1:M 31 Jan 2026 18:35:11.674 # Possible SECURITY ATTACK detected. It looks like somebody is sending POST or Host: commands to Redis. This is likely due to an attacker attempting to use Cross Protocol Scripting to compromise your Redis instance. Connection aborted.
```

4. удаления контейнера
- Я удалил под, но он "воскрес", точнее создался заново так как у нас в манифесте указано replicas: 1 и он будет его постоянно восстанавливать.
```bash
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k delete pod redis-deployment-c6bdb9788-8n7vt
pod "redis-deployment-c6bdb9788-8n7vt" deleted from default namespace

 alex  de13  ~/git/Netology_labs/kubernetes
❯ k get pods
NAME                               READY   STATUS    RESTARTS   AGE
redis-deployment-c6bdb9788-l54rx   1/1     Running   0          13s
```

5. проброса порта локальной машины в контейнер для отладки
Для проброса порта использовал port-forward и указал имя уже нового контейнера(пода)
```bash
 alex  de13  ~/git/Netology_labs/kubernetes
❯ k port-forward pod/redis-deployment-c6bdb9788-l54rx 6379:6379                                                                                                                                                                        1 ⨯
Forwarding from 127.0.0.1:6379 -> 6379
Forwarding from [::1]:6379 -> 6379

```
### Задание 4

Есть конфигурация nginx:

```
location / {
    add_header Content-Type text/plain;
    return 200 'Hello from k8s';
}
```

**Выполните действия:**

Напишите yaml-файлы для развёртки nginx, в которых будут присутствовать:

- ConfigMap с конфигом nginx;
- Deployment, который бы подключал этот configmap;
- Ingress, который будет направлять запросы по префиксу /test на наш сервис.

---
### Решение 4
Я создал 3 новых файла: nginx. yaml (основной конфиг), nginx-config. yaml(сконфигом исходных данных) и ingress. yaml для перенаправления запросов
- nginx. yaml
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d/
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config
```

- nginx-config. yaml
```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  default.conf: |
    server {
        listen 80;
        server_name localhost;

        location / {

            add_header Content-Type text/plain;
            return 200 'Hello from k8s';
        }
    }

```

- ingress.yaml
```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - http:
      paths:
      - path: /test
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

- Проверяем через curl
```bash
 alex  de13  ~/git/Netology_labs/kubernetes/kuber1
❯ curl localhost/test
Hello from k8s
```