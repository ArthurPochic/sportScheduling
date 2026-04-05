# Sports Scheduling Optimization — CP Optimizer (OPL)

Modélisation et extension d'un problème de planification sportive avec IBM ILOG CPLEX Optimization Studio.

> Projet réalisé par **Arthur POCHIC** et **Kenza MOUHARRAR**  
> Encadré par **Maria MALEK** — ING3 DS 2025/2026, CY Tech

---

## Description du problème

Le sports scheduling consiste à organiser les rencontres entre équipes sur une période donnée en respectant des contraintes logistiques et sportives, tout en optimisant certains objectifs comme l'équité ou le réalisme du calendrier.

Dans notre configuration :

| Paramètre | Valeur | Signification |
|---|---|---|
| `nbTeamsInDivision` | 7 ou 8 | Équipes par division (max 16) |
| `nbIntraDivisional` | 1 | Rencontres par paire intra-division |
| `nbInterDivisional` | 1 | Rencontres par paire inter-division |
| `nbWeeks` | 13 ou 15 | Calculé automatiquement |

Chaque équipe affronte toutes les autres équipes exactement une fois, ce qui détermine le nombre de semaines de la saison.

---

## Modélisation

### Variables de décision

| Variable | Domaine | Description |
|---|---|---|
| `plays[t][w]` | `1..nbTeams` | Adversaire de l'équipe `t` à la semaine `w` |
| `home[t][w]` | `{0, 1}` | 1 si l'équipe `t` joue à domicile en semaine `w`, 0 sinon |

### Fonction objectif

Maximiser `DivisionalLateness` : la somme pondérée des matchs intra-division, où le poids d'un match placé en semaine `w` vaut `w²`. Cela favorise les matchs les plus importants en fin de calendrier.

```
max  1/2 × Σ_{t ∈ Teams} Σ_{w ∈ Weeks}  Gain(t, plays[t][w], w)

avec  Gain(t1, t2, w) = w²  si intra-division, 0 sinon
```

### Contraintes du modèle original

1. **Pas d'auto-match** — `plays[t][w] ≠ t`
2. **Symétrie des matchs** — `plays[plays[t][w]][w] = t`
3. **Un seul match par semaine** — `allDifferent(plays[t][w] ∀t)` par semaine
4. **Nombre correct de matchs** — `count(plays[t1][w] = t2) = nbIntra` si même division, `nbInter` sinon
5. **Pas de matchs consécutifs** — `plays[t][w] ≠ plays[t][w+1]`
6. **Première mi-saison** — au moins `⌊nbWeeks/3⌋` matchs intra-division dans les semaines `1..⌊nbWeeks/2⌋`

### Extension : gestion domicile / extérieur

Dans sa version initiale, le modèle ne distingue pas le lieu des rencontres. L'ajout de la dimension domicile/extérieur permet d'assurer une équité entre les équipes, de limiter les déplacements et de rendre le calendrier plus réaliste.

**C7 — Symétrie domicile/extérieur :**
```
home[plays[t][w]][w] = 1 − home[t][w]
```
Si une équipe joue à domicile, son adversaire joue automatiquement à l'extérieur.

**C8 — Équilibre domicile/extérieur :**
```
|Σ_{w ∈ Weeks} home[t][w] − ⌊nbWeeks/2⌋| ≤ 1
```
Chaque équipe joue autant de matchs à domicile qu'à l'extérieur (à ±1 près si nbWeeks est impair).

**C9/C10 — Limitation des séries :**
```
home[t][w] + home[t][w+1] + home[t][w+2] ≤ 2
(1−home[t][w]) + (1−home[t][w+1]) + (1−home[t][w+2]) ≤ 2
```

---

## Fichiers

```
├── sportsCPO.mod   # Modèle OPL (CP Optimizer)
├── sports.dat      # Données (équipes, paramètres)
└── README.md
```

---

## Comment lancer le projet

1. Ouvrir **IBM ILOG CPLEX Optimization Studio**
2. Importer ou ouvrir le dossier du projet
3. Dans le panneau **OPL Projects**, faire un clic droit sur le projet → **New Run Configuration…**
4. Définir `sportsCPO.mod` comme model file et `sports.dat` comme data file
5. Cliquer **Finish**, puis double-cliquer sur la configuration et cliquer **Run**

La sortie s'affiche dans la console **OPL Output**.

---

## Résultats

La solution est affichée semaine par semaine avec les conventions suivantes :

- `[D]` : équipe jouant à domicile
- `[E]` : équipe jouant à l'extérieur
- `*` : match intra-division

Exemple de sortie (7 équipes/division, objectif = 2652) :

```
On week 2
  *[E] Cleveland Browns vs Tennessee Titans
  *[D] Atlanta Falcons vs Carolina Panthers
  *[D] Cincinnati Bengals vs Indianapolis Colts
   [E] Houston Texans vs New Orleans Saints

On week 13
  *[E] Cincinnati Bengals vs Tennessee Titans
  *[D] Houston Texans vs Jacksonville Jaguars
  *[D] Green Bay Packers vs Carolina Panthers
```

Les résultats confirment que le calendrier respecte l'alternance domicile/extérieur, qu'aucune équipe ne présente de longue série dans un même lieu, et que l'équilibre global est assuré.

### Impact de l'extension sur la complexité

L'ajout de `home[t][w]` augmente significativement la taille du problème. Pour obtenir une solution avec la version gratuite du solveur, il a été nécessaire de réduire le nombre d'équipes à **7 par division** (au lieu de 8). Cette réduction permet de garder le problème tractable tout en illustrant l'efficacité du modèle.

---

## Modifier les paramètres

Le fichier `sports.dat` permet d'ajuster la structure de la saison :

- `nbTeamsInDivision` : entre 2 et 16 (les deux listes contiennent 16 équipes NFL)
- `nbIntraDivisional` / `nbInterDivisional` : modifier ces valeurs change automatiquement `nbWeeks`
- Un `nbIntraDivisional` élevé réduit la tension entre la contrainte de première mi-saison et l'objectif

La limite de temps est fixée à **60 secondes** dans le bloc `execute` du `.mod`.

---

## Conclusion

Ce projet illustre les défis liés à la planification combinatoire dans le domaine sportif. La modélisation via CP Optimizer permet de générer des calendriers équilibrés, respectant à la fois les règles sportives et les impératifs logistiques.

L'introduction de la dimension domicile/extérieur enrichit le modèle et le rapproche de la réalité, tout en augmentant sa complexité. Ce travail constitue une base pour des extensions futures : disponibilités des stades, horaires de diffusion, préférences des équipes, ou passage à des ligues plus importantes.

---

## Credits

This project is based on the sports scheduling example provided with IBM ILOG CPLEX Optimization Studio.

Modifications and extensions:
- Added home/away (domicile/extérieur) constraints
- Implemented additional scheduling rules
