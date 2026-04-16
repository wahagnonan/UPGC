AREA_PAR_DEFAUT = 2
AREAS_PAR_DEFAUT = [2, 16]

AREAS = [
    {'id': 2, 'nom': 'Salle UPGC'},
    {'id': 16, 'nom': 'Salles louées'},
    {'id': 4, 'nom': 'Anglais'},
    {'id': 9, 'nom': 'Droit'},
    {'id': 10, 'nom': 'Économie'},
    {'id': 11, 'nom': 'Géographie'},
    {'id': 12, 'nom': 'Histoire'},
    {'id': 3, 'nom': 'IGA'},
    {'id': 5, 'nom': 'Lettres modernes'},
    {'id': 22, 'nom': 'Médecine'},
    {'id': 20, 'nom': 'Informatique'},
    {'id': 19, 'nom': 'Mathématiques'},
    {'id': 8, 'nom': 'MPC'},
    {'id': 13, 'nom': 'Philosophie'},
    {'id': 18, 'nom': 'Physique-Chimie'},
    {'id': 7, 'nom': 'SIC'},
    {'id': 6, 'nom': 'Sciences biologiques'},
    {'id': 14, 'nom': 'Sociologie'},
    {'id': 24, 'nom': 'Crous - Aires de jeux'},
    {'id': 21, 'nom': 'Enseignant'},
]

