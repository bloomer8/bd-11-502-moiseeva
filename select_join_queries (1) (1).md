# HW4 — SELECT, CASE и JOIN

## 1. SELECT

### Запрос 1
Смотрю имена всех артистов.
```sql
SELECT name
FROM artist;
```

### Запрос 2
Вывожу название и длительность треков.
```sql
SELECT title, duration
FROM track;
```

## 2. SELECT + CASE

### Запрос 1
Хочу пометить, кто у меня главный артист, а кто нет.
```sql
SELECT name,
       CASE
           WHEN name = 'The Weeknd Official' THEN 'Главный артист'
           ELSE 'Другой артист'
       END AS artist_status
FROM artist;
```

### Запрос 2
Делю треки на длинные и короткие по длительности.
```sql
SELECT title, duration,
       CASE
           WHEN duration >= 200 THEN 'Длинный трек'
           ELSE 'Короткий трек'
       END AS duration_type
FROM track;
```

## 3. JOIN

### INNER JOIN

#### Запрос 1
Соединяю треки с их артистами, беру только те, где есть совпадение.
```sql
SELECT track.title, artist.name
FROM track
INNER JOIN artist ON track.artist_id = artist.id;
```

#### Запрос 2
Смотрю плейлисты вместе с их владельцами.
```sql
SELECT playlist.title, users.name
FROM playlist
INNER JOIN users ON playlist.user_id = users.id;
```

### LEFT JOIN

#### Запрос 1
Беру всех артистов, даже если у них пока нет треков.
```sql
SELECT artist.name, track.title
FROM artist
LEFT JOIN track ON artist.id = track.artist_id;
```

#### Запрос 2
Беру всех юзеров, даже если у них нет ни одного плейлиста.
```sql
SELECT users.name, playlist.title
FROM users
LEFT JOIN playlist ON users.id = playlist.user_id;
```

### RIGHT JOIN

#### Запрос 1
Беру все альбомы, даже если в них ещё нет треков.
```sql
SELECT track.title, album.title
FROM track
RIGHT JOIN album ON track.album_id = album.id;
```

#### Запрос 2
Беру всех юзеров, даже тех, у кого нет плейлистов — тут то же самое, что и left, только наоборот.
```sql
SELECT playlist.title, users.name
FROM playlist
RIGHT JOIN users ON playlist.user_id = users.id;
```

### CROSS JOIN

#### Запрос 1
Делаю все возможные комбинации артистов и альбомов, просто для примера.
```sql
SELECT artist.name, album.title
FROM artist
CROSS JOIN album;
```

#### Запрос 2
То же самое, но для юзеров и артистов.
```sql
SELECT users.name, artist.name
FROM users
CROSS JOIN artist;
```

### FULL OUTER JOIN

#### Запрос 1
Беру вообще всех: и артистов без треков, и треки без артистов.
```sql
SELECT artist.name, track.title
FROM artist
FULL OUTER JOIN track ON artist.id = track.artist_id;
```

#### Запрос 2
Беру всех юзеров и все плейлисты, даже если они не связаны между собой.
```sql
SELECT users.name, playlist.title
FROM users
FULL OUTER JOIN playlist ON users.id = playlist.user_id;
```
