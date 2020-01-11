Napisz aplikację pozwalającą na synchronizację tasków z wielu aplikacji do list zadań, takich jak [Todoist](https://todoist.com/), [Remember the Milk](https://www.rememberthemilk.com/), itd. Aplikacja powinna mieć działające połączenie z Todoistem i jej architektura powinna pozwalać na łatwe dodanie kolejnej aplikacji oferującej dostęp przez HTTP API.

Z poziomu aplikacji, którą zaimplementujesz, będzie można:

- synchronizować aktywne taski z Todoista do lokalnej bazy danych,
- zaktualizować nazwę taska w Todoiście i w lokalnej bazie,
- wyszukiwać taski

Aplikacja powinna wystawiać endpointy:

### Synchronizacja - `POST /sync`

Przykładowy response:

```json
{ "created": 1, "updated": 1, "deleted": 1 }
```

### Wyszukiwanie - `GET /tasks/search`

Opcjonalne parametry:

- `name`
- `source`

Przykładowy response:

```json
{
  "tasks": [
    { "id": 1, "remote_id": "1234", "name": "Task 1", "source": "todoist" },
    { "id": 2, "remote_id": "4321", "name": "Task 2", "source": "todoist" }
  ]
}
```

### Aktualizacja - `PATCH /tasks/:id`

Wymagania implementacyjne

- cały projekt oprzyj na najnowszym [Phoenixie](https://www.phoenixframework.org/)
- do komunikacji z zewnętrznymi API użyj [Tesli](https://github.com/teamon/tesla)
- użyj [Todoist REST API](https://developer.todoist.com/rest/v1/)
- bez front-endu
- bez autentykacji użytkownika, API token może być zahardkodowany w aplikacji
