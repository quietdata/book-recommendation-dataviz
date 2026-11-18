sql
-- ============================================================
-- PROJET : BOOK RECOMMENDATION DATASET
-- FICHIER : 02_nettoyage.sql
-- OBJET   : Contrôle qualité et nettoyage des données
-- ============================================================

-- IMPORTANT :
-- Script destiné aux tables initialement importées depuis les CSV.
-- Effectuer une sauvegarde avant toute opération destructive.
-- Exécuter ce script après les vérifications du fichier 01.
-- Les tables et colonnes créées ne doivent pas déjà exister.
--
-- Les clés étrangères sont créées à la fin du nettoyage.
-- Ce script est prévu pour une première exécution contrôlée.


-- ============================================================
-- 1. CONTROLES QUALITE INITIAUX
-- ============================================================


-- ------------------------------------------------------------
-- 1.1 BOOKS : Années de publication
-- ------------------------------------------------------------

SELECT
    `Year-Of-Publication`,
    COUNT(*) AS total
FROM books
WHERE `Year-Of-Publication` < 1900
   OR `Year-Of-Publication` > 2004
GROUP BY `Year-Of-Publication`
ORDER BY `Year-Of-Publication`;


SELECT
    ISBN,
    `Book-Title`,
    `Book-Author`,
    `Year-Of-Publication`
FROM books
WHERE (
    `Year-Of-Publication` < 1900
    OR `Year-Of-Publication` > 2004
)
AND `Year-Of-Publication` > 0
ORDER BY `Year-Of-Publication`;


-- ------------------------------------------------------------
-- 1.2 BOOKS : ISBN manquants, invalides et doublons
-- ------------------------------------------------------------

SELECT COUNT(*) AS isbn_manquants
FROM books
WHERE ISBN IS NULL
   OR TRIM(ISBN) = '';


-- ISBN-10 et ISBN-13 acceptés

SELECT COUNT(*) AS isbn_invalides
FROM books
WHERE ISBN IS NOT NULL
  AND TRIM(ISBN) <> ''
  AND UPPER(TRIM(ISBN))
      NOT REGEXP '^([0-9]{9}[0-9X]|[0-9]{13})$';


SELECT
    ISBN,
    COUNT(*) AS nb_occurrences
FROM books
GROUP BY ISBN
HAVING COUNT(*) > 1
ORDER BY nb_occurrences DESC;


-- ------------------------------------------------------------
-- 1.3 BOOKS : Informations bibliographiques manquantes
-- ------------------------------------------------------------

SELECT
    SUM(CASE WHEN `Book-Title` IS NULL
                  OR TRIM(`Book-Title`) = ''
             THEN 1 ELSE 0 END) AS titres_manquants,

    SUM(CASE WHEN `Book-Author` IS NULL
                  OR TRIM(`Book-Author`) = ''
             THEN 1 ELSE 0 END) AS auteurs_manquants,

    SUM(CASE WHEN Publisher IS NULL
                  OR TRIM(Publisher) = ''
             THEN 1 ELSE 0 END) AS editeurs_manquants
FROM books;


SELECT
    ISBN,
    `Book-Title`,
    `Book-Author`,
    Publisher
FROM books
WHERE Publisher IS NULL
   OR TRIM(Publisher) = '';


SELECT *
FROM books
WHERE Publisher REGEXP '^https?://';


-- ------------------------------------------------------------
-- 1.4 BOOKS : URL des couvertures manquantes
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_lignes,

    SUM(CASE
        WHEN `Image-URL-S` IS NULL
          OR TRIM(`Image-URL-S`) = ''
        THEN 1 ELSE 0
    END) AS url_s_manquantes,

    SUM(CASE
        WHEN `Image-URL-M` IS NULL
          OR TRIM(`Image-URL-M`) = ''
        THEN 1 ELSE 0
    END) AS url_m_manquantes,

    SUM(CASE
        WHEN `Image-URL-L` IS NULL
          OR TRIM(`Image-URL-L`) = ''
        THEN 1 ELSE 0
    END) AS url_l_manquantes

FROM books;


-- ------------------------------------------------------------
-- 1.5 RATINGS : Contrôles qualité
-- ------------------------------------------------------------

SELECT COUNT(*) AS user_id_manquants
FROM ratings
WHERE `User-ID` IS NULL;


SELECT COUNT(*) AS isbn_manquants
FROM ratings
WHERE ISBN IS NULL
   OR TRIM(ISBN) = '';


SELECT COUNT(DISTINCT ISBN) AS isbn_invalides
FROM ratings
WHERE ISBN IS NOT NULL
  AND TRIM(ISBN) <> ''
  AND UPPER(TRIM(ISBN))
      NOT REGEXP '^([0-9]{9}[0-9X]|[0-9]{13})$';


