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
         pathFaOut = argv[2];

  int seuilNbRep = atoi( argv[3] ),
      seuilNbPres = atoi( argv[4] );

  DIR *DH( 0 );
  DH = opendir( pathDosFaIn.c_str() );

  struct dirent *nomFichier( 0 );
  struct stat filestat;

  ofstream outPathFH( pathFaOut );

  // liste d'échs

  set<string> Sechs;

  while( nomFichier = readdir( DH ) ) {
    string pathFaIn( pathDosFaIn + "/" + nomFichier->d_name );
    if ( stat( pathFaIn.c_str(), &filestat )) continue;
    if ( S_ISDIR( filestat.st_mode )) continue;
    string nomFa( nomFichier->d_name );
    Sechs.insert( nomFa.c_str() );
  }

  // parcourt du répertoire et recuperation des sequences
  
  map<string, map<string, int>> MseqEchs;   // map<seq, map<noEch, rep>>

  for( set<string>::iterator it = Sechs.begin(); it != Sechs.end(); it++ ) {
  
    string pathFaIn( pathDosFaIn + "/" + *it );

    ifstream inPathFaFH( pathFaIn );
    
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
    
    while( getline( inPathFaFH, ligne ) ) {

      if( ligne.at( 0 ) != '>' ) {

        // si première rencontre de la séquence
        
        if( MseqEchs.find( ligne ) == MseqEchs.end() ) {

          map<string, int> Mcomptes;
          for( set<string>::iterator jt = Sechs.begin(); jt != Sechs.end(); jt++ ) {
            string partLigne,
                   noEch2;
            istringstream iss( *jt );
            while( getline( iss, partLigne, '.' ) ) {
              noEch2 = partLigne;
              break;
            }

            Mcomptes.insert( pair<string, int>( noEch2, 0 ) );
          }

          Mcomptes[noEch]++;

          MseqEchs.insert( pair<string, map<string, int>>( ligne, Mcomptes ) );
        }

        // si sequence rencontre au paravent

        else {
          MseqEchs[ligne][noEch]++;
        }

      }

    }

    inPathFaFH.close();

  }
    
  // somme pour chaque séquence derep
  
  multimap<int, pair<string, map<string, int>>> MMdecSeqEchs;   // multimap<sommeReps, pair<seq, map<noEch, rep>>>

  for( map<string, map<string, int>>::iterator it = MseqEchs.begin(); it != MseqEchs.end(); it++ ) {
    
    int dec( 0 );
    map<string, int> M( it->second );

    for( map<string, int>::iterator jt = M.begin(); jt != M.end(); jt++ ) {
      dec += jt->second;
    }

    pair<string, map<string, int>> p( it->first, it->second );
    
    MMdecSeqEchs.insert( pair<int, pair<string, map<string, int>>>( dec, p ) );

  }


  // écriture du fichier dereplique

  int indSeqDerep( 1 );

  for( multimap<int, pair<string, map<string, int>>>::reverse_iterator rit = MMdecSeqEchs.rbegin(); rit != MMdecSeqEchs.rend(); rit++ ) {
    
    // vérification de la reponse totale

    if( rit->first < seuilNbRep ) {
      break;
    }
  
    // récupération des réponse et nb de présence

    pair<string, map<string, int>> p( rit->second );    // pair<seq, map<noEch, rep>>
    map<string, int> Mcomptes( p.second );

    string reponse;
    int presEch( 0 );

    for( map<string, int>::iterator kt = Mcomptes.begin(); kt != Mcomptes.end(); kt++ ) {
      
      string Srep = static_cast<ostringstream*>( &( ostringstream() << kt->second ) )->str();
     
      reponse += '-' + kt->first + '_' + Srep;
      if( kt->second != 0 ) {
        presEch++;
      }
    }

    // écriture si assez de présence

    if( presEch >= seuilNbPres ) { 
      outPathFH << '>' << indSeqDerep << '_' << rit->first << reponse << endl << p.first << endl;
      indSeqDerep++;
    }


    if( indSeqDerep % 100000  == 0 ) {
      cout << indSeqDerep << endl;
    }
  }



  outPathFH.close();

  //

  cout << "pilées" << endl;
  return(0);
}

