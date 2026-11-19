# **HW7. Транзакции**

## **1. BEGIN и COMMIT**

**Запрос 1.** Добавление исполнителя и сохранение изменений.

```
BEGIN;

INSERT INTO artist (name)
VALUES ('Test Artist');

COMMIT;
```

**Запрос 2.** Добавление альбома и сохранение изменений.

```
BEGIN;

INSERT INTO album (title, year, description, artist_id)
VALUES ('Test Album', 2025, 'Test description', 1);

COMMIT;
```

## **2. BEGIN и ROLLBACK**

**Запрос 1.** Добавление исполнителя с отменой изменений.

```
BEGIN;

INSERT INTO artist (name)
VALUES ('Cancelled Artist');

ROLLBACK;
```

**Запрос 2.** Изменение названия альбома с отменой изменений.

```
BEGIN;

UPDATE album
SET title = 'Changed Album'
WHERE id = 1;

ROLLBACK;
```

## **3. COMMIT и ROLLBACK**

**Запрос 1.** Изменение названия исполнителя с сохранением.

```
BEGIN;

UPDATE artist
SET name = 'Updated Artist'
WHERE id = 1;

COMMIT;
```

**Запрос 2.** Изменение названия исполнителя с отменой.

```
BEGIN;

UPDATE artist
SET name = 'Another Artist'
WHERE id = 1;

ROLLBACK;
```

## **4. Уровни изоляции транзакций**

### **READ UNCOMMITTED**

**Запрос 1.** Проверка чтения незакоммиченных изменений.

Окно 1:

```
BEGIN;

UPDATE artist
SET name = 'Uncommitted Artist'
WHERE id = 1;
```

Окно 2:

```
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT * FROM artist WHERE id = 1;

COMMIT;
```

Окно 1:

```
ROLLBACK;
```

**Запрос 2.** Чтение данных после сохранения изменений другой транзакцией.

Окно 1:

```
BEGIN;

UPDATE artist
SET name = 'Committed Artist'
WHERE id = 1;

COMMIT;
```

Окно 2:

```
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT * FROM artist WHERE id = 1;

COMMIT;
```

### **READ COMMITTED**

**Запрос 1.** Повторное чтение записи после изменения в другой транзакции.

Окно 1:

```
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT * FROM artist WHERE id = 1;

SELECT pg_sleep(10);

SELECT * FROM artist WHERE id = 1;

COMMIT;
```

Во время ожидания выполнить в окне 2:

```
BEGIN;

UPDATE artist
SET name = 'Read Committed Artist'
WHERE id = 1;

COMMIT;
```

**Запрос 2.** Повторное чтение после изменения альбома.

Окно 1:

```
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT * FROM album WHERE id = 1;

SELECT pg_sleep(10);

SELECT * FROM album WHERE id = 1;

COMMIT;
```

Во время ожидания выполнить в окне 2:

```
BEGIN;

UPDATE album
SET title = 'Updated Read Committed Album'
WHERE id = 1;

COMMIT;
```

### **REPEATABLE READ**

**Запрос 1.** Проверка повторного чтения исполнителя.

Окно 1:

```
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT * FROM artist WHERE id = 1;

SELECT pg_sleep(10);

SELECT * FROM artist WHERE id = 1;

COMMIT;
```

Во время ожидания выполнить в окне 2:

```
BEGIN;

UPDATE artist
SET name = 'Repeatable Read Artist'
WHERE id = 1;

COMMIT;
```

**Запрос 2.** Проверка повторного чтения списка альбомов.

Окно 1:

```
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT * FROM album;

SELECT pg_sleep(10);

SELECT * FROM album;

COMMIT;
```

Во время ожидания выполнить в окне 2:

```
BEGIN;

INSERT INTO album (title, year, description, artist_id)
VALUES ('New Test Album', 2025, 'Test description', 1);

COMMIT;
```

### **SERIALIZABLE**

**Запрос 1.** Проверка конфликтующих изменений в двух транзакциях.

Окно 1:

```
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT COUNT(*) FROM artist;

SELECT pg_sleep(10);

UPDATE artist
SET name = 'Serializable Artist'
WHERE id = 1;

COMMIT;
```

Во время ожидания выполнить в окне 2:

```
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO artist (name)
VALUES ('Another Serializable Artist');

COMMIT;
```

**Запрос 2.** Проверка ограничения уникальности при добавлении пользователей.

Окно 1:

```
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO users (name, email)
VALUES ('Serializable User', 'serializable@example.com');

COMMIT;
```

Окно 2:

```
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO users (name, email)
VALUES ('Another User', 'serializable@example.com');

COMMIT;
```

## **5. SAVEPOINT**

**Запрос 1.** Отмена части изменений с помощью точки сохранения.

```
BEGIN;

INSERT INTO artist (name)
VALUES ('Savepoint Artist');

SAVEPOINT artist_savepoint;

INSERT INTO album (title, year, description, artist_id)
VALUES (
    'Savepoint Album',
    2025,
    'Test description',
    (SELECT id FROM artist WHERE name = 'Savepoint Artist')
);

ROLLBACK TO SAVEPOINT artist_savepoint;

COMMIT;
```

**Запрос 2.** Откат к точке сохранения и выполнение другой операции.

```
BEGIN;

INSERT INTO artist (name)
VALUES ('Second Savepoint Artist');

SAVEPOINT second_savepoint;

INSERT INTO artist (name)
VALUES ('Temporary Artist');

ROLLBACK TO SAVEPOINT second_savepoint;

INSERT INTO artist (name)
VALUES ('Final Artist');

COMMIT;
```

## **6. Вывод**

В ходе работы были изучены основные операции с транзакциями `BEGIN`, `COMMIT` и `ROLLBACK`. Были рассмотрены уровни изоляции `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ` и `SERIALIZABLE`, а также работа с точками сохранения `SAVEPOINT`.

Транзакции позволяют контролировать изменения в базе данных, сохранять успешно выполненные операции и отменять ненужные изменения. Уровни изоляции определяют, как несколько транзакций взаимодействуют между собой.
