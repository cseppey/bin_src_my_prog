#include <fstream>
#include <sstream>
#include <iostream>

#include <string>
#include <vector>
#include <map>
#include <set>

#include <algorithm>

using namespace std;



int main( int argc, char * argv[] ) {

  // établissement du flux

  string pathTmpIn( argv[1] ),
         pathPwIn( argv[2] ),
         pathSeqClu( argv[3] );

  ifstream inTmpFh( pathTmpIn ),
           inPwFh( pathPwIn );
  ofstream outSeqCluFh( pathSeqClu );

  // ceéation dun conteneur de cluster choisis par piecewise

  string lignePw;
  vector<string> Vclus;

  while( getline( inPwFh, lignePw ) ) {
    Vclus.push_back( lignePw );
  }
//  cout << Vclus[Vclus.size()-1] << endl;

  // sélection des lignes de seq env et clusters
  
  cout << "parsing opDbc" << endl;

  string ligneCluSeq;
  int indLigne( 0 ),
      indClu( 0 ),
      onOff( 0 );
  multiset<string> MSseqsClu;

  while( getline( inTmpFh, ligneCluSeq ) ) {

    // découpage de la ligne CluSeq
    
    string partLigne;
    istringstream iss( ligneCluSeq );
    vector<string> VcluSeq;
    while( getline( iss, partLigne, '\t' ) ) {
      VcluSeq.push_back( partLigne );
    }

    if( indLigne == 0 ) {
      MSseqsClu.insert( VcluSeq[1] );
    }
      
    // recherche du 1er cluster

    if( onOff != 0 ) {
      cout << Vclus[indClu] << endl;

      // insertion de seq ds multiset
  
      if( VcluSeq[0] == Vclus[indClu] ) {
        MSseqsClu.insert( VcluSeq[1] );
      }
  
      // impression à la fin du cluster on du fichier
  
      else {

        outSeqCluFh << '>' << Vclus[indClu] << endl;
    
        set<string> SseqsUniqClu( MSseqsClu.begin(), MSseqsClu.end() );
        multimap<int, string> McntSeq;
        for( set<string>::iterator it = SseqsUniqClu.begin(); it != SseqsUniqClu.end(); it++ ) {
          McntSeq.insert( pair<int, string>( MSseqsClu.count( *it ), *it ) );
        }
        SseqsUniqClu.clear();
        MSseqsClu.clear();
        MSseqsClu.insert( VcluSeq[1] );
    
        for( multimap<int, string>::reverse_iterator rit = McntSeq.rbegin(); rit != McntSeq.rend(); rit++ ){
          outSeqCluFh << rit->first << '\t' << rit->second << endl;
        }        

        indClu++;
        onOff--;

      }
    }

    if(( VcluSeq[0] == Vclus[indClu] ) & ( onOff == 0 )) {
      onOff++;
    }


    if( indLigne % 1000 == 0 ) {
      cout << "cntl" << '\t' << indLigne << endl;
    }

    indLigne++;
  }

  outSeqCluFh << '>' << Vclus[indClu] << endl;
  
  set<string> SseqsUniqClu( MSseqsClu.begin(), MSseqsClu.end() );
  multimap<int, string> McntSeq;
  for( set<string>::iterator it = SseqsUniqClu.begin(); it != SseqsUniqClu.end(); it++ ) {
    McntSeq.insert( pair<int, string>( MSseqsClu.count( *it ), *it ) );
  }
  SseqsUniqClu.clear();
  MSseqsClu.clear();
  
  for( multimap<int, string>::reverse_iterator rit = McntSeq.rbegin(); rit != McntSeq.rend(); rit++ ){
    outSeqCluFh << rit->first << '\t' << rit->second << endl;
  }   
  
  inTmpFh.close();
  outSeqCluFh.close();

  return(0);

}

    
