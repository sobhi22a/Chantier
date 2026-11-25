# Référentiel géographique (données, pas du code)

- `wilayas.json` : les 58 wilayas (découpage de 2019). **À confirmer** sur le Journal officiel (joradp.dz) : un découpage à 69 wilayas
  est annoncé (H-14, question Q-11). Pour le mettre à jour, modifier ce fichier : le démarrage de l'API **ajoute** les lignes absentes
  (il ne modifie ni ne supprime jamais une ligne existante).
- `communes.json` : **extrait non officiel** (communes de la wilaya de Blida, utilisées par les données de démonstration).
  La liste complète des communes est à fournir avant la mise en service ; en attendant, le formulaire de chantier accepte
  une commune hors liste (saisie libre).
- Format : `code` à deux chiffres, `nameFr`, `nameAr` ; pour une commune : `wilayaCode`, `nameFr`, `nameAr`.
- Les traductions arabes sont à faire relire par un arabophone du terrain (H-19, Q-12).
