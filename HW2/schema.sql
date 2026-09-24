-- 1. Создание таблиц

CREATE TABLE artist(
                       id SERIAL PRIMARY KEY,
                       name VARCHAR(100) NOT NULL
);

CREATE TABLE album(
                      id SERIAL PRIMARY KEY,
                      title VARCHAR(100) NOT NULL,
                      year VARCHAR(100) NOT NULL
);

CREATE TABLE users(
                      id SERIAL PRIMARY KEY,
                      name VARCHAR(100) NOT NULL,
                      email VARCHAR(100) NOT NULL
);

CREATE TABLE track(
                      id SERIAL PRIMARY KEY,
                      title VARCHAR(100) NOT NULL,
                      duration INT NOT NULL,
                      artist_id INT REFERENCES artist(id),
                      album_id INT REFERENCES album(id)
);

CREATE TABLE playlist(
                         id SERIAL PRIMARY KEY,
                         title VARCHAR(100) NOT NULL,
                         user_id INT REFERENCES users(id),
                         track_id INT REFERENCES track(id)
);


-- 2. ALTER-запросы

ALTER TABLE track
    ADD COLUMN genre VARCHAR(50);

ALTER TABLE album
    ADD COLUMN description TEXT;

ALTER TABLE artist
    ALTER COLUMN name TYPE VARCHAR(150);

ALTER TABLE playlist
    ADD COLUMN created_at TIMESTAMP;

ALTER TABLE users
    ADD CONSTRAINT unique_user_email UNIQUE (email);


-- 3. Заполняем таблицы

INSERT INTO artist (name) VALUES
                              ('The Weeknd'),
                              ('Beyonce'),
                              ('Rihanna');

INSERT INTO album (title, year, description) VALUES
                                                 ('After Hours', '2020', 'Fourth studio album'),
                                                 ('Crazy in love', '2002', 'Dance-pop album'),
                                                 ('Work', '2016', 'Third studio album');

INSERT INTO users (name, email) VALUES
                                    ('Lilia', 'lilia@mail.com'),
                                    ('Anna', 'anna@mail.com'),
                                    ('Guzel', 'Guzel@mail.com');

INSERT INTO track (title, duration, artist_id, album_id, genre) VALUES
                                                                    ('Blinding Lights', 200, 1, 1, 'Pop'),
                                                                    ('Crazy in love', 203, 2, 2, 'Pop'),
                                                                    ('Work', 204, 3, 3, 'Rock');

INSERT INTO playlist (title, user_id, track_id, created_at) VALUES
                                                                ('My favorites', 1, 1, CURRENT_TIMESTAMP),
                                                                ('Workout', 2, 3, CURRENT_TIMESTAMP),
                                                                ('Chill music', 3, 2, CURRENT_TIMESTAMP);


-- 4. UPDATE-запросы

UPDATE artist
SET name = 'The Weeknd Official'
WHERE id = 1;

UPDATE album
SET title = 'After Hours Deluxe'
WHERE id = 1;

UPDATE users
SET email = 'lilia.new@mail.com'
WHERE id = 1;

UPDATE track
SET genre = 'Alternative Pop'
WHERE id = 1;

UPDATE playlist
SET title = 'My Best Favorites'
WHERE id = 1;

SELECT * FROM artist;
SELECT * FROM album;
SELECT * FROM users;
SELECT * FROM track;
SELECT * FROM playlist;
