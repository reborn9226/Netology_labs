# Домашнее задание к занятию «Защита сети» Ершова А.О.

---
### Подготовка к выполнению заданий

[](https://github.com/netology-code/sdb-homeworks/blob/main/13-03.md#%D0%BF%D0%BE%D0%B4%D0%B3%D0%BE%D1%82%D0%BE%D0%B2%D0%BA%D0%B0-%D0%BA-%D0%B2%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D1%8E-%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B9)

1. Подготовка защищаемой системы:

- установите **Suricata**,
- установите **Fail2Ban**.

2. Подготовка системы злоумышленника: установите **nmap** и **thc-hydra** либо скачайте и установите **Kali linux**.

Обе системы должны находится в одной подсети.

---

### Задание 1

[](https://github.com/netology-code/sdb-homeworks/blob/main/13-03.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-1)

Проведите разведку системы и определите, какие сетевые службы запущены на защищаемой системе:

**sudo nmap -sA < ip-адрес >**

**sudo nmap -sT < ip-адрес >**

**sudo nmap -sS < ip-адрес >**

**sudo nmap -sV < ip-адрес >**

По желанию можете поэкспериментировать с опциями: [https://nmap.org/man/ru/man-briefoptions.html](https://nmap.org/man/ru/man-briefoptions.html).

_В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат._

---
### Решение 1
В локальной сети две машины: Атакующая Kali 192.168.88.116 и Защищаемая Debian 192.168.88.10

1. По очереди проводил сканирование уязвимостей через nmap
**sudo nmap -sA 192.168.88.10**

**sudo nmap -sT 192.168.88.10**

**sudo nmap -sS 192.168.88.10**

**sudo nmap -sV 192.168.88.10**

- Результат вывода логов утилиты Suricata
```bash
 vagrant  host  ~
❯ sudo tail -f /var/log/suricata/fast.log
07/12/2026-20:53:48.603481  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38910 -> 192.168.88.10:3000
07/12/2026-20:53:48.653935  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43160 -> 192.168.88.10:9090
07/12/2026-20:53:48.653935  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43160 -> 192.168.88.10:9090
07/12/2026-20:53:48.653874  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38912 -> 192.168.88.10:3000
07/12/2026-20:53:48.653874  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38912 -> 192.168.88.10:3000
07/12/2026-20:53:48.761823  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38926 -> 192.168.88.10:3000
07/12/2026-20:53:48.761823  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38926 -> 192.168.88.10:3000
07/12/2026-20:53:48.810264  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38936 -> 192.168.88.10:3000
07/12/2026-20:53:48.810264  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:38936 -> 192.168.88.10:3000
07/12/2026-20:54:29.576991  [**] [1:2221010:1] SURICATA HTTP unable to match response to request [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.10:9090 -> 192.168.88.116:40310
07/13/2026-00:31:54.122333  [**] [1:2010937:3] ET SCAN Suspicious inbound to mySQL port 3306 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:46418 -> 192.168.88.10:3306
07/13/2026-00:31:54.123791  [**] [1:2010936:3] ET SCAN Suspicious inbound to Oracle SQL port 1521 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:36236 -> 192.168.88.10:1521
07/13/2026-00:31:54.129783  [**] [1:2002910:6] ET SCAN Potential VNC Scan 5800-5820 [**] [Classification: Attempted Information Leak] [Priority: 2] {TCP} 192.168.88.116:39716 -> 192.168.88.10:5801
07/13/2026-00:31:54.133191  [**] [1:2010939:3] ET SCAN Suspicious inbound to PostgreSQL port 5432 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:58818 -> 192.168.88.10:5432
07/13/2026-00:31:54.138293  [**] [1:2010935:3] ET SCAN Suspicious inbound to MSSQL port 1433 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:33856 -> 192.168.88.10:1433
07/13/2026-00:32:07.010805  [**] [1:2010937:3] ET SCAN Suspicious inbound to mySQL port 3306 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:54399 -> 192.168.88.10:3306
07/13/2026-00:32:07.013265  [**] [1:2010935:3] ET SCAN Suspicious inbound to MSSQL port 1433 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:54399 -> 192.168.88.10:1433
07/13/2026-00:32:07.018406  [**] [1:2010936:3] ET SCAN Suspicious inbound to Oracle SQL port 1521 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:54399 -> 192.168.88.10:1521
07/13/2026-00:32:07.034018  [**] [1:2010939:3] ET SCAN Suspicious inbound to PostgreSQL port 5432 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:54399 -> 192.168.88.10:5432
07/13/2026-00:32:24.263849  [**] [1:2010937:3] ET SCAN Suspicious inbound to mySQL port 3306 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:48768 -> 192.168.88.10:3306
07/13/2026-00:32:24.273750  [**] [1:2010939:3] ET SCAN Suspicious inbound to PostgreSQL port 5432 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:48768 -> 192.168.88.10:5432
07/13/2026-00:32:24.283410  [**] [1:2010935:3] ET SCAN Suspicious inbound to MSSQL port 1433 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:48768 -> 192.168.88.10:1433
07/13/2026-00:32:24.287669  [**] [1:2010936:3] ET SCAN Suspicious inbound to Oracle SQL port 1521 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.88.116:48768 -> 192.168.88.10:1521
07/13/2026-00:32:30.407750  [**] [1:2034718:4] ET INFO RMI Request Outbound [**] [Classification: Potential Corporate Privacy Violation] [Priority: 1] {TCP} 192.168.88.116:51054 -> 192.168.88.10:9090
07/13/2026-00:32:30.407377  [**] [1:2221010:1] SURICATA HTTP unable to match response to request [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.10:3000 -> 192.168.88.116:36588
07/13/2026-00:32:45.442022  [**] [1:2221010:1] SURICATA HTTP unable to match response to request [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.10:9090 -> 192.168.88.116:36744
07/13/2026-00:32:45.442977  [**] [1:2221010:1] SURICATA HTTP unable to match response to request [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.10:9090 -> 192.168.88.116:36756
07/13/2026-00:32:55.468326  [**] [1:2221010:1] SURICATA HTTP unable to match response to request [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.10:9090 -> 192.168.88.116:42690
07/13/2026-00:32:55.468952  [**] [1:2260000:1] SURICATA Applayer Mismatch protocol both directions [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.116:42704 -> 192.168.88.10:9090
07/13/2026-00:33:00.490583  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:42992 -> 192.168.88.10:9090
07/13/2026-00:33:00.490583  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:42992 -> 192.168.88.10:9090
07/13/2026-00:33:00.490709  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43000 -> 192.168.88.10:9090
07/13/2026-00:33:00.490709  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43000 -> 192.168.88.10:9090
07/13/2026-00:33:00.490925  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59662 -> 192.168.88.10:3000
07/13/2026-00:33:00.490925  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59662 -> 192.168.88.10:3000
07/13/2026-00:33:00.490990  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59660 -> 192.168.88.10:3000
07/13/2026-00:33:00.490990  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59660 -> 192.168.88.10:3000
07/13/2026-00:33:00.593090  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43016 -> 192.168.88.10:9090
07/13/2026-00:33:00.593090  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43016 -> 192.168.88.10:9090
07/13/2026-00:33:00.593155  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59676 -> 192.168.88.10:3000
07/13/2026-00:33:00.593155  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59676 -> 192.168.88.10:3000
07/13/2026-00:33:00.643495  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43028 -> 192.168.88.10:9090
07/13/2026-00:33:00.643495  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:43028 -> 192.168.88.10:9090
07/13/2026-00:33:00.643935  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59678 -> 192.168.88.10:3000
07/13/2026-00:33:00.643935  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59678 -> 192.168.88.10:3000
07/13/2026-00:33:00.749896  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59682 -> 192.168.88.10:3000
07/13/2026-00:33:00.749896  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59682 -> 192.168.88.10:3000
07/13/2026-00:33:00.799514  [**] [1:2009358:8] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59696 -> 192.168.88.10:3000
07/13/2026-00:33:00.799514  [**] [1:2024364:5] ET SCAN Possible Nmap User-Agent Observed [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 192.168.88.116:59696 -> 192.168.88.10:3000
07/13/2026-00:33:41.382981  [**] [1:2221010:1] SURICATA HTTP unable to match response to request [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 192.168.88.10:9090 -> 192.168.88.116:51054
```

В данном примере мы видим что Suricata выявила попытку сканирования уязвимостей и об этом сообщает

### Задание 2

[](https://github.com/netology-code/sdb-homeworks/blob/main/13-03.md#%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-2)

Проведите атаку на подбор пароля для службы SSH:

**hydra -L users.txt -P pass.txt < ip-адрес > ssh**

1. Настройка **hydra**:

- создайте два файла: **users.txt** и **pass.txt**;
- в каждой строчке первого файла должны быть имена пользователей, второго — пароли. В нашем случае это могут быть случайные строки, но ради эксперимента можете добавить имя и пароль существующего пользователя.

Дополнительная информация по **hydra**: [https://kali.tools/?p=1847](https://kali.tools/?p=1847).

2. Включение защиты SSH для Fail2Ban:

- открыть файл /etc/fail2ban/jail.conf,
- найти секцию **ssh**,
- установить **enabled** в **true**.

Дополнительная информация по **Fail2Ban**:[https://putty.org.ru/articles/fail2ban-ssh.html](https://putty.org.ru/articles/fail2ban-ssh.html).

_В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат._

---
### Решение 2
Выполнил `hydra -L users.txt -P pass.txt 192.168.88.10 ssh`
Результат:
```bash

2026-07-13 00:30:33,538 fail2ban.server         [746]: INFO    Starting Fail2ban v1.1.0
2026-07-13 00:30:33,538 fail2ban.observer       [746]: INFO    Observer start...
2026-07-13 00:30:33,544 fail2ban.database       [746]: INFO    Connected to fail2ban persistent database '/var/lib/fail2ban/fail2ban.sqlite3'
2026-07-13 00:30:33,545 fail2ban.jail           [746]: INFO    Creating new jail 'sshd'
2026-07-13 00:30:33,557 fail2ban.jail           [746]: INFO    Jail 'sshd' uses systemd {}
2026-07-13 00:30:33,567 fail2ban.jail           [746]: INFO    Initiated 'systemd' backend
2026-07-13 00:30:33,568 fail2ban.filter         [746]: INFO      maxLines: 1
2026-07-13 00:30:33,595 fail2ban.filtersystemd  [746]: INFO    [sshd] Added journal match for: '_SYSTEMD_UNIT=ssh.service + _COMM=sshd'
2026-07-13 00:30:33,595 fail2ban.filter         [746]: INFO      maxRetry: 5
2026-07-13 00:30:33,595 fail2ban.filter         [746]: INFO      findtime: 600
2026-07-13 00:30:33,595 fail2ban.actions        [746]: INFO      banTime: 600
2026-07-13 00:30:33,595 fail2ban.filter         [746]: INFO      encoding: UTF-8
2026-07-13 00:30:33,599 fail2ban.jail           [746]: INFO    Jail 'sshd' started
2026-07-13 00:30:33,655 fail2ban.filtersystemd  [746]: INFO    [sshd] Jail is in operation now (process new journal entries)
2026-07-13 00:30:48,445 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.3 - 2026-07-13 00:30:47
2026-07-13 00:30:49,587 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.3 - 2026-07-13 00:30:49
2026-07-13 00:59:29,648 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.3 - 2026-07-13 00:59:29
2026-07-13 00:59:31,317 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.3 - 2026-07-13 00:59:31
2026-07-13 01:21:15,504 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,505 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,505 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,505 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,507 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,507 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,508 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,508 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,508 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:15,817 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:15
2026-07-13 01:21:16,205 fail2ban.actions        [746]: NOTICE  [sshd] Ban 192.168.88.116
2026-07-13 01:21:17,132 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:16
2026-07-13 01:21:17,133 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:16
2026-07-13 01:21:17,567 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,572 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,573 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,573 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,573 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,573 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,984 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,984 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,984 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,985 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
2026-07-13 01:21:17,985 fail2ban.filter         [746]: INFO    [sshd] Found 192.168.88.116 - 2026-07-13 01:21:17
```

В данном примере атака была с 192.168.88.116, 10 раз была попытка подобрать пароль и данный ip попал в бан.