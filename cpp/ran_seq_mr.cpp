#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>

#include <stdlib.h>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patate" << endl;
  
  // établissement du flux pour l'ouverture des fichiers 

  string pathMrIn = argv[1],
         pathMrOut = argv[2];

  int nbPioche = atoi( argv[3] );

  ifstream inPathMrFH( pathMrIn );
  ofstream outPathMrFH( pathMrOut );

  // parcourt de la matrice de réponse
  
  string ligne;
  int indLigne( 0 );
  vector<int> VnomOtus;

  while( getline( inPathMrFH, ligne ) ) {

    cout << indLigne << endl;
    if( indLigne == 0 ) {
      
      // recup nom OTUs
      string partLigne;
      istringstream iss( ligne );
      while( getline( iss, partLigne, '\t' ) ) {
        VnomOtus.push_back( atoi( partLigne.substr( 1 ).c_str() ) );
      }

      //écriture nom OTUs
      outPathMrFH << ligne << endl;

    }
    else{

      // recherche réponse
      string partLigne;
      istringstream iss( ligne );
      int indPartLigne( 0 );
      vector<int> Vreps;
      multiset<int> Sreps;
      while( getline( iss, partLigne, '\t' ) ) {
       
        if( indPartLigne == 0 ) {
          outPathMrFH << endl << partLigne;
        }
        else {
          
          int rep( atoi( partLigne.c_str() ) ),
              noOtu( VnomOtus[indPartLigne-1] );
          for( int i( 0 ); i < rep; i++ ) {
            Vreps.push_back( noOtu );
            Sreps.insert( noOtu );
          }
        
        }

        indPartLigne++;
      }

      // initialisatio de la récup
      map<int, int> Mrecup;
      for( vector<int>::iterator it = VnomOtus.begin(); it != VnomOtus.end(); it++ ) {
        Mrecup.insert( pair<int, int>( *it, 0 ) );
      }

      // pioche
      for( int i( 0 ); i < nbPioche; i++ ) {
        int indRan( rand() % Vreps.size() );
        Mrecup.find( Vreps[indRan] )->second++;
        Vreps.erase( Vreps.begin() + indRan );
      }

      // écriture
      for( map<int, int>::iterator it = Mrecup.begin(); it != Mrecup.end(); it++ ) {
        outPathMrFH << '\t' << it->second;
      }
      
    }

    indLigne++;
  }


  //

  cout << "pilées" << endl;

  return(0);
}

