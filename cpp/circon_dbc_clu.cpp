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
 
  // établissement des flux

  string pathTmpIn = argv[1],
         pathCluOkOut = argv[2],
         nbSeqRanStr = argv[3];

  ifstream inPathTmpFH( pathTmpIn );
  ofstream outPathCluOkFH( pathCluOkOut );

  int nbSeqRanInt( atoi( nbSeqRanStr.c_str() ) );
  double nbSeqRanDbl( nbSeqRanInt );

  // recherche des cluster et comptes

  string ligneTmp;
  map<double, double> McluCnt;
  double nbSeqTot,
         minDbcClus( 10000000 );

  while( getline( inPathTmpFH, ligneTmp ) ) {

    string partLigne;
    istringstream iss( ligneTmp );
    vector<double> VpartLigne;
    while( getline( iss, partLigne, '\t' ) ) {
      int partLigneInt( atoi( partLigne.c_str() ) );
      double partLigneDbl( partLigneInt );
      VpartLigne.push_back( partLigneDbl );
    }

    if( VpartLigne[0] < minDbcClus ) {
      minDbcClus = VpartLigne[0];
    }

    McluCnt.insert( pair<double, double>( VpartLigne[1], VpartLigne[0] ) );

    nbSeqTot += VpartLigne[0];
  
  }

  // détermination du 1er nb de seq minimum
  
  double nbSeqMin( 1 / (nbSeqRanDbl / nbSeqTot) );
  cout << nbSeqTot << '\t' << nbSeqMin << '\t' << minDbcClus << '\t' << McluCnt.size() <<  endl << endl;

  // boucle de suppression des clusters
  
  while( nbSeqMin > minDbcClus ) {

    // suppression du cluster si compte inférieur à seuil minimum

    nbSeqTot = 0;
    minDbcClus = 10000000;
    for( map<double, double>::iterator it=McluCnt.begin(); it!=McluCnt.end(); ) {
      
      if( it->second > nbSeqMin ) {
        
        nbSeqTot += it->second;

        if( it->second < minDbcClus ) {
          minDbcClus = it->second;
        }

        ++it;
      }
      else {
        McluCnt.erase( it++ );
      }

    }
  
    nbSeqMin = 1 / (nbSeqRanDbl / nbSeqTot);
    cout << nbSeqTot << '\t' << nbSeqMin << '\t' << minDbcClus << '\t' << McluCnt.size() <<  endl << endl;

  }

  // écriture des clusters
  
  for( map<double, double>::iterator it=McluCnt.begin(); it!=McluCnt.end(); it++ ) {
    outPathCluOkFH << it->first << endl;
  }

  //

  outPathCluOkFH.close();
  inPathTmpFH.close();

  return(0);
}