ROOMS_PAR_AREA = {
    2: [
        {'id': 2, 'nom': 'Amphi A'}, {'id': 3, 'nom': 'Amphi B'}, {'id': 4, 'nom': 'Amphi C'},
        {'id': 5, 'nom': 'TP/TD Salle A'}, {'id': 6, 'nom': 'TP/TD Salle B'}, {'id': 7, 'nom': 'TP/TD Salle C'},
        {'id': 8, 'nom': 'TP/TD Labo TP/A'}, {'id': 9, 'nom': 'TP/TD Labo TP/B'}, {'id': 10, 'nom': 'TP/TD Labo TP/C'},
        {'id': 11, 'nom': 'TD1 Labo TP/D'}, {'id': 12, 'nom': 'TD1 Salle E'}, {'id': 178, 'nom': 'TD1 Salle AUF'},
        {'id': 13, 'nom': 'TD1 Salle F'}, {'id': 14, 'nom': 'TD1 Salle G Studio MOOC'},
        {'id': 15, 'nom': 'TD1 Salle H'}, {'id': 16, 'nom': 'TD1 Salle I'}, {'id': 17, 'nom': 'TD1 Salle J'},
        {'id': 18, 'nom': 'TD1 Salle K'}, {'id': 19, 'nom': 'TD1 Salle L'}, {'id': 20, 'nom': 'TD1 Salle M'},
        {'id': 21, 'nom': 'TD1 Salle N'}, {'id': 22, 'nom': 'TD1 Salle O'}, {'id': 168, 'nom': 'TD1 Salle P'},
    ],
    16: [
        {'id': 210, 'nom': 'Lycée HB. Amphi'}, {'id': 218, 'nom': 'Lycée HB. Foyer'},
        {'id': 136, 'nom': 'LOGOKAHA S01'}, {'id': 137, 'nom': 'LOGOKAHA S02'}, {'id': 138, 'nom': 'LOGOKAHA S03'},
        {'id': 139, 'nom': 'LOGOKAHA S04'}, {'id': 140, 'nom': 'LOGOKAHA S05'}, {'id': 143, 'nom': 'LOGOKAHA S06'},
        {'id': 141, 'nom': 'LOGOKAHA S07'}, {'id': 142, 'nom': 'LOGOKAHA S08'}, {'id': 144, 'nom': 'LOGOKAHA S09'},
        {'id': 145, 'nom': 'LOGOKAHA S10'}, {'id': 146, 'nom': 'LOGOKAHA S11'}, {'id': 147, 'nom': 'LOGOKAHA S12'},
        {'id': 148, 'nom': 'LOGOKAHA S13'}, {'id': 149, 'nom': 'LOGOKAHA S14'}, {'id': 150, 'nom': 'LOGOKAHA S15'},
        {'id': 151, 'nom': 'LOGOKAHA S16'}, {'id': 152, 'nom': 'LOGOKAHA S17'}, {'id': 153, 'nom': 'LOGOKAHA S18'},
    ],
    4: [
        {'id': 36, 'nom': 'Licence 1'}, {'id': 37, 'nom': 'Licence 2'}, {'id': 38, 'nom': 'Licence 3'},
        {'id': 40, 'nom': 'Master 1 LCAC'}, {'id': 39, 'nom': 'Master 1 LDE'},
        {'id': 41, 'nom': 'Master 2 LCAC'}, {'id': 42, 'nom': 'Master 2 LDE'},
    ],
    9: [
        {'id': 87, 'nom': 'Licence 1'}, {'id': 88, 'nom': 'Licence 2'},
        {'id': 89, 'nom': 'Licence 3 Droit Privé'}, {'id': 90, 'nom': 'Licence 3 Droit Public'},
        {'id': 91, 'nom': 'Master 1 Droit des affaires'}, {'id': 92, 'nom': 'Master 1 Droit Juridique'},
        {'id': 93, 'nom': 'Master 1 Droit Public'}, {'id': 94, 'nom': 'Master 2 DDL'},
        {'id': 95, 'nom': 'Master 2 Droit Privé fondamental'}, {'id': 96, 'nom': 'Master 2 Droit Public fondamental'},
        {'id': 97, 'nom': 'Master 2 Professionnel DA'},
    ],
    10: [
        {'id': 98, 'nom': 'Licence 1'}, {'id': 99, 'nom': 'Licence 2'},
        {'id': 100, 'nom': 'Licence 3 Economie'}, {'id': 101, 'nom': 'Licence 3 Gestion'},
        {'id': 103, 'nom': 'Master 1 Economie'}, {'id': 102, 'nom': 'Master 1 Gestion'},
        {'id': 104, 'nom': 'Master 2 Economie'}, {'id': 105, 'nom': 'Master 2 Gestion'},
    ],
    11: [
        {'id': 106, 'nom': 'Licence 1'}, {'id': 107, 'nom': 'Licence 2'},
        {'id': 109, 'nom': 'Licence 3 GHE'}, {'id': 108, 'nom': 'Licence 3 GMEE'},
        {'id': 110, 'nom': 'Licence 3 GPE'}, {'id': 111, 'nom': 'Master 1 GHE'},
        {'id': 112, 'nom': 'Master 1 GMEE'}, {'id': 113, 'nom': 'Master 1 GPE'},
        {'id': 114, 'nom': 'Master 2 GHE'}, {'id': 115, 'nom': 'Master 2 GMEE'},
        {'id': 116, 'nom': 'Master 2 GPE'},
    ],
    12: [
        {'id': 117, 'nom': 'Licence 1'}, {'id': 118, 'nom': 'Licence 2'}, {'id': 119, 'nom': 'Licence 3'},
        {'id': 169, 'nom': 'Master 1 HAM'}, {'id': 170, 'nom': 'Master 1 HMC'},
        {'id': 171, 'nom': 'Master 2 HAM'}, {'id': 172, 'nom': 'Master 2 HMC'},
    ],
    3: [
        {'id': 23, 'nom': 'Licence 1 Tronc Commun'}, {'id': 24, 'nom': 'Licence 2 Agriculture'},
        {'id': 25, 'nom': 'Licence 2 EGA'}, {'id': 26, 'nom': 'Licence 2 Zootechnie'},
        {'id': 27, 'nom': 'Licence 3 Agriculture'}, {'id': 28, 'nom': 'Licence 3 EGA'},
        {'id': 29, 'nom': 'Licence 3 Zootechnie'}, {'id': 30, 'nom': 'Master 1 ADD'},
        {'id': 31, 'nom': 'Master 1 IZ'}, {'id': 32, 'nom': 'Master 1 MEOA'},
        {'id': 33, 'nom': 'Master 2 ADD'}, {'id': 34, 'nom': 'Master 2 IZ'}, {'id': 35, 'nom': 'Master 2 MEOA'},
    ],
    5: [
        {'id': 43, 'nom': 'Licence 1'}, {'id': 44, 'nom': 'Licence 2'}, {'id': 45, 'nom': 'Licence 3'},
        {'id': 47, 'nom': 'Master 1 LC'}, {'id': 46, 'nom': 'Master 1 LTDL'},
        {'id': 48, 'nom': 'Master 2 LC'}, {'id': 49, 'nom': 'Master 2 LTDL'},
    ],
    22: [
        {'id': 222, 'nom': 'Licence 1'}, {'id': 223, 'nom': 'Licence 2'}, {'id': 224, 'nom': 'Licence 3'},
        {'id': 225, 'nom': 'Master 1'}, {'id': 226, 'nom': 'Master 2'},
        {'id': 227, 'nom': 'Doctorat 1'}, {'id': 228, 'nom': 'Doctorat 2'},
    ],
    20: [
        {'id': 154, 'nom': 'Licence 2'}, {'id': 155, 'nom': 'Licence 3'},
        {'id': 156, 'nom': 'Master 1'}, {'id': 157, 'nom': 'Master 2'},
    ],
    19: [
        {'id': 158, 'nom': 'Licence 2'}, {'id': 159, 'nom': 'Licence 3'},
        {'id': 160, 'nom': 'Master 1'}, {'id': 161, 'nom': 'Master 2'},
    ],
    8: [
        {'id': 78, 'nom': 'Licence 1'}, {'id': 79, 'nom': 'Licence 2'},
    ],
    13: [
        {'id': 131, 'nom': 'Licence 1'}, {'id': 132, 'nom': 'Licence 2'},
        {'id': 231, 'nom': 'Licence 3 BPT'}, {'id': 230, 'nom': 'Licence 3 EAED'},
        {'id': 133, 'nom': 'Licence 3 MEP'}, {'id': 174, 'nom': 'Master 1 BPT'},
        {'id': 173, 'nom': 'Master 1 EAED'}, {'id': 166, 'nom': 'Master 1 MEP'},
        {'id': 175, 'nom': 'Master 2 BPT'}, {'id': 176, 'nom': 'Master 2 EAED'}, {'id': 177, 'nom': 'Master 2 MEP'},
    ],
    18: [
        {'id': 162, 'nom': 'Licence 2'}, {'id': 163, 'nom': 'Licence 3'},
        {'id': 164, 'nom': 'Master 1'}, {'id': 165, 'nom': 'Master 2'},
    ],
    7: [
        {'id': 70, 'nom': 'Licence 1'}, {'id': 71, 'nom': 'Licence 2'},
        {'id': 72, 'nom': 'Licence 3 CC'}, {'id': 73, 'nom': 'Licence 3 CD'},
        {'id': 75, 'nom': 'Master 1 CC'}, {'id': 74, 'nom': 'Master 1 CD'},
        {'id': 76, 'nom': 'Master 2 CC'}, {'id': 77, 'nom': 'Master 2 CD'},
    ],
    6: [
        {'id': 50, 'nom': 'Licence 1'}, {'id': 51, 'nom': 'Licence 2'},
        {'id': 53, 'nom': 'Licence 3 GBA'}, {'id': 52, 'nom': 'Licence 3 GRNOES'},
        {'id': 54, 'nom': 'Licence 3 PV'}, {'id': 56, 'nom': 'Licence 3 SA'},
        {'id': 55, 'nom': 'Licence 3 SVT'}, {'id': 57, 'nom': 'Licence 3 ZBAE'},
    ],
    14: [
        {'id': 120, 'nom': 'Licence 1'}, {'id': 121, 'nom': 'Licence 2'},
        {'id': 122, 'nom': 'Licence 3 GCDL'}, {'id': 123, 'nom': 'Licence 3 SE'},
        {'id': 124, 'nom': 'Licence 3 TE'}, {'id': 127, 'nom': 'Master 1 DL'},
        {'id': 126, 'nom': 'Master 1 SE'}, {'id': 125, 'nom': 'Master 1 TE'},
        {'id': 128, 'nom': 'Master 2 DL'}, {'id': 129, 'nom': 'Master 2 SE'}, {'id': 130, 'nom': 'Master 2 TE'},
    ],
    24: [
        {'id': 234, 'nom': 'Terrain Football 1'}, {'id': 235, 'nom': 'Terrain Football 2'},
        {'id': 236, 'nom': 'Terrain Basket 1'}, {'id': 237, 'nom': 'Terrain Basket 2'},
        {'id': 240, 'nom': 'Terrain Handball 1'}, {'id': 241, 'nom': 'Terrain Handball 2'},
        {'id': 238, 'nom': 'Terrain Volleyball 1'}, {'id': 239, 'nom': 'Terrain Volleyball 2'},
    ],
    21: [
        {'id': 204, 'nom': 'BALLO Abou Bakary'}, {'id': 205, 'nom': 'COULIBALY Kassoum'},
        {'id': 200, 'nom': 'DETOH Kolety'}, {'id': 201, 'nom': 'DIEDIE Gokou Herv'},
        {'id': 203, 'nom': 'DIOMANDE Adama'}, {'id': 209, 'nom': 'KONE Isaac Zakariya'},
        {'id': 208, 'nom': 'KOUASSI Kouacou'}, {'id': 202, 'nom': 'OUATTARA Dramane'},
    ],
}

CACHE_TIMEOUT = 300
