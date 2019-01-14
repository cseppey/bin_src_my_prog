#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>

#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

#include <algorithm>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patates" << endl;
  
  // établissement du flux pour l'ouverture des fichiers fastq

  string pathDosFaIn = argv[1],
         pathFaOut = argv[2],
         pathDosInt = argv[5],
         mkdir,
         rmdir;

  int seuilNbRep = atoi( argv[3] ),
      seuilNbPres = atoi( argv[4] );

  DIR *DH( 0 );
  DH = opendir( pathDosFaIn.c_str() );

  struct dirent *nomFichier( 0 );
  struct stat filestat;

  ofstream outPathFH( pathFaOut );


  mkdir = "mkdir -p " + pathDosInt;
  rmdir = "rm -r " + pathDosInt;

  system( mkdir.c_str() );
  
  // liste d'échs

  set<string> Sechs;

  map<string, pair<int, int>> MseqTot;       // map>seq, pair<nb_ech_trouve, nb_occ_dataset>>

  while( nomFichier = readdir( DH ) ) {
    string pathFaIn( pathDosFaIn + "/" + nomFichier->d_name );
    if ( stat( pathFaIn.c_str(), &filestat )) continue;
    if ( S_ISDIR( filestat.st_mode )) continue;
    string nomFa( nomFichier->d_name );
    Sechs.insert( nomFa.c_str() );
  }

  // parcourt du répertoire et décompte sÉquences pour chaque fa
  
  cout << "parcourt" << endl;

  for( set<string>::iterator it = Sechs.begin(); it != Sechs.end(); it++ ) {
  
    string pathFaIn( pathDosFaIn + "/" + *it ),
           pathInt( pathDosInt + "/" + *it );

    ifstream inPathFaFH( pathFaIn );

    ofstream outIntEch( pathInt );

    string ligne,
           noEch;

    // calcul nb digit
    istringstream iss( *it );
    while( getline( iss, ligne, '.' ) ) {
      noEch = ligne;
      break;
    }

    cout << noEch << endl;

    // parcourt fasta
    
    map<string, int> Mseq;
    
    while( getline( inPathFaFH, ligne ) ) {

      if( ligne.at( 0 ) != '>' ) {

        // si première rencontre de la séquence
        if( Mseq.find( ligne ) == Mseq.end() ) {
          Mseq.insert( pair<string, int>( ligne, 1 ) );
          if( MseqTot.find( ligne ) == MseqTot.end() ) {
            pair<int, int> p( 1, 1 );
            MseqTot.insert( pair<string, pair<int, int>>( ligne, p ) );
          } else {
            MseqTot[ligne].first++;
            MseqTot[ligne].second++;
          }
        } 
        // si seq déjà rencontré
        else {
          Mseq[ligne]++;
          MseqTot[ligne].second++;
        }
      }

    }

    inPathFaFH.close();

    for( map<string, int>::iterator jt = Mseq.begin(); jt != Mseq.end(); jt++ ) {
      outIntEch << jt->first << '\t' << noEch << '\t' << jt->second << endl;
    }

    outIntEch.close();

  }

  // seq par seq

  cout << "decompte" << endl;

  int noSeq( 1 );

  for( map<string, pair<int, int>>::iterator it = MseqTot.begin(); it != MseqTot.end(); it++ ) {
    
    if( it->second.first >= seuilNbPres && it->second.second >= seuilNbRep ) {

      int sum( 0 );
      map<string,int> Mcnt;

      for( set<string>::iterator jt = Sechs.begin(); jt != Sechs.end(); jt++ ) {

        string pathIntEch( pathDosInt + '/' + *jt ),
               ligne,
               partLigne,
               noE;

        vector<string> lignesEch;

        ifstream inPathInt( pathIntEch );

        istringstream iss( *jt );
        while( getline( iss, partLigne, '.' ) ) {
          noE = partLigne;
          break;
        }

        // recherche de la réponse pour la séquence dans l'échantillon si non nul

        while( getline( inPathInt, ligne ) ) {

          if( ligne.find( it->first ) != std::string::npos ) {
            int indPartLigne( 0 );
            string partLigne;
            istringstream iss( ligne );
            while( getline( iss, partLigne, '\t' ) ) {
              if( indPartLigne == 2 ){
                Mcnt.insert( pair<string, int>( noE, atoi( partLigne.c_str() ) ) );
                sum += atoi( partLigne.c_str() );
              }
              indPartLigne++;
            }
          } else {
            lignesEch.push_back( ligne );
          }

        }

        inPathInt.close();

        // si réponse de la séquenc dans l'échantillon nul

        if( Mcnt.find( noE ) == Mcnt.end() ) {
          Mcnt.insert( pair<string, int>( noE, 0 ) );
        }

        // réécriture du fichier int
        
        ofstream outPathInt( pathIntEch );

        for( int k = 0; k < lignesEch.size(); k++ ) { 
          outPathInt << lignesEch[k] << endl;
        }

        outPathInt.close();

      }

      // écriture du fichier dérépliqué
      
      if( sum >= seuilNbRep ) {

        outPathFH << noSeq << '_' << sum;
        for( map<string, int>::iterator jt = Mcnt.begin(); jt != Mcnt.end(); jt++ ) {
          outPathFH << '-' << jt->first << '_' << jt->second;
        }
        outPathFH << endl << it->first << endl;

        noSeq++;
      }

    }
  }
    
  outPathFH.close();

  system( rmdir.c_str() );

  //

  cout << "pilées" << endl;
  return(0);
}

