# OKAK AI Mobile — iOS клиент

Мобильное приложение для интернет-магазина цифровых услуг с интегрированным GPT/LLM клиентом. Реализует регистрацию, верификацию email, авторизацию, AI-чат со streaming-ответами, квоты, каталог подписок, mock-платежи, управление сессиями, профиль и настройки.

## Стек

- Swift, SwiftUI, Combine, Foundation
- URLSession, Codable, Keychain Services, Network framework
- Architecture: MVVM, modular feature folders
- SPM (без внешних зависимостей в репозитории)
- XCTest для unit-тестов, XCUITest для UI

## Требования

- Xcode 26.2 или новее, iOS 26.2 SDK
- macOS 14+ для разработки
- Запущенный backend (`../backend`), либо доступ к удалённому API

## Запуск

1. Клонируй репозиторий и открой `OKAK APP.xcodeproj` в Xcode 26.
2. Убедись, что backend поднят. По умолчанию приложение в Simulator ходит на `http://127.0.0.1:3000`.
3. Чтобы переопределить адрес API, добавь в `Info.plist` ключ `OKAK_API_BASE_URL`.
4. Выбери симулятор и запусти Build & Run (⌘R).

## Структура

```
OKAK APP/
  App/                     // точка входа, RootView
  Core/
    DesignSystem/          // цвета, шрифты, спейсинг, кнопки
    Networking/            // APIClient, endpoints, SSE
    Security/              // Keychain
    Environment/           // конфигурация, dependencies, session store
    Utils/                 // logger, network monitor, debouncer
  Features/
    Auth/                  // login, register, email verify, password reset
    AIChat/                // чаты, сообщения, streaming, параметры
    Store/                 // каталог, mock-платежи, рекомендации
    Orders/                // история заказов
    Subscriptions/         // активные подписки, продление, отмена
    Account/               // профиль
    Settings/              // язык, тема, уведомления
    Sessions/              // активные сессии, revoke
    Common/                // home tab, toast, offline banner
```

## Тесты

- `OKAK APPTests` — unit-тесты ViewModel и валидаторов.
- `OKAK APPUITests` — smoke UI-тесты.

Запуск:

```
xcodebuild -project "OKAK APP.xcodeproj" -scheme "OKAK APP" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Безопасность

- Токены доступа и refresh-токены хранятся в Keychain.
- Пароли никогда не сохраняются на устройстве.
- LLM-ключи отсутствуют в клиенте — все обращения идут через backend.
- Платёжные реквизиты пользователя в приложении не вводятся, используется mock-провайдер.

## Демо-аккаунт

После запуска backend и применения seed-данных можно войти под:

- email: `demo@okak.app`
- пароль: см. seed-скрипт backend
