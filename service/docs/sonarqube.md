# Подключение Golang-сервиса к SonarQube

## Цель
Позволяет проверять качество кода и уязвимости автоматически.

## Шаги подключения

1. Получить токен SonarQube (Settings → Security → Generate Token)
2. Добавить проект в SonarQube (Project → Create Project → Key = service)
3. Проверить `.gitlab-ci.yml` — должен быть шаг `sonarqube`
4. Каждый коммит в `main`/`master` автоматически проверяется
5. Если SonarQube обнаруживает ошибки, пайплайн останавливается

## Локальная проверка
```bash
docker run --rm -v $(pwd):/usr/src sonarsource/sonar-scanner-cli \
  -Dsonar.projectKey=service \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://<sonarqube_ip>:9000 \
  -Dsonar.login=<token>

