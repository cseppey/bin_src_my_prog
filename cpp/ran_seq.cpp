#include <fstream>
#include <iostream>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

#include <string.h>
#include <utility>
#include <vector>
#include <set>
#include <map>

#include <algorithm>
#include <math.h>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "miam!" << endl;
  
  // établissement des flux d'entre et sortie
   
  string pathFaIn = argv[1],
         pathFaOut = argv[2];

  double fracFa = atof( argv[3] ),
         seuilScrap = atof( argv[4] );
 
  ifstream inPathFH( pathFaIn );
  ofstream outPathFH( pathFaOut );

  cout << pathFaIn << endl;

  // boucle sur toute les séquences du fasta
  
  string ligne, 
         titreSeq;

  int seqOk( 0 ),
      seqScrap( 0 );

  // si tout l'échantillon
  
  if( fracFa == 1 ){

    while ( getline( inPathFH, ligne )) {
      if ( ligne.at(0) == '>' ) {
        titreSeq = ligne;
      }
      else {
        double nbN = count( ligne.begin(), ligne.end(), 'N' );
        double seqLength = ligne.size();
        double res = nbN / seqLength;
        if ( nbN / seqLength <= seuilScrap ){
          outPathFH << titreSeq << endl;
          outPathFH << ligne << endl;
          seqOk++;
        }
        else {
          seqScrap++;
        }
      }
    }
  
    cout << "nb seq ok = " << seqOk << "\nnb seq scrap = " << seqScrap << endl;
  }

  // si bout d'échantillon

  else {

    vector<pair<string, string> > vecSeq;

    while ( getline( inPathFH, ligne )) {
      if ( ligne.at(0) == '>' ) {
        titreSeq = ligne;
      }
      else {
        double nbN = count( ligne.begin(), ligne.end(), 'N' );
        double seqLength = ligne.size();
        double res = nbN / seqLength;
        if ( nbN / seqLength <= seuilScrap ){
          vecSeq.push_back( pair<string, string>( titreSeq, ligne ) );
          seqOk++;
        }
        else {
          seqScrap++;
        }
      }
    }
  
    cout << "nb seq ok = " << seqOk << "\nnb seq scrap = " << seqScrap << endl;
  
    /////////////

    srand( time( NULL ));
    vector<int> vecRan;
    int i( 0 );
 
    // si fraction d'échantillon
    
    if( fracFa < 1 ) {

      // boucle sur les seq aleat
      
      int nbRanSeq( vecSeq.size() * fracFa );

      while ( i < nbRanSeq ){
    
        int ran = rand() % vecSeq.size();
        if ( find( vecRan.begin(), vecRan.end(), ran ) == vecRan.end() ){
    
          if( i % 1000 == 0 ){
            cout << i << " / " << nbRanSeq << endl;
          }
    
          vecRan.push_back( ran );
          outPathFH << vecSeq[ran].first << endl;
          outPathFH << vecSeq[ran].second << endl;
          i++;
        }
      }
    }

    // si un nombre de séquences par ech
    
    else { 
      
      // si nb de séquence voulu est < au nombre de séquence totale
      
      if( fracFa < vecSeq.size() ) {

        while( i < fracFa ){
          
          int ran = rand() % vecSeq.size();
          if ( find( vecRan.begin(), vecRan.end(), ran ) == vecRan.end() ){
      
            if( i % 1000 == 0 ){
              cout << i << " / " << fracFa << endl;
            }
      
            vecRan.push_back( ran );
            outPathFH << vecSeq[ran].first << endl;
            outPathFH << vecSeq[ran].second << endl;
            i++;
  
            if( i > vecSeq.size() ){
              break;
            }
          }
        }
      }

      // si le nombre de séquence voulu est > au nombre de séquence totale
      
      else {
        
        int nbIter( 1 );

        // multiplication des pains
        
        while( vecSeq.size() * nbIter < fracFa ){

          for( int j = 0; j != vecSeq.size(); j++ ) {
            outPathFH << vecSeq[j].first << ' ' << nbIter << endl;
            outPathFH << vecSeq[j].second << endl;
            i++;
          }
          
          nbIter++;
        }
      
        cout << i << fracFa << endl;
        // remplissage de la mission

        while( i < fracFa ){
          
          int ran = rand() % vecSeq.size();
          if ( find( vecRan.begin(), vecRan.end(), ran ) == vecRan.end() ){
      
            if( i % 1000 == 0 ){
              cout << i << " / " << fracFa << endl;
            }
      
            vecRan.push_back( ran );
            outPathFH << vecSeq[ran].first << endl;
            outPathFH << vecSeq[ran].second << endl;
            i++;
  
          }
        }
      
      }




    }

  }


  inPathFH.close();
  outPathFH.close();

  cout << "burp!" << endl;

  //

  return(0);
}

