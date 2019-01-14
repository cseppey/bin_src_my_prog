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

  string pathFaIn = argv[1],
         pathFaOut = argv[2];

  ifstream inPathFH( pathFaIn );
  ofstream outPathFH( pathFaOut );

  // parcourt du faIn
  
  string ligneFaIn;
  int indLigne( 1 );
  map<string, int> MseqCnt;

  while( getline( inPathFH, ligneFaIn ) ) {

    if( ligneFaIn.find( '>' ) != 0 ) {
      
      if( MseqCnt.count( ligneFaIn ) == 0 ) {
        int cnt( 1 );
        MseqCnt.insert( pair<string, int>( ligneFaIn, cnt ) );
      }
      else {
        int cnt( MseqCnt.find( ligneFaIn )->second );
        cnt++;
        MseqCnt.erase( ligneFaIn );
        MseqCnt.insert( pair<string, int>( ligneFaIn, cnt ) );
      }
    
    }

    if( indLigne % 100000 == 0 ) {
      cout << "parcourt fa " <<  indLigne << endl;
    }
    indLigne++;

  }

  // swap cnt et seq
  
  int indSeq( 1 );
  multimap<int, string> MMcntSeq;
#
  for( map<string, int>::iterator it = MseqCnt.begin(); it != MseqCnt.end(); it++ ) {
    string seq( it->first );
    int cnt( it->second );

    MMcntSeq.insert( pair<int, string>( cnt, seq ) );
    
    if( indSeq % 10000 == 0 ) {
      cout << "swap " << indSeq << " / " << MseqCnt.size() << endl;
    }
    indSeq++;

  }

  // écriture des séquences

  indSeq = 1;

  for( multimap<int, string>::reverse_iterator rit = MMcntSeq.rbegin(); rit != MMcntSeq.rend(); rit++ ){

    outPathFH << '>' << indSeq << '_' << rit->first << endl << rit->second << endl;
    indSeq++;
  }

  inPathFH.close();
  outPathFH.close();

  //

  cout << "burp!" << endl;
  return(0);
}

