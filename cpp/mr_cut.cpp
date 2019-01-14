#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>

#include <algorithm>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patate" << endl;
  
  // établissement du flux pour l'ouverture des fichiers fastq

  string pathMrIn = argv[1],
         pathAssIn = argv[2],
         pathRepOut = argv[3];

  int nbTranche = atoi( argv[4] ),
      tailleSeuilClu = atoi( argv[5] );

  ifstream inPathMrFH( pathMrIn ),
           inPathAssFH( pathAssIn );

  // parcourt de la matrice de réponse
  
  string ligne;
  int indLigne( 0 ),
      indClu( 0 );
  vector<pair<int, pair<int, vector<int>>>> VsumCluRep; // vector<pair<repCumuleDuCluster, pair<noClu, vector<repsDuClu>>>>
  vector<string> Vechs;
  
  while( getline( inPathMrFH, ligne ) ) { 
    
    // vector clusters
    if( indLigne == 0 ) {
      
      string partLigne;
      int indClu( 0 );
      istringstream iss( ligne );
      
      while( getline( iss, partLigne, '\t' ) ) {
        if( indClu != 0 ) {
          vector<int> v;
          pair<int, vector<int>> p( atoi( partLigne.c_str() ), v );
          VsumCluRep.push_back( pair<int, pair<int, vector<int>>>( 0, p ) );
        }
        
        indClu++;
      }

    }
    
    // echantillon
    else {

      string partLigne;
      indClu = 0;
      istringstream iss( ligne );
      vector<int> Vreps;

      while( getline( iss, partLigne, '\t' ) ) {
        
        if( indClu == 0 ) {
          Vechs.push_back( partLigne );
        }
        else {
          int rep( atoi( partLigne.c_str() ) );

          // incrémentation du cluster
          VsumCluRep[indClu-1].first += rep;
          VsumCluRep[indClu-1].second.second.push_back( rep );

        }
        
        indClu++;
      }

    }

    indLigne++;
  }

  // parcourt du fichier d'assignation

  map<int, string> Mass;

  while( getline( inPathAssFH, ligne ) ) {

    string partLigne;
    istringstream iss( ligne );
    while( getline( iss, partLigne, '_' ) ) {
      Mass.insert( pair<int, string>( atoi( partLigne.c_str() ), ligne ) );
      break;
    }
  }

  // switch mr vector à un multimap

  multimap<int, pair<int, vector<int>>> MMsumCluRep;    // multimap<repCumuleDuCluster, pair<noClu, vector<repsDuClu>>>

  for( int i = 0; i < VsumCluRep.size(); i++ ) {
    if( VsumCluRep[i].first >= tailleSeuilClu ) {
      MMsumCluRep.insert( pair<int, pair<int, vector<int>>>( VsumCluRep[i].first, VsumCluRep[i].second ) );
    }
  }

  // morceaux matrice

  int nbCluTranche( MMsumCluRep.size() / nbTranche ),
      nbClu( 0 ),
      noTranche( 1 );
  multimap<int, pair<int, vector<int>>>::iterator it;
  map<int, string>::iterator jt;

  for( int i = 1; i <= nbTranche; i++ ) {

    // ouverture des flux

    int nb1( nbCluTranche * i - nbCluTranche ),
        nb2( nbCluTranche * i );
    string SnoTranche = static_cast<ostringstream*>( &( ostringstream() << noTranche ) )->str();
  
    if( noTranche < 10 ) {
      SnoTranche = '0' + SnoTranche;
    }

    string pathMrOut( pathRepOut + '/' + SnoTranche + "_.mr" ),
           pathAssOut( pathRepOut + '/' + SnoTranche + "_.ass" );
    ofstream outPathMrFH( pathMrOut ),
             outPathAssFH( pathAssOut );

    // récupération de la sous matrice et écriture du fichier d'assign

    vector<vector<int>> Vreps;

    if( i != nbTranche) {
      for( int j = 0; j < nbCluTranche; j++ ) {
        
        it = MMsumCluRep.begin();
        Vreps.push_back( it->second.second );

        outPathMrFH << '\t' << it->second.first;
        outPathAssFH << Mass.find( it->second.first )->second << endl;
        
        MMsumCluRep.erase( it );

      }
    }
    else {
      for( it = MMsumCluRep.begin(); it != MMsumCluRep.end(); it++ ) {

        Vreps.push_back( it->second.second );
        outPathMrFH << '\t' << it->second.first;
        outPathAssFH << Mass.find( it->second.first )->second << endl;

      }
    }

    outPathMrFH << endl;

    outPathAssFH.close();
    
    // écriture de la matrice
    
    for( int j = 0; j < Vechs.size(); j++ ) {
      outPathMrFH << Vechs[j];
      for( int k = 0; k < Vreps.size(); k++ ) {
        outPathMrFH << '\t' << Vreps[k][j];
      }
      outPathMrFH << endl;
    }

    noTranche++;

    outPathMrFH.close();


  }
  inPathMrFH.close();

  //

  cout << "pilées" << endl;

  return(0);
}

