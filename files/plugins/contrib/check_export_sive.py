#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os                       # utilise pour recuperer les info du fichier tar.gz
import glob                     # utilise pour lister les fichiers
import time                     # Utilise pour la recuperer la date et l'heure
import tarfile                  # utilise pour de-tarer les fichiers
import datetime                 # utilise pour creer la liste des fichiers a verifier


# On initialise les variables
folder = "/home/ftpctp_sive/production/fromcanaltp/"                     # dossier ou ce trouve le fichier
date = time.strftime('%Y%m%d')                                  # on recupere la date du jours
date = str(date)                                                # convertie la date du jour en chaine de caractere
list_fic = []                                                   # Creation du liste vide qui contiendra la liste des fichiers
fic_generique = folder+"SIVE_EXPORT_"+date+"*.tar.gz"           # initialise le fichier avec la date du jour
erreur = False
rep_sonde_ok = "/home/ftpctp_sive/resultat_export/export_ok"    # repertoire a creer si l'export est OK
rep_sonde_ko = "/home/ftpctp_sive/resultat_export/export_ko"    # repertoire a creer si l'export est KO

list_fic = glob.glob(fic_generique)                             # liste les fichiers en date du jour dans une liste

# on test si un fichier est present
try:
    fichier = list_fic[0]                                 # Recupere le premiere fichier de la liste
except IndexError:
    print("Pas d'export SIVE present aujourd hui")
    if os.path.exists(rep_sonde_ok):
       os.rename(rep_sonde_ok,rep_sonde_ko)
    exit(2)

# on test l'heure de creation du fichier
time_fic = os.stat(fichier).st_mtime        # recupere la date du fichier (timestanp)
time_fic = time.strftime('%H%M',time.localtime(time_fic))
if time_fic > "0301" :                                    # test si le fichier a ete cree apres 03h00 si oui => KO
    print("L export SIVE a ete genere avec du retard")
    erreur = True

# TAR
tar = tarfile.open(fichier,"r:gz")                        # On va lire le fichier
for tarinfo in tar:
  list_fic.append((tarinfo.name))                         #Pour chaque fichier dans le tar.gz on ajoute sont nom a la liste
tar.close()                                               # on ferme le fichier

today = datetime.date.today()                             # recupere la date format "YYYY-MM-JJ"
one_day = datetime.timedelta(days=1)                      # varaible egale a une journee

# On crer une liste avec tous les fichiers desserte devant etre present
desserte = [str(today)+"_desserte.csv",str(today+one_day)+"_desserte.csv",str(today+one_day*2)+"_desserte.csv",str(today+one_day*3)+"_desserte.csv",str(today+one_day*4)+"_desserte.csv",str(today+one_day*5)+"_desserte.csv",str(today+one_day*6)+"_desserte.csv",str(today+one_day*7)+"_desserte.csv",str(today+one_day*8)+"_desserte.csv",str(today+one_day*9)+"_desserte.csv"]

# On crer une liste avec tous les fichiers tranche devant etre present
tranche = [str(today)+"_tranche.csv",str(today+one_day)+"_tranche.csv",str(today+one_day*2)+"_tranche.csv",str(today+one_day*3)+"_tranche.csv",str(today+one_day*4)+"_tranche.csv",str(today+one_day*5)+"_tranche.csv",str(today+one_day*6)+"_tranche.csv",str(today+one_day*7)+"_tranche.csv",str(today+one_day*8)+"_tranche.csv",str(today+one_day*9)+"_tranche.csv"]

#on test la presence des fichiers desserte
for fic_desserte in desserte :
    presence_fic = fic_desserte in list_fic
    if presence_fic == False:
        print("Il manque un fichier Desserte dans l export SIVE :",fic_desserte)
        if os.path.exists(rep_sonde_ok):
           os.rename(rep_sonde_ok,rep_sonde_ko)
        exit(2)

#on test la presence des fichiers desserte
for fic_tranche in tranche :
    presence_fic = fic_tranche in list_fic
    if presence_fic == False:
        print("Il manque un fichier Tranche dans l export SIVE")
        if os.path.exists(rep_sonde_ok):
           os.rename(rep_sonde_ok,rep_sonde_ko)
        exit(2)

#on test la presence du fichier equipement.csv
presence_fic = "equipement.csv" in list_fic
if presence_fic == False:
    print("Il manque le fichier equipement dans l export SIVE")
    if os.path.exists(rep_sonde_ok):
       os.rename(rep_sonde_ok,rep_sonde_ko)
    exit(2)

#on test la presence du fichier mode.csv
presence_fic = "mode.csv" in list_fic
if presence_fic == False:
    print("Il manque le fichier mode dans l export SIVE")
    if os.path.exists(rep_sonde_ok):
       os.rename(rep_sonde_ok,rep_sonde_ko)
    exit(2)

if not os.path.exists(rep_sonde_ok):    #Si tout est Ok on crer le repertoire /home/ftpctp_sive/export_ok
    os.rename(rep_sonde_ko,rep_sonde_ok)
#on test la variable erreur qui passe a 1 si il y a eu du retard dans la generation du fichier
if erreur == True:
    exit(1)

print("Export SIVE OK",)
exit(0)
