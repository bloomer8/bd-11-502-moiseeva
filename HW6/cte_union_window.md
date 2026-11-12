HW6. CTE, UNION и оконные функции (MusicHub)
Запросы написаны для PostgreSQL и рассчитаны на итоговую структуру БД после нормализации:
- artist(id, name)
- album(id, title, year, description, artist_id)
- track(id, title, duration, album_id, genre)
- users(id, name, email)
- playlist(id, title, user_id, created_at)
- playlist_track(playlist_id, track_id)
Предполагается, что artist_id находится в album, а связь плейлистов и треков хранится в playlist_track.

0. Дополнительные данные
Сначала добавим данные, чтобы запросы возвращали непустые результаты.
-- Дополнительные исполнители
INSERT INTO artist (name)
SELECT v.name
FROM (VALUES
    ('Taylor Swift'),
    ('Dua Lipa'),
    ('Ed Sheeran')
) AS v(name)
WHERE NOT EXISTS (
    SELECT 1 FROM artist a WHERE a.name = v.name
);

-- Добавим пользователя с именем, совпадающим с именем исполнителя.
-- Это нужно для проверки INTERSECT.
INSERT INTO users (name, email)
SELECT 'The Weeknd', 'theweeknd@mail.com'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE email = 'theweeknd@mail.com'
);

-- Дополнительные альбомы
INSERT INTO album (title, year, description, artist_id)
SELECT v.title, v.year, v.description, a.id
FROM (VALUES
    ('Midnights', '2022', 'Pop album', 'Taylor Swift'),
    ('Future Nostalgia', '2020', 'Dance-pop album', 'Dua Lipa'),
    ('Divide', '2017', 'Pop album', 'Ed Sheeran')
) AS v(title, year, description, artist_name)
JOIN artist a ON a.name = v.artist_name
WHERE NOT EXISTS (
    SELECT 1 FROM album old WHERE old.title = v.title
);

-- Дополнительные треки
INSERT INTO track (title, duration, album_id, genre)
SELECT v.title, v.duration, a.id, v.genre
FROM (VALUES
    ('Anti-Hero', 200, 'Midnights', 'Pop'),
    ('Lavender Haze', 202, 'Midnights', 'Pop'),
    ('Levitating', 203, 'Future Nostalgia', 'Pop'),
    ('Physical', 205, 'Future Nostalgia', 'Dance-pop'),
    ('Shape of You', 240, 'Divide', 'Pop'),
    ('Perfect', 263, 'Divide', 'Pop'),
    ('Short Song', 180, 'Divide', 'Pop')
) AS v(title, duration, album_title, genre)
JOIN album a ON a.title = v.album_title
WHERE NOT EXISTS (
    SELECT 1 FROM track old WHERE old.title = v.title
);

-- Дополнительные пользователи
INSERT INTO users (name, email)
SELECT 'Max', 'max@mail.com'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE email = 'max@mail.com'
);

-- Дополнительные плейлисты
INSERT INTO playlist (title, user_id, created_at)
SELECT v.title, u.id, CURRENT_TIMESTAMP
FROM (VALUES
    ('Pop hits', 'Lilia'),
    ('Evening', 'Anna'),
    ('New music', 'Max')
) AS v(title, user_name)
JOIN users u ON u.name = v.user_name
WHERE NOT EXISTS (
    SELECT 1 FROM playlist p
    WHERE p.title = v.title AND p.user_id = u.id
);

-- Свяжем плейлисты с треками
INSERT INTO playlist_track (playlist_id, track_id)
SELECT p.id, t.id
FROM (VALUES
    ('My Best Favorites', 'Blinding Lights'),
    ('My Best Favorites', 'Anti-Hero'),
    ('Workout', 'Work'),
    ('Workout', 'Physical'),
    ('Chill music', 'Crazy in love'),
    ('Chill music', 'Perfect'),
    ('Pop hits', 'Levitating'),
    ('Pop hits', 'Shape of You'),
    ('Evening', 'Perfect'),
    ('New music', 'Anti-Hero'),
    ('New music', 'Lavender Haze')
) AS v(playlist_title, track_title)
JOIN playlist p ON p.title = v.playlist_title
JOIN track t ON t.title = v.track_title
WHERE NOT EXISTS (
    SELECT 1 FROM playlist_track pt
    WHERE pt.playlist_id = p.id AND pt.track_id = t.id
);



