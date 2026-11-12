HW6. Подзапросы (MusicHub)
Запросы написаны для итоговой структуры базы MusicHub после
нормализации:
- artist(id, name)
- album(id, title, year, description, artist_id)
- track(id, title, duration, album_id, genre)
- users(id, name, email)
- playlist(id, title, user_id, created_at)
- playlist_track(playlist_id, track_id)
Предполагается, что artist_id находится в album, а связь плейлистов
и треков реализована через playlist_track.
1. Подзапрос в SELECT --- 2 запроса
1.1. Вывести каждого исполнителя и количество всех альбомов в базе
SELECT
    name,
    (SELECT COUNT(*) FROM album) AS total_albums
FROM artist;
Подзапрос возвращает одно число --- общее количество альбомов.
1.2. Вывести названия альбомов и общее количество треков в базе
SELECT
    title,
    (SELECT COUNT(*) FROM track) AS total_tracks
FROM album;
Для каждой строки альбома выводится одно и то же общее количество
треков.
2. Подзапрос в FROM --- 2 запроса
2.1. Вывести альбомы, в которых средняя длительность трека больше 200 секунд
SELECT
    a.title,
    stats.avg_duration
FROM album a
JOIN (
    SELECT album_id, AVG(duration) AS avg_duration
    FROM track
    GROUP BY album_id
) AS stats ON stats.album_id = a.id
WHERE stats.avg_duration > 200;
Подзапрос в FROM сначала рассчитывает среднюю длительность треков для
каждого альбома.
2.2. Вывести плейлисты и количество треков в каждом
SELECT
    p.title,
    COALESCE(stats.track_count, 0) AS track_count