SELECT
    MIN(`Book-Rating`) AS note_minimale,
    MAX(`Book-Rating`) AS note_maximale
FROM ratings;


SELECT
    `Book-Rating`,
    COUNT(*) AS nombre_evaluations
FROM ratings
GROUP BY `Book-Rating`
ORDER BY `Book-Rating`;


-- ------------------------------------------------------------
-- 1.6 USERS : Contrôles qualité
-- ------------------------------------------------------------

SELECT COUNT(*) AS user_id_manquants
FROM users
WHERE `User-ID` IS NULL;


SELECT
    `User-ID`,
    COUNT(*) AS nb_occurrences
FROM users
GROUP BY `User-ID`
HAVING COUNT(*) > 1;


SELECT COUNT(*) AS locations_manquantes
FROM users
WHERE Location IS NULL
   OR TRIM(Location) = '';


SELECT
    LENGTH(Location) - LENGTH(REPLACE(Location, ',', ''))
        AS nb_virgules,
    COUNT(*) AS nb_users
FROM users
WHERE Location IS NOT NULL
GROUP BY nb_virgules
ORDER BY nb_virgules;


SELECT COUNT(*) AS nb_locations_anormales
FROM users
WHERE Location IS NOT NULL
  AND LENGTH(Location) - LENGTH(REPLACE(Location, ',', '')) <> 2;


SELECT COUNT(*) AS age_manquants
FROM users
WHERE Age IS NULL;


SELECT
    MIN(Age) AS age_min,
    MAX(Age) AS age_max,
    ROUND(AVG(Age), 2) AS age_moyen
FROM users
WHERE Age IS NOT NULL;


SELECT
    Age,
    COUNT(*) AS nb_users
FROM users
WHERE Age IS NOT NULL
GROUP BY Age
ORDER BY Age;


SELECT COUNT(*) AS nb_ages_aberrants
FROM users
WHERE Age > 100
   OR Age < 5;


-- ============================================================
-- 2. NETTOYAGE DES ISBN ET DEDUPLICATION DE BOOKS
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 Uniformisation des ISBN
-- ------------------------------------------------------------

UPDATE books
SET ISBN = UPPER(TRIM(ISBN))
WHERE ISBN IS NOT NULL;


UPDATE ratings
SET ISBN = UPPER(TRIM(ISBN))
WHERE ISBN IS NOT NULL;


-- ------------------------------------------------------------
-- 2.2 Analyse des doublons et conflits bibliographiques
-- ------------------------------------------------------------

SELECT
    ISBN,
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT `Book-Title`) AS nb_titres,
    COUNT(DISTINCT `Book-Author`) AS nb_auteurs,
    COUNT(DISTINCT `Year-Of-Publication`) AS nb_annees,
    COUNT(DISTINCT Publisher) AS nb_editeurs
FROM books
GROUP BY ISBN
HAVING COUNT(*) > 1
ORDER BY nb_lignes DESC;


SELECT
    ISBN,
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT `Book-Title`) AS nb_titres,
    COUNT(DISTINCT `Book-Author`) AS nb_auteurs,
    COUNT(DISTINCT `Year-Of-Publication`) AS nb_annees,
    COUNT(DISTINCT Publisher) AS nb_editeurs
FROM books
GROUP BY ISBN
HAVING COUNT(*) > 1
   AND (
       COUNT(DISTINCT `Book-Title`) > 1
       OR COUNT(DISTINCT `Book-Author`) > 1
       OR COUNT(DISTINCT `Year-Of-Publication`) > 1
       OR COUNT(DISTINCT Publisher) > 1
   );


-- ------------------------------------------------------------
-- 2.3 Déduplication de Books
-- ------------------------------------------------------------

-- Conservation d'une seule ligne par ISBN.
-- Priorité :
-- 1. Cas particulier ISBN 051513628X.
-- 2. Informations bibliographiques les plus complètes.
-- 3. Titre le plus long.

CREATE TABLE books_dedup AS
SELECT
    ISBN,
    `Book-Title`,
    `Book-Author`,
    `Year-Of-Publication`,
    Publisher,
    `Image-URL-S`,
    `Image-URL-M`,
    `Image-URL-L`
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ISBN
            ORDER BY
                CASE
                    WHEN ISBN = '051513628X'
                     AND `Book-Title` =
                         'Key of Light (Key Trilogy (Paperback))'
                    THEN 1
                    ELSE 0
                END DESC,

                (
                    CASE WHEN `Book-Title` IS NOT NULL
                              AND TRIM(`Book-Title`) <> ''
                         THEN 1 ELSE 0 END
                    +
                    CASE WHEN `Book-Author` IS NOT NULL
                              AND TRIM(`Book-Author`) <> ''
                         THEN 1 ELSE 0 END
                    +
                    CASE WHEN `Year-Of-Publication` BETWEEN 1000 AND 2004