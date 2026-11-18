-- ============================================================
-- PROJET : BOOK RECOMMENDATION DATASET
-- FICHIER : 01_creation_structure.sql
-- OBJET   : Structuration relationnelle de la base de données
-- ============================================================

-- IMPORTANT :
-- Ce script intervient après l'importation des fichiers CSV.
-- Les tables doivent déjà exister.
-- Les clés primaires et étrangères ne doivent pas déjà exister.


-- ============================================================
-- 1. VERIFICATION PREALABLE DE LA STRUCTURE
-- ============================================================

DESCRIBE books;
DESCRIBE users;
DESCRIBE ratings;


-- ============================================================
-- 2. VERIFICATION DE L'UNICITE DES IDENTIFIANTS
-- ============================================================

-- Vérification des ISBN en double

SELECT ISBN, COUNT(*) AS nb_occurrences
FROM books
GROUP BY ISBN
HAVING COUNT(*) > 1;


-- Vérification des User-ID en double

SELECT `User-ID`, COUNT(*) AS nb_occurrences
FROM users
GROUP BY `User-ID`
HAVING COUNT(*) > 1;


-- Vérification des identifiants manquants

SELECT COUNT(*) AS isbn_null
FROM books
WHERE ISBN IS NULL OR TRIM(ISBN) = '';


SELECT COUNT(*) AS user_id_null
FROM users
WHERE `User-ID` IS NULL;


-- ============================================================
-- 3. DEFINITION DES CLES PRIMAIRES
-- ============================================================

-- Clé primaire de Books
-- À exécuter uniquement si elle n'existe pas déjà.

ALTER TABLE books
ADD PRIMARY KEY (ISBN);


-- Clé primaire de Users
-- À exécuter uniquement si elle n'existe pas déjà.

ALTER TABLE users
ADD PRIMARY KEY (`User-ID`);


-- ============================================================
-- 4. VERIFICATION DES UTILISATEURS ORPHELINS
-- ============================================================

-- Les évaluations dont le User-ID ne correspond à aucun
-- utilisateur doivent être identifiées avant la création
-- de la clé étrangère.

SELECT
    COUNT(*) AS nb_users_orphelins
FROM ratings r
LEFT JOIN users u
    ON r.`User-ID` = u.`User-ID`
WHERE u.`User-ID` IS NULL;


-- ============================================================
-- 5. CREATION DE LA CLE ETRANGERE USERS - RATINGS
-- ============================================================

-- Relation Users (1) -> Ratings (N)
-- À exécuter uniquement après traitement des utilisateurs
-- orphelins et vérification de l'absence de cette contrainte.

ALTER TABLE ratings
ADD CONSTRAINT fk_ratings_users
FOREIGN KEY (`User-ID`)
REFERENCES users (`User-ID`);


-- ============================================================
-- 6. VERIFICATION DES CONTRAINTES
-- ============================================================

-- Vérification des clés étrangères

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- Vérification des clés et index

SHOW KEYS FROM books;
SHOW KEYS FROM users;
SHOW KEYS FROM ratings;


-- Vérification de la structure finale

SHOW CREATE TABLE books;
SHOW CREATE TABLE users;
SHOW CREATE TABLE ratings;


-- ============================================================
-- FIN DU SCRIPT DE STRUCTURATION
-- ============================================================
