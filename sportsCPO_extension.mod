// Extension : gestion domicile / extérieur
// Auteurs : Arthur POCHIC, Kenza MOUHARRAR — CY Tech 2025/2026

///Ajout de la variable home
dvar int home[Teams][Weeks] in 0..1;  // 1 = domicile, 0 = extérieur

subject to {
	// Symétrie : si t joue à domicile, son adversaire joue à l'extérieur
  forall(t in Teams, w in Weeks)
      homeSymmetry:
      home[plays[t][w]][w] == 1 - home[t][w];

  // Équilibre domicile/extérieur (à ±1 près)
  forall(t in Teams)
      homeBalance:
      abs(sum(w in Weeks) home[t][w] - ftoi(floor(nbWeeks/2))) <= 1;

  // Pas plus de 2 matchs consécutifs au même lieu
  forall(t in Teams, w in 1..nbWeeks-2)
      noLongHomeRun:
      home[t][w] + home[t][w+1] + home[t][w+2] <= 2;
  forall(t in Teams, w in 1..nbWeeks-2)
      noLongAwayRun:
      (1-home[t][w]) + (1-home[t][w+1]) + (1-home[t][w+2]) <= 2;
}