FROM playlist p
LEFT JOIN (
    SELECT playlist_id, COUNT(*) AS track_count
    FROM playlist_track
    GROUP BY playlist_id
) AS stats ON stats.playlist_id = p.id;
Подзапрос формирует временную таблицу с количеством треков для каждого
плейлиста. LEFT JOIN позволяет показать и пустые плейлисты.
3. Подзапрос в WHERE --- 2 запроса
3.1. Найти треки, длительность которых больше средней длительности всех треков
SELECT title, duration
FROM track
WHERE duration > (
    SELECT AVG(duration)
    FROM track
);
Подзапрос вычисляет среднюю длительность, а внешний запрос сравнивает с
ней каждый трек.
3.2. Найти треки из альбома After Hours Deluxe
SELECT title, duration
FROM track
WHERE album_id = (
    SELECT id
    FROM album
    WHERE title = 'After Hours Deluxe'
);
Подзапрос находит ID альбома по названию, внешний запрос выбирает его
треки.
4. Подзапрос в HAVING --- 2 запроса
4.1. Найти исполнителей, у которых альбомов больше, чем среднее количество альбомов на исполнителя
SELECT artist_id, COUNT(*) AS album_count
FROM album
GROUP BY artist_id
HAVING COUNT(*) > (
    SELECT AVG(album_count)
    FROM (
        SELECT COUNT(*) AS album_count
        FROM album
        GROUP BY artist_id
    ) AS artist_stats
);
Внутренний запрос считает количество альбомов каждого исполнителя,
следующий уровень вычисляет среднее. HAVING сравнивает с ним
количество альбомов текущего исполнителя.
4.2. Найти плейлисты, в которых треков больше, чем среднее количество треков в плейлисте
SELECT playlist_id, COUNT(*) AS track_count
FROM playlist_track
GROUP BY playlist_id
HAVING COUNT(*) > (
    SELECT AVG(track_count)
    FROM (
        SELECT COUNT(*) AS track_count
        FROM playlist_track
        GROUP BY playlist_id
    ) AS playlist_stats
);
Подзапрос вычисляет среднее количество треков в плейлистах, а HAVING
оставляет плейлисты выше среднего.
5. Оператор ALL --- 2 запроса
5.1. Найти треки, которые длиннее каждого трека из альбома с ID 1
SELECT title, duration
FROM track
WHERE duration > ALL (
    SELECT duration
    FROM track
    WHERE album_id = 1
);
ALL означает, что условие должно выполняться для каждого значения,
возвращённого подзапросом.
5.2. Найти треки, которые короче каждого трека из альбома с ID 1
SELECT title, duration
FROM track
WHERE duration < ALL (
    SELECT duration
    FROM track
    WHERE album_id = 1
);
Трек попадёт в результат, только если его длительность меньше
длительности каждого трека выбранного альбома.
6. Оператор IN --- 2 запроса
6.1. Найти альбомы исполнителей, чьё имя начинается на букву T
SELECT title, artist_id
FROM album
WHERE artist_id IN (
    SELECT id
    FROM artist
    WHERE name LIKE 'T%'
);
IN проверяет, входит ли artist_id альбома в список ID, полученный
подзапросом.
6.2. Найти треки из альбомов, выпущенных в 2020 году
SELECT title, album_id
FROM track
WHERE album_id IN (
    SELECT id
    FROM album
    WHERE year = '2020'
);
Подзапрос возвращает ID альбомов за 2020 год, внешний запрос выбирает
связанные с ними треки.
7. Оператор ANY --- 2 запроса
7.1. Найти треки, которые длиннее хотя бы одного трека из альбома с ID 1
SELECT title, duration
FROM track
WHERE duration > ANY (
    SELECT duration
    FROM track
    WHERE album_id = 1
);
ANY означает, что достаточно выполнить условие хотя бы для одного
значения из подзапроса.
7.2. Найти треки, которые короче хотя бы одного трека из альбома с ID 1
SELECT title, duration
FROM track
WHERE duration < ANY (
    SELECT duration
    FROM track
    WHERE album_id = 1
);
Трек попадёт в результат, если найдётся хотя бы один трек выбранного
альбома с большей длительностью.
8. Оператор EXISTS --- 2 запроса
8.1. Найти пользователей, у которых есть хотя бы один плейлист
SELECT u.id, u.name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM playlist p
    WHERE p.user_id = u.id
);
EXISTS проверяет, возвращает ли подзапрос хотя бы одну строку.
8.2. Найти исполнителей, у которых есть хотя бы один альбом
SELECT ar.id, ar.name
FROM artist ar
WHERE EXISTS (
    SELECT 1
    FROM album a
    WHERE a.artist_id = ar.id
);
Проверяется наличие хотя бы одного альбома у каждого исполнителя.
9. Сравнение по нескольким столбцам --- 2 запроса
9.1. Найти плейлисты, принадлежащие пользователям с именем Lilia, сравнивая одновременно ID пользователя и название плейлиста
SELECT p.user_id, p.title
FROM playlist p
WHERE (p.user_id, p.title) IN (
    SELECT p2.user_id, p2.title
    FROM playlist p2
    JOIN users u ON u.id = p2.user_id
    WHERE u.name = 'Lilia'
);
Сравнивается сразу пара значений: user_id и title.
9.2. Найти самые длинные треки в каждом альбоме
SELECT album_id, duration, title
FROM track
WHERE (album_id, duration) IN (
    SELECT album_id, MAX(duration)
    FROM track
    GROUP BY album_id
);
Сравнивается пара столбцов: ID альбома и длительность трека. Подзапрос
находит максимальную длительность для каждого альбома.
10. Коррелированные подзапросы --- 5 запросов
Коррелированный подзапрос использует значение из внешнего запроса.
Поэтому он логически выполняется с учётом текущей строки внешнего
запроса.
10.1. Найти треки, длительность которых больше средней длительности треков в их альбоме
SELECT t.title, t.duration, t.album_id
FROM track t
WHERE t.duration > (
    SELECT AVG(t2.duration)
    FROM track t2
    WHERE t2.album_id = t.album_id
);
Подзапрос обращается к t.album_id из внешнего запроса и считает
среднюю длительность именно для этого альбома.
10.2. Найти исполнителей, у которых есть хотя бы один альбом
SELECT ar.id, ar.name
FROM artist ar
WHERE EXISTS (
    SELECT 1
    FROM album a
    WHERE a.artist_id = ar.id
);
Подзапрос использует ar.id из внешнего запроса, поэтому он
коррелированный.
10.3. Найти плейлисты, в которых больше одного трека
SELECT p.id, p.title
FROM playlist p
WHERE (
    SELECT COUNT(*)
    FROM playlist_track pt
    WHERE pt.playlist_id = p.id
) > 1;
Подзапрос считает треки для текущего плейлиста, используя его p.id.
10.4. Найти альбомы, в которых треков больше, чем в среднем у альбомов того же исполнителя
SELECT a.id, a.title, a.artist_id
FROM album a
WHERE (
    SELECT COUNT(*)
    FROM track t
    WHERE t.album_id = a.id
) > (
    SELECT AVG(album_track_count)
    FROM (
        SELECT COUNT(t2.id) AS album_track_count
        FROM album a2
        LEFT JOIN track t2 ON t2.album_id = a2.id
        WHERE a2.artist_id = a.artist_id
        GROUP BY a2.id
    ) AS artist_album_stats
);
Оба подзапроса используют a.id или a.artist_id из внешнего запроса.
Сначала считается число треков текущего альбома, затем среднее число
треков в альбомах того же исполнителя.
10.5. Найти пользователей, у которых есть плейлист хотя бы с одним треком
SELECT u.id, u.name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM playlist p
    JOIN playlist_track pt ON pt.playlist_id = p.id
    WHERE p.user_id = u.id
);
Подзапрос связан с внешним запросом через u.id: проверяется наличие
плейлиста с треками у текущего пользователя.
Кратко: чем отличаются операторы
- SELECT --- подзапрос используется как отдельное значение в списке
  выводимых столбцов.
- FROM --- подзапрос создаёт временную таблицу, с которой работает
  внешний запрос.
- WHERE --- подзапрос помогает отфильтровать строки.
- HAVING --- подзапрос используется для фильтрации сгруппированных
  данных.
- ALL --- условие должно выполняться для всех значений подзапроса.
- IN --- значение должно входить в набор, возвращённый подзапросом.
- ANY --- условие должно выполняться хотя бы для одного значения.
- EXISTS --- проверяет, вернул ли подзапрос хотя бы одну строку.
- Сравнение по нескольким столбцам --- сравниваются наборы значений,
  например (album_id, duration).
- Коррелированный подзапрос --- обращается к столбцам внешнего
  запроса.
