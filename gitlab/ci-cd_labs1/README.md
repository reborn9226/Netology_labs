# Домашняя работа Ершова А.О. Gitlab

### Задание 1

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-03.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-1)

**Что нужно сделать:**

1. Разверните GitLab локально, используя Vagrantfile и инструкцию, описанные в [этом репозитории](https://github.com/netology-code/sdvps-materials/tree/main/gitlab).
2. Создайте новый проект и пустой репозиторий в нём.
3. Зарегистрируйте gitlab-runner для этого проекта и запустите его в режиме Docker. Раннер можно регистрировать и запускать на той же виртуальной машине, на которой запущен GitLab.

В качестве ответа в репозиторий шаблона с решением добавьте скриншоты с настройками раннера в проекте.

---
### Решение 1
- Я локально развернул gitlab и docker на debian 13. (через vpn, в Крыму не качает)
```bash
sudo  apt update
# install docker & docker-compose
sudo apt-get install -y docker.io docker-compose
# install gitlab: https://about.gitlab.com/install/#debian
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://gitlab.localdomain" apt-get install gitlab-ee
# В hosts указал gitlab.localdomain
echo "192.168.88.46     gitlab.localdomain    gitlab" | sudo tee -a /etc/hosts
echo "127.0.1.1     gitlab.localdomain    gitlab" | sudo tee -a /etc/hosts
# получил сгенерированый пароль по пути
sudo cat /etc/gitlab/initial_root_password
```


 - Использовал для входа с генерированый
- Зашел в настройки cicd и создал runner
![](. scrin/create_runner_gitlab.png)
- Так же в докер зарегистрировал runner. Указал адрес репозитория  и токен
```bash
   docker run -ti --rm --name gitlab-ershov-runner \
     --network host \
     -v /srv/gitlab-runner/config:/etc/gitlab-runner \ # проброс локальной папки с конфигом раннера
     -v /var/run/docker.sock:/var/run/docker.sock \    # проброс лольного docker в контейнер для управление им из контейнера
     gitlab/gitlab-runner:latest register
```

![](. scrin/runner-docker.png)

- Редактируем конфигурацию ранера и указываем в нем проброс локального [[docker]]
```bash
 sudo nano /srv/gitlab-runner/config/config.toml
```

![](. scrin/runner-docker.png)

- Запускаем ранер
```bash
 alex  debian-vagrant  ~/gitlab/ci-cd_labs_gitlab_ershov (main)
❯    docker run -d --name gitlab-ershov-runner --restart always \
     --network host \
     -v /srv/gitlab-runner/config:/etc/gitlab-runner \
     -v /var/run/docker.sock:/var/run/docker.sock \
     gitlab/gitlab-runner:latest
```

- Запущенный ранер в gitlab
![](. scrin/runner-done.png)
### Задание 2

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-03.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-2)

**Что нужно сделать:**

1. Запушьте [репозиторий](https://github.com/netology-code/sdvps-materials/tree/main/gitlab) на GitLab, изменив origin. Это изучалось на занятии по Git.
2. Создайте .gitlab-ci.yml, описав в нём все необходимые, на ваш взгляд, этапы.

В качестве ответа в шаблон с решением добавьте:

- файл gitlab-ci.yml для своего проекта или вставьте код в соответствующее поле в шаблоне;
- скриншоты с успешно собранными сборками.

---

### Решение 2
- мой .**gitlab-ci.yml**
```bash
stages:
  - test
  - build
test:
  stage: test
  image: golang:1.17
  script:
   - go test .
   - ls -Fla
  tags:
    - ershov_labs

build:
  stage: build
  image: docker:latest
  script:
   - docker build .
  tags:
    - ershov_labs
```

- Выполнен тест и сборка

![](. scrin/ci1.png)


![](. scrin/ci2.png)

## Дополнительные задания* (со звёздочкой)

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-03.md#%D0%B4%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B5-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8F-%D1%81%D0%BE-%D0%B7%D0%B2%D1%91%D0%B7%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B9)

Их выполнение необязательное и не влияет на получение зачёта по домашнему заданию. Можете их решить, если хотите лучше разобраться в материале.

---

### Задание 3*

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-03.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-3)

Измените CI так, чтобы:

- этап сборки запускался сразу, не дожидаясь результатов тестов;
- тесты запускались только при изменении файлов с расширением *.go.

В качестве ответа добавьте в шаблон с решением файл gitlab-ci. yml своего проекта или вставьте код в соответсвующее поле в шаблоне.