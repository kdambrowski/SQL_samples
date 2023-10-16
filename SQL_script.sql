-- a. Napisz zapytanie zwracające wszystkich pasażerów, którzy mieszkają w Warszawie albo w Krakowie oraz mieli 
-- wylot między 2022-01-01 a 2022-06-01.
SELECT DISTINCT r.pasazer_id1 AS indywidualny_numer_pasazera,
	p.imie,
    p.nazwisko,
	a.miejscowosc AS nazwa_miejscowosci_skad_pochodzi_pasazer
FROM rezerwacja AS r
	JOIN adres AS a ON r.pasazer_adres_id1 = a.id
    JOIN lot ON r.lot_numer_lotu1 = lot.numer_lotu
    JOIN pasazer AS p ON r.pasazer_id1 = p.id
WHERE lot.data_wylotu BETWEEN '2022-01-01T00:00:00.000' AND '2022-06-01T23:59:59.999'
    AND a.miejscowosc IN ('Warszawa', 'Kraków');

-- b. Napisz zapytanie zliczające ile lotów wykonał każdy z samolotów w okresie 2022-01-01 do dnia dzisiejszego. 
SELECT s.id AS numer_samolotu, 
	COUNT(s.id) AS liczba_lotow_od_2022_01_01_do_dzis 
FROM lot
	JOIN samolot as s ON s.id = lot.samolot_id1
WHERE lot.data_wylotu BETWEEN '2022-01-01' AND NOW()
GROUP BY s.id;

-- c. Do powyższego zapytania, dodaj  informację, o liczbie pasażerów obsłużonych przez każdy samolot i jaki procent z 
-- tych pasażerów posiadał dodatkowy bagaż. (informacja o bagażu jest przechowywana w tabeli rezerwacja w polu bagaż. 
-- Jeśli jest pusta, to pasażer nie miał dodatkowego bagażu).
SELECT s.id AS samolot_id, 
	COUNT(DISTINCT lot.numer_lotu) AS liczba_lotow_od_2022_01_01_do_dzis, 
	COUNT(r.pasazer_id1) AS liczba_pasazerow_obsluzonych_przez_samolot,
	(COUNT(CASE WHEN r.bagaz <> 'pusta' THEN 1 END) / COUNT(r.pasazer_id1)) AS procent_pasaerow_z_dodatkowym_bagazem -- tu uzyto pusta bo nie zdefiniowano w zadaniu czy to jest wartosc typu varchar czy null
FROM rezerwacja as r
	JOIN lot ON r.lot_numer_lotu1 = lot.numer_lotu
	JOIN samolot as s ON s.id = lot.samolot_id1
	WHERE lot.data_wylotu BETWEEN '2022-01-01' AND NOW()
	GROUP BY s.id;

-- d. Napisz zapytanie zwracające dla każdego pasażera jego 3 ostatnie loty z podziałem na producenta samolotu.
WITH ostatnie_loty AS (
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY lot.data_wylotu DESC) AS nr_wiersza, 
		p.id AS indywidualny_numer_pasazera,
        p.imie,
        p.nazwisko,
		lot.data_wylotu,
        s.producent AS producent_samolotu
	FROM rezerwacja AS r 
		JOIN pasazer AS p ON r.pasazer_id1 = p.id
		JOIN lot ON r.lot_numer_lotu1 = lot.numer_lotu
		JOIN samolot AS s ON lot.samolot_id1 = s.id
		)
SELECT indywidualny_numer_pasazera, imie, nazwisko, data_wylotu, producent_samolotu
FROM ostatnie_loty AS ol
WHERE ol.nr_wiersza <=3;

-- e. Napisz zapytanie zwracające informacje o liczbie pasażerów obsłużonych przez każdy samolot w każdym miesiącu
--  w okresie od 2022-01-01 do 2023-02-28. Dodatkowo dodaj sumę narastającą na liczbie obsłużonych pasażerów przez 
-- każdy z samolotów.
WITH CTE AS (
SELECT
    s.id,
    s.producent,
    s.typ,
    CONCAT(YEAR(lot.data_wylotu),'-',LPAD(MONTH(lot.data_wylotu), 2, 0)) AS miesiac,
    COUNT(r.id) AS liczba_obsluzonych_pasazerow
FROM
    samolot AS s
JOIN
    lot ON s.id = lot.samolot_id1
JOIN
    rezerwacja AS r ON r.lot_numer_lotu1 = lot.numer_lotu
WHERE
   lot.data_wylotu BETWEEN '2022-01-01T00:00:00.000' AND '2023-02-28T23:59:59.999'
GROUP BY
    s.id,
    s.producent,
    s.typ,
	CONCAT(YEAR(lot.data_wylotu),'-',LPAD(MONTH(lot.data_wylotu), 2, 0))
)
SELECT
    *,
    SUM(liczba_obsluzonych_pasazerow) OVER (
    PARTITION BY id ORDER BY miesiac) AS suma_narastajaca_pasazerow
FROM
    CTE;