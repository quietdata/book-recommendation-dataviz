# Analyse et datavisualisation
### Book Recommendation Dataset (SQL et PowerBI)

Ce projet représente un pipeline complet d'exploration et de visualisation de données réalisé à partir du jeu de données ouvert
Book Recommendation Dataset (issu de la communauté *Book-Crossing* sur Kaggle).  
L'objectif est d'importer, nettoyer, interroger et visualiser les habitudes de lecture de plus de 270000 ouvrages.


## Architecture et outils utilisés

Sources de données : https://www.kaggle.com/datasets/arashnic/book-recommendation-dataset/data
* Books.csv : ~271 000 livres (ISBN, titre, auteur, année de publication, éditeur, couvertures)
* Users.csv : ~278 000 utilisateurs inscrits (identifiant, localisation, âge)
* Ratings.csv : ~1 000 000 interactions (notes de 0 à 100)

Base de données & requêtage : Navicat (importation des fichiers csv, création des tables et requêtes sql exploratoires)

ETL, modélisation et Dataviz : Power BI Desktop (nettoyage Power Query, modèle en étoile, mesures DAX, analyses visuelles)


## Défis techniques & préparation des données (Data cleaning)

Avant de concevoir les tableaux de bord, un important travail de fiabilisation a été mené dans ***Navicat*** et ***Power Query***  

&emsp; Nettoyage de clé de jointure (ISBN) : normalisation (Power BI sensible à la casse), suppression des caractères invisibles non imprimables …
		afin d'établir des relations propres de type 1 à plusieurs (1:*).  

&emsp; Distinction des évaluations implicites et explicites : dans le dataset, la note 0 correspond à une évaluation implicite (livre ajouté sans note).  
&emsp; &emsp; Des mesures DAX dédiées ont été créées pour isoler les véritables notes ([1; 10]) et éviter de fausser les moyennes.  

&emsp; Traitement des données aberrantes :  
&emsp; &emsp; &emsp; Année de publication : filtrage de la période pertinente pour écarter les erreurs de saisie (0, 2050, …) et tenir compte de la période de collecte des données (Août/Septembre 2004)  
&emsp; &emsp; &emsp; Géographie : Location contient 3 information géographiques dont le pays, extraction du pays après la dernière virgule, suppression des caractères non alphabétiques  
&emsp; &emsp; &emsp; Age des lecteurs : Création de tranches d'âge cohérentes en isolant les valeurs manquantes ou aberrantes (<5, >100)


## Structure du rapport Power BI

Vue d'ensemble : indicateurs clés du catalogue, volume d'interactions vs votes explicites, courbe historique des publications (pic en 2002).  

Analyse des livres et auteurs : classements des œuvres les plus populaires, et des livres les mieux notés (avec un seuil minimum de 50 votes explicites 		pour éviter le biais des petits échantillons)  

Analyse des éditeurs : Répartition des parts de catalogue (Treemap) et croisement entre volume  

Profil des utilisateurs  

Explorateur de recommandations (interactif) : outil de recherche dynamique par auteur, titre et décennie avec affichage des couvertures de livres et 		jauge comparative par rapport à la moyenne globale (~7,6 / 10).


## Contenu du dépôt

sql : scripts sql réalisés sous Navicat (création de structure, nettoyage et requêtes d'analyse)

Book_recommendation_screen.pdf : export PDF de l'ensemble des pages pour une consultation rapide sans Power BI
	

## Principaux enseignements et regard critique

### Ce qu'on retient des données :  

&emsp; Un marché très concentré : Quelques best-sellers mondiaux et grands éditeurs généralistes concentrent l'essentiel des volumes d'évaluations, face à une longue queue d'ouvrages et d'éditeurs spécialisés très bien notés.  

&emsp; Des lecteurs bienveillants : Lorsqu'ils attribuent une note explicite (>0), les utilisateurs évaluent positivement leurs lectures avec une moyenne autour de 7,6 / 10.

### Limites :  

&emsp; Biais temporel et géographique : la période de collecte des données (Août/Septembre 2004), les données provenant majoritairement d'un public anglophone (USA, UK …) limitant la représentativité actuelle.  

&emsp; Absence de variable sur le genre littéraire : le fichier source ne comporte pas de colonne "Catégorie" ou "Genre" (policier, science-fiction …), qui rajouterait une finesse d'analyse des préférences.



## Perspectives d'évolution

Data Prep : Bien qu'un premier nettoyage ait été effectué sous Navicat et Power Query, un traitement approfondi en amont
		(via Python ou un outil ETL dédié) serait idéal pour normaliser les titres de livres multi-éditions, harmoniser les noms des auteurs et standardiser l'ensemble des localisations géographiques  

Enrichissement du catalogue : un croisement avec des bases externes permettrait de récupérer les genres littéraires.

Ouverture vers le Big Data et le Deep Learning : croiser les 278 000 utilisateurs et les  271 000 livres génère plus de 75 milliards de combinaisons, dont la quasi totalité est vide (chaque lecteur n'ayant évalué qu'une infime fraction du catalogue, environ 1 million de notes).  
&emsp; Pour entraîner un véritable moteur de recommandation sur un tel volume sans saturer un ordinateur classique, la suite logique consisterait à 		basculer vers un environnement Big Data et explorer dans un second temps, des approches de recommandation par Deep Learning
	
