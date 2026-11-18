
-- ============================================================
-- PROJET : BOOK RECOMMENDATION DATASET
-- FICHIER : 03_requetes_analyse.sql
-- OBJET   : Analyses exploratoires et statistiques descriptives
-- ============================================================


-- ============================================================
-- 1. VUE D'ENSEMBLE DU DATASET
-- ============================================================


-- Nombre total de livres

SELECT
    COUNT(*) AS total_books
FROM books;


-- Nombre total d'utilisateurs

SELECT
    COUNT(*) AS total_users
FROM users;


-- Nombre total d'évaluations

SELECT
    COUNT(*) AS total_ratings
FROM ratings;


-- Nombre de livres distincts

SELECT
    COUNT(DISTINCT ISBN) AS isbn_distincts
FROM books;


-- Nombre d'utilisateurs distincts

SELECT
    COUNT(DISTINCT `User-ID`) AS users_distincts
FROM users;


-- Nombre d'ISBN distincts évalués

SELECT
    COUNT(DISTINCT ISBN) AS isbn_evalues
FROM ratings;


-- ============================================================
-- 2. ANALYSE DES LIVRES
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 Top 10 des livres les plus évalués
-- ------------------------------------------------------------

SELECT
    b.ISBN,
    b.`Book-Title`,
    b.`Book-Author`,
    COUNT(r.ISBN) AS nombre_evaluations
FROM books b
INNER JOIN ratings r
    ON b.ISBN = r.ISBN
GROUP BY
    b.ISBN,
    b.`Book-Title`,
    b.`Book-Author`
ORDER BY nombre_evaluations DESC
LIMIT 10;


-- ============================================================
-- 3. ANALYSE DES AUTEURS
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 Top 10 des auteurs les plus évalués
-- ------------------------------------------------------------

-- Exclusion des auteurs manquants pour éviter
-- une catégorie sans nom dans le classement.

SELECT
    b.`Book-Author`,
    COUNT(r.ISBN) AS nombre_evaluations,
    COUNT(DISTINCT b.ISBN) AS nombre_livres
FROM books b
INNER JOIN ratings r
    ON b.ISBN = r.ISBN
WHERE b.`Book-Author` IS NOT NULL
  AND TRIM(b.`Book-Author`) <> ''
GROUP BY b.`Book-Author`
ORDER BY nombre_evaluations DESC
LIMIT 10;


-- ============================================================
-- 4. ANALYSE DES EVALUATIONS
-- ============================================================


-- ------------------------------------------------------------
-- 4.1 Répartition des notes
-- ------------------------------------------------------------

-- Les notes égales à 0 correspondent aux évaluations implicites.
-- Elles sont conservées dans cette analyse de la répartition
-- globale, mais doivent être exclues des calculs de moyenne.

SELECT
    `Book-Rating`,
    COUNT(*) AS nombre_evaluations
FROM ratings
GROUP BY `Book-Rating`
ORDER BY `Book-Rating`;


-- ------------------------------------------------------------
-- 4.2 Répartition des notes explicites uniquement
-- ------------------------------------------------------------

-- Les notes explicites sont comprises entre 1 et 10.

SELECT
    `Book-Rating`,
    COUNT(*) AS nombre_evaluations
FROM ratings
WHERE `Book-Rating` BETWEEN 1 AND 10
GROUP BY `Book-Rating`
ORDER BY `Book-Rating`;


-- ------------------------------------------------------------
-- 4.3 Distinction entre évaluations implicites et explicites
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN `Book-Rating` = 0
            THEN 'Evaluation implicite'
        WHEN `Book-Rating` BETWEEN 1 AND 10
            THEN 'Evaluation explicite'
        ELSE 'Valeur invalide'
    END AS type_evaluation,
    COUNT(*) AS nombre_evaluations
FROM ratings
GROUP BY type_evaluation
ORDER BY type_evaluation;


-- ------------------------------------------------------------
-- 4.4 Moyenne des notes explicites
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS nombre_notes_explicites,
    ROUND(AVG(`Book-Rating`), 2) AS note_moyenne,
    MIN(`Book-Rating`) AS note_minimale,
    MAX(`Book-Rating`) AS note_maximale
FROM ratings
WHERE `Book-Rating` BETWEEN 1 AND 10;


-- ------------------------------------------------------------
-- 4.5 Identification des notes invalides
-- ------------------------------------------------------------

-- Vérification des notes NULL, négatives ou supérieures à 10.

SELECT
    `Book-Rating`,
    COUNT(*) AS nombre_evaluations
FROM ratings
WHERE `Book-Rating` IS NULL
   OR `Book-Rating` < 0
   OR `Book-Rating` > 10
GROUP BY `Book-Rating`
ORDER BY `Book-Rating`;


-- ============================================================
-- FIN DU SCRIPT D'ANALYSE
-- ============================================================
