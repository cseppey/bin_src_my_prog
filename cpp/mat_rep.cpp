#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>

#include <algorithm>

#include <stdlib.h>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  // établissement des flux

  string pathDbcIn = argv[1],
         pathCluPwIn = argv[2],
         pathMatRepOut = argv[3];

  ifstream inPathDbcFH( pathDbcIn ),
           inPathCluPwFH( pathCluPwIn );
  ofstream outPathMatRepFH( pathMatRepOut );

  // téléchargement des cluster piecewise

  string ligneCluPw;
  set<int> ScluPw;

  while( getline( inPathCluPwFH, ligneCluPw ) ) {
    ScluPw.insert( atoi( ligneCluPw.c_str() ) );
  }

  inPathCluPwFH.close();

  // parcourt du dbc op

  string ligneDbc;
  int indLigne( 1 );
  map<string, multiset<int>> MechClus;
  
  while( getline( inPathDbcFH, ligneDbc ) ) {
  
    // récupération des clu et ech

    string partLigne,
           ech;
    istringstream iss( ligneDbc );
    int indPartLigne( 1 ),
        indBreak( 0 ),
        clu;
    
    while( getline( iss, partLigne, '\t' ) ) {
      
      if( indPartLigne == 2 ) {
        if( ScluPw.find( atoi( partLigne.c_str() ) ) == ScluPw.end() ) {
          break;
        }
        else {
          clu = atoi( partLigne.c_str() );
        }
      }
      
      if( indPartLigne == 3 ) {
        
        // recherche de l'ech

        string partLigne2;
        istringstream iss2( partLigne );
        int indPartLigne2( 1 );
        while( getline( iss2, partLigne2, ' ' ) ) {
          if( indPartLigne2 == 3 ) {
            ech = partLigne2;
          }
          indPartLigne2++;
        }

        // insertion ds le map

        if( MechClus.find( ech ) == MechClus.end() ) {
          multiset<int> Ms;
          MechClus.insert( pair<string, multiset<int>>( ech, Ms ) );
        }
        else {
          MechClus[ech].insert( clu );
        }

      }
      
      indPartLigne++;
    }    

    if( indLigne % 100000 == 0 ) {
      cout << indLigne << endl;
    }

    indLigne++;
  }

  inPathDbcFH.close();

  // écriture de la mat
  
  for( set<int>::iterator it = ScluPw.begin(); it != ScluPw.end(); it++ ) {
    outPathMatRepFH << '\t' << *it;
  }
  outPathMatRepFH << endl;

  for( map<string, multiset<int>>::iterator it = MechClus.begin(); it != MechClus.end(); it++ ) {
    outPathMatRepFH << it->first;

    for( set<int>::iterator jt = ScluPw.begin(); jt != ScluPw.end(); jt ++ ) {
      int cnt( it->second.count( *jt ) );
      outPathMatRepFH << '\t' << cnt;
    }

    outPathMatRepFH << endl;
  }
   
  outPathMatRepFH.close();

  return(0);
}

