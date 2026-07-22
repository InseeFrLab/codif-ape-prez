# codif-ape-prez

Site web (Quarto) regroupant les présentations relatives à la codification
automatique de l'APE. Le site liste chaque présentation sous forme de tuile
(*card*) sur la page d'accueil, et chaque tuile ouvre un support reveal.js.

Site en ligne : <https://inseefrlab.github.io/codif-ape-prez/>

## Fonctionnement

- **Un seul projet Quarto** (`_quarto.yaml`) rend `slides/*/*.qmd`,
  `papers/*/*.qmd`, `index.qmd` et `cards/*.qmd`.
- **Une présentation** = un dossier `slides/<nom-du-dossier>/index.qmd` (format reveal.js).
- **La page d'accueil** (`index.qmd`) est un *listing* qui lit `cards/*.qmd`
  (triés par `order`) et affiche une tuile par présentation.
- **Déploiement** : à chaque push sur `main`, le workflow
  `.github/workflows/publish.yaml` reconstruit et publie sur GitHub Pages.

## Ajouter une présentation

1. **Créer le support** dans `slides/<nom-du-dossier>/index.qmd`. Front-matter minimal :

   ```yaml
   ---
   title: "Titre de la présentation"
   author: "Prénom Nom"
   date: "AAAA-MM-JJ"
   format:
     revealjs:              # ou onyxia-revealjs (thème maison, cf. slides/_extensions)
       output-file: index.html   # requis pour que le lien de la tuile fonctionne
   ---
   ```
   Placer les images/thèmes propres à la présentation dans `slides/<nom-du-dossier>/`
   (chemins relatifs). Le support doit être **auto-portant** : s'il utilise une
   extension Quarto (thème, plugins reveal.js), la copier dans
   `slides/<nom-du-dossier>/_extensions/`.

2. **Créer la tuile** `cards/cards<N>.qmd` (N = prochain numéro libre) :

   ```yaml
   ---
   title: Titre affiché sur la tuile
   image: url-ou-chemin-de-couverture      # ex. ../slides/<nom-du-dossier>/img/cover.png
   date: "AAAA-MM-JJ"
   description: |
     <b>Description :</b> une phrase.
   author: Prénom Nom
   slides:
     text: Slides
     url: /slides/<nom-du-dossier>/index.html
   order: <N>
   ---
   ```

3. **Vérifier en local** sans installer les dépendances (R/Python) des autres
   supports : restreindre temporairement la liste `render:` de `_quarto.yaml`,

   ```yaml
   render:
     - /slides/<nom-du-dossier>/*.qmd
     - index.qmd
     - cards/*.qmd
   ```
   puis `quarto preview` (ou `quarto render slides/<nom-du-dossier>/index.qmd` pour le seul
   support). **Rétablir la liste `render:` d'origine avant de committer.**

4. **Contribuer** : créer une branche, committer, ouvrir une *Pull Request*.

## Développement complet

`. setup.sh` à la racine installe les dépendances (certains supports utilisent
`R` et des données S3). Nécessaire uniquement pour rendre l'ensemble du site.
