#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <map>

#include <algorithm>

#include <stdlib.h>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  // établissement du flux d'entre

  string pathAssIn = argv[1],
         pathMrIn = argv[2],
         dirMrTaxoOut = argv[3];

  ifstream inPathAssFH( pathAssIn ),
           inPathMrFH( pathMrIn );

  // recherche des des taxo et cluster

  string ligneAss;

  map<string, vector<string>> Mtaxo;

  while( getline( inPathAssFH, ligneAss ) ) {

    string partLigne,
           cluster;
    istringstream iss( ligneAss );
    int indPartLigne( 0 );

    while( getline( iss, partLigne, '\t' ) ) {
      
      //récupération du cluster
      if( indPartLigne == 0 ) {

        string partClus;
        istringstream iss2( partLigne );
        int indPartClu( 0 );

        while( getline( iss2, partClus, '_' ) ) {
          if( indPartClu == 0 ) {
            cluster = partClus;
          }
          break;
        }

      }

      // récupération de la taxo
      if( indPartLigne == 2 ) {

        // si taxo vide
        if( Mtaxo.find( partLigne ) == Mtaxo.end() ) {
          
          vector<string> Vclus;
          Vclus.push_back( cluster );

          Mtaxo.insert( pair<string, vector<string>>( partLigne, Vclus ) );

        }

        // si taxo existante
        else {

          vector<string> Vclus( Mtaxo.find( partLigne )->second );
          Vclus.push_back( cluster );
          
          Mtaxo.erase( Mtaxo.find( partLigne ) );
          Mtaxo.insert( pair<string, vector<string>>( partLigne, Vclus ) );
        
        }

      }

      indPartLigne++;
    }

  }

  inPathAssFH.close();

  //////////
  
  // téléchargement de la matrice de réponse
  
  vector<vector<string>> VVrep;
  string ligneMr;
  int indLigne( 0 ); 

  while( getline( inPathMrFH, ligneMr ) ) {
  
    vector<string> Vrep;
    string partLigne,
           rep;
    istringstream iss( ligneMr );
    int indPartLigne( 0 );

    while( getline( iss, partLigne, '\t' ) ) {
      
      if( indPartLigne > 0 ) {
        Vrep.push_back( partLigne );
      }

      indPartLigne++;
    }

    VVrep.push_back( Vrep );

    indLigne++;
  }

  // transposition ds un map

  map<string, string> Mrep;

  for( int i=0; i < VVrep[0].size(); i++ ) {

    string cluster( VVrep[0][i] ),
           rep;
    for( int j=0; j < VVrep.size(); j++ ) {
      
      if( j == 0 ) {
        rep = VVrep[j][i];
      }
      else {
        rep += '\t' + VVrep[j][i];
      }

    }

    Mrep.insert( pair<string, string>( cluster, rep ) );

  }


  // recherche des réponses pour chaque taxo
  
  int indTaxo( 0 );

  for( map<string, vector<string>>::iterator it=Mtaxo.begin(); it != Mtaxo.end(); it++ ) {

    // ouverture du file handler d'OP

    stringstream ss;
    ss << indTaxo;
    ofstream outPathMrTaxo( dirMrTaxoOut + "/mr_" + ss.str() );
    
    // récupération des réponses

    cout << it->first << endl;
    vector<string> Vclus( it->second );

    for( int i=0; i < Vclus.size(); i++ ){

      outPathMrTaxo << Mrep.find( Vclus[i] )->second << endl;
      
    }

    outPathMrTaxo.close();
    indTaxo++;
  }


  //

  return(0);
}

