#include <fstream>
#include <iostream>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#include <vector>
#include <algorithm>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  // établissement du flux pour l'ouverture des fichiers fasta

  string nomDosEntre = argv[1];
  string nomFichierSortie = argv[2];

  ofstream outputFH( nomFichierSortie.c_str() );

  DIR *DH(0);
  DH = opendir( nomDosEntre.c_str());
  
  struct dirent *nomFichier(0);
  struct stat filestat;

  // boucle sur les fichiers fasta 

  while (( nomFichier = readdir( DH ) )) {

    // établissement du flux d'entré

    string cheminFichierEntre = nomDosEntre + "/" + nomFichier->d_name;

    if ( stat(cheminFichierEntre.c_str(), &filestat )) continue;
    if ( S_ISDIR( filestat.st_mode )) continue;

    ifstream inputFH;
    inputFH.open( cheminFichierEntre );
    
    // établissement du no du fasta

    string noFasta = nomFichier->d_name;

    cout << cheminFichierEntre << endl;

    // boucle sur les lignes

    string titreFa;
    string ligne;
    while ( getline( inputFH, ligne )) {
      if ( ligne.at(0) == '>' ) {
        titreFa = ligne + " " + noFasta;
      }
      else {
          outputFH << titreFa << endl;
          outputFH << ligne << endl;
      }

    }

    inputFH.close();

  }

  outputFH.close();

  //

  return(0);
}