1. CTE — 3 запроса
CTE (Common Table Expression) — временный именованный результат запроса, который объявляется через WITH и используется в основном запросе.
1.1. Вывести исполнителей и количество их альбомов
WITH artist_albums AS (
    SELECT artist_id, COUNT(*) AS album_count
    FROM album
    GROUP BY artist_id
)
SELECT a.name, aa.album_count
FROM artist a
JOIN artist_albums aa ON aa.artist_id = a.id
ORDER BY aa.album_count DESC;


Сначала CTE считает альбомы каждого исполнителя, затем основной запрос добавляет имена исполнителей.
1.2. Найти альбомы, в которых средняя длительность треков больше 200 секунд
WITH album_stats AS (
    SELECT
        album_id,
        AVG(duration) AS avg_duration,
        COUNT(*) AS track_count
    FROM track
    GROUP BY album_id
)
SELECT a.title, s.avg_duration, s.track_count
FROM album a
JOIN album_stats s ON s.album_id = a.id
WHERE s.avg_duration > 200;


CTE рассчитывает статистику по альбомам, внешний запрос выбирает альбомы со средней длительностью больше 200 секунд.
1.3. Найти пользователей и количество треков во всех их плейлистах
WITH user_tracks AS (
    SELECT
        p.user_id,
        COUNT(pt.track_id) AS track_count
    FROM playlist p
    LEFT JOIN playlist_track pt ON pt.playlist_id = p.id
    GROUP BY p.user_id
)
SELECT u.name, COALESCE(ut.track_count, 0) AS track_count
FROM users u
LEFT JOIN user_tracks ut ON ut.user_id = u.id
ORDER BY track_count DESC;


CTE считает общее количество треков в плейлистах каждого пользователя.

2. UNION, INTERSECT, EXCEPT — по 1 запросу
2.1. UNION — объединение результатов
Вывести названия всех исполнителей и пользователей в одном списке.
SELECT name AS person_name
FROM artist
UNION
SELECT name
FROM users;


UNION объединяет результаты и убирает дубликаты.
2.2. INTERSECT — пересечение результатов
Найти имена, которые одновременно встречаются среди исполнителей и пользователей.
SELECT name
FROM artist
INTERSECT
SELECT name
FROM users;


INTERSECT оставляет только общие значения двух запросов.
2.3. EXCEPT — разность результатов
Найти исполнителей, у которых нет одноимённого пользователя.
SELECT name
FROM artist
EXCEPT
SELECT name
FROM users;


EXCEPT возвращает строки первого запроса, которых нет во втором.

3. Оконные функции: PARTITION BY — 2 запроса
PARTITION BY делит строки на группы, но не объединяет их в одну строку, как GROUP BY. Результат оконной функции выводится рядом с каждой исходной строкой.
3.1. Вывести каждый трек и среднюю длительность треков его альбома
SELECT
    title,
    album_id,
    duration,
    AVG(duration) OVER (PARTITION BY album_id) AS avg_album_duration
FROM track
ORDER BY album_id, title;


Для каждого альбома отдельно рассчитывается средняя длительность его треков.
3.2. Вывести каждый альбом и количество альбомов его исполнителя
SELECT
    title,
    artist_id,
    COUNT(*) OVER (PARTITION BY artist_id) AS artist_album_count
FROM album
ORDER BY artist_id, title;


Для каждого альбома показывается, сколько всего альбомов есть у его исполнителя.

4. Оконные функции: PARTITION BY + ORDER BY — 2 запроса
4.1. Пронумеровать треки внутри каждого альбома по длительности
SELECT
    title,
    album_id,
    duration,
    ROW_NUMBER() OVER (
        PARTITION BY album_id
        ORDER BY duration
    ) AS track_number
FROM track;


Нумерация начинается заново для каждого альбома. Самый короткий трек получает номер 1.
4.2. Посчитать накопительную сумму длительности треков внутри каждого альбома
SELECT
    title,
    album_id,
    duration,
    SUM(duration) OVER (
        PARTITION BY album_id
        ORDER BY duration
    ) AS running_duration
FROM track;


Сумма постепенно увеличивается по мере перехода к следующим трекам внутри альбома.

5. Оконная рамка ROWS — 2 запроса
ROWS задаёт рамку относительно физического количества строк до и после текущей строки.
5.1. Посчитать сумму длительности текущего трека и одного предыдущего трека в альбоме
SELECT
    title,
    album_id,
    duration,
    SUM(duration) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS two_tracks_duration
FROM track;


В сумму входят текущая строка и одна физически предыдущая строка в порядке сортировки.
5.2. Посчитать среднюю длительность текущего трека и двух следующих треков
SELECT
    title,
    album_id,
    duration,
    AVG(duration) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
        ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
    ) AS next_three_avg
