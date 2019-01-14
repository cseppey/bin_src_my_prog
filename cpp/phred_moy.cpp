#include <fstream>
#include <iostream>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#include <vector>
#include <numeric>

using namespace std;

#include <Bpp/Seq/Alphabet.all>
#include <Bpp/Seq/Sequence.h>
#include <Bpp/Seq/SequenceWithQuality.h>
#include <Bpp/Seq/Io.all>
#include <Bpp/Seq/Container/SiteContainerTools.h>

using namespace bpp;


// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patate" << endl;
  
  // établissement du flux pour l'ouverture des fichiers fastq

  string nomDosEntre = argv[1];

  DIR *DH(0);
  DH = opendir( nomDosEntre.c_str());
  
  struct dirent *nomFichier(0);
  struct stat filestat;

  // établissement du flux de sortie
 
  string nomFichierSortie = argv[2];
 
  ofstream outputFH( nomFichierSortie.c_str() );
 
  // établissement de variable fq

  DNA *alpha(0);
  alpha = new DNA;

  Fastq fq;

  while ( nomFichier = readdir( DH )){

    // établissement du flux pour l'ouverture des fichiers fastq

    string cheminFichierEntre = nomDosEntre + "/" + nomFichier->d_name;

    if ( stat(cheminFichierEntre.c_str(), &filestat )) continue;
    if ( S_ISDIR( filestat.st_mode )) continue;

    cout << cheminFichierEntre << endl;
  
    ifstream inputFH;
    inputFH.open( cheminFichierEntre.c_str() );
    
    // boucle sur toute les séquences du fastq
  
    SequenceWithQuality seqFq ( alpha );
  
    while ( fq.nextSequence( inputFH, seqFq )) {
      
      // déphrédage
      
      vector<int> qual = seqFq.getQualities();
      double mean = accumulate( qual.begin(), qual.end(), 0.0) / qual.size();
  
      outputFH << mean - 33 << endl;
  
    }

    inputFH.close();
  }
  outputFH.close();

  //

  return(0);
}

