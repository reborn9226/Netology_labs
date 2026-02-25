# **Домашняя работа по GIT Ершова А.О.**
### Задание 1

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-01.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-1)

**Что нужно сделать:**

1. Зарегистрируйте аккаунт на [GitHub](https://github.com/).
2. Создайте **новый отдельный публичный репозиторий**. Обязательно поставьте галочку в поле «Initialize this repository with a README».
3. Склонируйте репозиторий, используя https протокол `git clone ...`.
4. Перейдите в каталог с клоном репозитория.
5. Произведите первоначальную настройку Git, указав своё настоящее имя и email: `git config --global user.name` и `git config --global user.email johndoe@example.com`.
6. Выполните команду `git status` и запомните результат.
7. Отредактируйте файл README.md любым удобным способом, переведя файл в состояние Modified.
8. Ещё раз выполните `git status` и продолжайте проверять вывод этой команды после каждого следующего шага.
9. Посмотрите изменения в файле README.md, выполнив команды `git diff` и `git diff --staged`.
10. Переведите файл в состояние staged или, как говорят, добавьте файл в коммит, командой `git add README.md`.
11. Ещё раз выполните команды `git diff` и `git diff --staged`.
12. Теперь можно сделать коммит `git commit -m 'First commit'`.
13. Сделайте `git push origin master`.

В качестве ответа добавьте ссылку на этот коммит в ваш md-файл с решением.

---
### Решение 1
Ссылка на первый коммит
[Firsrt commit · reborn9226/git\_neotologi@9ffd683 · GitHub](https://github.com/reborn9226/git_neotologi/commit/9ffd6835d0860eba3c6d031021487779f4967fea)


---

### Задание 2

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-01.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-2)

**Что нужно сделать:**

1. Создайте файл .gitignore (обратите внимание на точку в начале файла) и проверьте его статус сразу после создания.
2. Добавьте файл .gitignore в следующий коммит `git add...`.
3. Напишите правила в этом файле, чтобы игнорировать любые файлы `.pyc`, а также все файлы в директории `cache`.
4. Сделайте коммит и пуш.

В качестве ответа добавьте ссылку на этот коммит в ваш md-файл с решением.

---
### Решение 2
Ссылка на коммит с gitignore
[add .gitignore · reborn9226/git\_neotologi@614011e · GitHub](https://github.com/reborn9226/git_neotologi/commit/614011e1a92568e494fe6adddae7173db390725d)

---

### Задание 3

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-01.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-3)

**Что нужно сделать:**

1. Создайте новую ветку dev и переключитесь на неё.
2. Создайте в ветке dev файл test.sh с произвольным содержимым.
3. Сделайте несколько коммитов и пушей в ветку dev, имитируя активную работу над файлом в процессе разработки.
4. Переключитесь на основную ветку.
5. Добавьте файл main.sh в основной ветке с произвольным содержимым, сделайте комит и пуш . Так имитируется продолжение общекомандной разработки в основной ветке во время разработки отдельного функционала в dev ветке.
6. Сделайте мердж dev ветки в основную с помощью git merge dev. Напишите осмысленное сообщение в появившееся окно комита.
7. Сделайте пуш в основной ветке.
8. Не удаляйте ветку dev.

В качестве ответа прикрепите ссылку на граф коммитов [https://github.com/ваш-логин/ваш-репозиторий/network](https://github.com/%D0%B2%D0%B0%D1%88-%D0%BB%D0%BE%D0%B3%D0%B8%D0%BD/%D0%B2%D0%B0%D1%88-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%B9/network) в ваш md-файл с решением.

Ваш граф комитов должен выглядеть аналогично скриншоту:

[![скрин для Git](https://private-user-images.githubusercontent.com/77622076/256180841-e73589cf-7e97-40e5-ac01-d1d55376f1b9.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzE1Njg2OTIsIm5iZiI6MTc3MTU2ODM5MiwicGF0aCI6Ii83NzYyMjA3Ni8yNTYxODA4NDEtZTczNTg5Y2YtN2U5Ny00MGU1LWFjMDEtZDFkNTUzNzZmMWI5LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNjAyMjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjYwMjIwVDA2MTk1MlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTA2NGU0NWNjM2VjM2ViZDNjMTgwNzlmM2JhNmFhYjYwMWI4MzkxOWM4ODI1NjZiYjQxYzY5NjNmMDBlNGI2MTEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.T04PpO8KzppuG1eItuGbV9d-t6jVfQy_Ir6_Vb0zhCA)](https://private-user-images.githubusercontent.com/77622076/256180841-e73589cf-7e97-40e5-ac01-d1d55376f1b9.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzE1Njg2OTIsIm5iZiI6MTc3MTU2ODM5MiwicGF0aCI6Ii83NzYyMjA3Ni8yNTYxODA4NDEtZTczNTg5Y2YtN2U5Ny00MGU1LWFjMDEtZDFkNTUzNzZmMWI5LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNjAyMjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjYwMjIwVDA2MTk1MlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTA2NGU0NWNjM2VjM2ViZDNjMTgwNzlmM2JhNmFhYjYwMWI4MzkxOWM4ODI1NjZiYjQxYzY5NjNmMDBlNGI2MTEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.T04PpO8KzppuG1eItuGbV9d-t6jVfQy_Ir6_Vb0zhCA)

---
### Решение 3
Ссылка на граф коммитов
[Network Graph · reborn9226/git\_neotologi · GitHub](https://github.com/reborn9226/git_neotologi/network)


---
## Дополнительные задания* (со звёздочкой)

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-01.md#%D0%B4%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B5-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8F-%D1%81%D0%BE-%D0%B7%D0%B2%D1%91%D0%B7%D0%B4%D0%BE%D1%87%D0%BA%D0%BE%D0%B9)

Их выполнение необязательное и не влияет на получение зачёта по домашнему заданию. Можете их решить, если хотите лучше разобраться в материале.

---

### Задание 4*

[](https://github.com/netology-code/sdvps-homeworks/blob/main/8-01.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-4)

Сэмулируем конфликт. Перед выполнением изучите [документацию](https://git-scm.com/book/ru/v2/%D0%98%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D1%8B-Git-%D0%9F%D1%80%D0%BE%D0%B4%D0%B2%D0%B8%D0%BD%D1%83%D1%82%D0%BE%D0%B5-%D1%81%D0%BB%D0%B8%D1%8F%D0%BD%D0%B8%D0%B5).

**Что нужно сделать:**

1. Создайте ветку conflict и переключитесь на неё.
2. Внесите изменения в файл test.sh.
3. Сделайте коммит и пуш.
4. Переключитесь на основную ветку.
5. Измените ту же самую строчку в файле test.sh.
6. Сделайте коммит и пуш.
7. Сделайте мердж ветки conflict в основную ветку и решите конфликт так, чтобы в результате в файле оказался код из ветки conflict.

В качестве ответа на задание прикрепите ссылку на граф коммитов [https://github.com/ваш-логин/ваш-репозиторий/network](https://github.com/%D0%B2%D0%B0%D1%88-%D0%BB%D0%BE%D0%B3%D0%B8%D0%BD/%D0%B2%D0%B0%D1%88-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%B9/network) в ваш md-файл с решением.

---
### Решение 4
[Unicorn! · GitHub](https://github.com/reborn9226/git_neotologi/network)

---