FROM track;


Для каждой строки считается среднее по текущему треку и двум следующим. Если строк меньше трёх, используются доступные строки.

6. Оконная рамка RANGE — 2 запроса
RANGE задаёт рамку по значениям сортировки, а не по количеству физических строк. В PostgreSQL для рамки со смещением используется один столбец ORDER BY.
6.1. Посчитать сумму длительности треков, которые отличаются по длительности от текущего не более чем на 5 секунд
SELECT
    title,
    duration,
    SUM(duration) OVER (
        ORDER BY duration
        RANGE BETWEEN 5 PRECEDING AND 5 FOLLOWING
    ) AS nearby_duration_sum
FROM track;


В сумму входят треки, длительность которых находится в диапазоне от duration - 5 до duration + 5.
6.2. Посчитать среднюю длительность треков в диапазоне от текущей длительности до 10 секунд вперёд
SELECT
    title,
    duration,
    AVG(duration) OVER (
        ORDER BY duration
        RANGE BETWEEN CURRENT ROW AND 10 FOLLOWING
    ) AS duration_range_avg
FROM track;


Для каждого трека считается средняя длительность треков, попавших в диапазон от текущего значения до значения на 10 секунд больше.

7. Ранжирующие оконные функции
7.1. ROW_NUMBER — уникальный номер строки
SELECT
    title,
    duration,
    ROW_NUMBER() OVER (ORDER BY duration DESC, id) AS row_num
FROM track;


Каждой строке присваивается уникальный номер. Даже при одинаковой длительности номера будут разными.
7.2. RANK — ранг с пропусками
SELECT
    title,
    duration,
    RANK() OVER (ORDER BY duration DESC) AS track_rank
FROM track;


Одинаковые значения получают одинаковый ранг, а следующий ранг пропускается.
7.3. DENSE_RANK — ранг без пропусков
SELECT
    title,
    duration,
    DENSE_RANK() OVER (ORDER BY duration DESC) AS dense_track_rank
FROM track;


Одинаковые значения получают одинаковый ранг, но пропусков в нумерации нет.
7.4. PERCENT_RANK — относительный ранг
SELECT
    title,
    duration,
    PERCENT_RANK() OVER (ORDER BY duration) AS percent_rank
FROM track;


Возвращает относительный ранг от 0 до 1. Минимальное значение получает 0, максимальное — 1, если строк больше одной.
7.5. CUME_DIST — накопительное распределение
SELECT
    title,
    duration,
    CUME_DIST() OVER (ORDER BY duration) AS cumulative_distribution
FROM track;


Показывает долю строк, значение которых меньше или равно значению текущей строки.
7.6. NTILE — распределение по группам
SELECT
    title,
    duration,
    NTILE(3) OVER (ORDER BY duration DESC) AS duration_group
FROM track;


Распределяет строки на три примерно равные группы. Первая группа содержит более длинные треки.

8. Функции смещения и доступа к строкам
8.1. LAG — получить значение предыдущей строки
SELECT
    title,
    album_id,
    duration,
    LAG(duration, 1) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
    ) AS previous_duration
FROM track;


Показывает длительность предыдущего трека внутри того же альбома. У первой строки альбома значение будет NULL.
8.2. LEAD — получить значение следующей строки
SELECT
    title,
    album_id,
    duration,
    LEAD(duration, 1) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
    ) AS next_duration
FROM track;


Показывает длительность следующего трека внутри альбома. У последней строки значение будет NULL.
8.3. FIRST_VALUE — первое значение в окне
SELECT
    title,
    album_id,
    duration,
    FIRST_VALUE(title) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
    ) AS shortest_track
FROM track;


Для каждого трека показывает название самого короткого трека его альбома.
8.4. LAST_VALUE — последнее значение в окне
SELECT
    title,
    album_id,
    duration,
    LAST_VALUE(title) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS longest_track
FROM track;


Показывает название самого длинного трека в альбоме. Полная рамка UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING нужна, чтобы получить последнее значение всего раздела, а не текущей рамки.
8.5. NTH_VALUE — получить значение строки с заданным номером
SELECT
    title,
    album_id,
    duration,
    NTH_VALUE(title, 2) OVER (
        PARTITION BY album_id
        ORDER BY duration, id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_shortest_track
FROM track;


Показывает название второго по длительности трека в альбоме. Если в альбоме меньше двух треков, результат будет NULL.
