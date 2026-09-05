> [!WARNING]
> Скрипт командной строки, лежащий в этой папке, **устарел** и больше не поддерживается.
> Актуальная альтернатива — нативное macOS-приложение с графическим интерфейсом:
> **[mac_dont_sleep](https://github.com/user-is-absinthe/mac_dont_sleep)** ☕️ — friendly GUI for the built-in `caffeinate` utility.

# Что происходит

- Скрипт [dont_sleep.command](https://github.com/user-is-absinthe/rpi_scripts/blob/master/mac/dont_sleep.command) позволяет маку "не засыпать" из коробки, только штатными средствами.

- Скрипт [dont_sleep_notify.command](https://github.com/user-is-absinthe/rpi_scripts/blob/master/mac/dont_sleep_notify.command) делает то же самое, но только добавляет уведомления в цетр уведомлений.  
Для корректной работы необходимо установить [Homebrew](https://brew.sh/) и пакет `terminal-notifier` при помощи команды `brew install terminal-notifier`.
