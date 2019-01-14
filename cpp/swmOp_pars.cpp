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

  string pathSmopIn( argv[1] ),
         pathDerepIn( argv[2] ),
         
         pathMrOut( argv[3] ),
         pathFaSeqMajo( argv[4] );

  ifstream inSmopFH( pathSmopIn ),
           inDerepFH( pathDerepIn );
  
  ofstream outMrFH( pathMrOut ),
           outFaSeqMajoFH( pathFaSeqMajo );

  // parcourt derep

  string ligne,
         nomDerep;
  map<string, string> Mderep;

  while( getline( inDerepFH, ligne ) ) {
    if( ligne.at( 0 ) == '>' ) {
      string partLigne2;
      istringstream iss( ligne );
      while( getline( iss, partLigne2, '-' ) ) {
        nomDerep = partLigne2;
        break;
      }
    }
    else {
      Mderep.insert( pair<string, string>( nomDerep, ligne ) );
    }
  }

  // parcourt swm OP

  int indClu( 0 );
  vector<string> Vechs;
  map<int, vector<int>> Mreps;

  while( getline( inSmopFH, ligne ) ) {

    string partLigne;
    int indSeqDerep( 0 );
    istringstream iss( ligne );
    vector<int> Vreps;
    map<string, int> MechCnt;

    while( getline( iss, partLigne, ' ' ) ) {
      
      string partLigne2;
      int indEch( 0 );
      istringstream iss2( partLigne );

      while( getline( iss2, partLigne2, '-' ) ) {
      
        // écriture du fasta de seq majo
        if(( indSeqDerep == 0 ) & ( indEch == 0 )) {
          outFaSeqMajoFH << Mderep.find( '>' + partLigne2 )->first << endl << Mderep.find( '>' + partLigne2 )->second << endl; 
        }

        // recup echs
        if(( indClu == 0 ) & ( indSeqDerep == 0 ) & ( indEch > 0 )) {
          Vechs.push_back( partLigne2.substr( 0, partLigne2.find_first_of( '_' ) ) );
        }

        // recup cnts

        if( indEch > 0 ) {
          int cnt( atoi( partLigne2.substr( partLigne2.find_first_of( '_' )+1 , partLigne2.length() ).c_str() ) );
          if( indSeqDerep == 0 ) {
            Vreps.push_back( cnt );
          }
          else {
            Vreps[indEch-1] += cnt;
          }
        }
          
        indEch++;
      }

      indSeqDerep++;
    }

    indClu++;

    Mreps.insert( pair<int, vector<int>>( indClu, Vreps ) );

    if( indClu % 10000 == 0 ) {
      cout << "parcourt swop: clu no " << indClu << endl;
    }

  }

  outFaSeqMajoFH.close();

  // osti q'suis fatigué (switch d'la matrice)
  
  map<string, vector<int>> MechReps;
  for( int i = 0; i < Vechs.size(); i++ ){
    vector<int> v( indClu, 0 );
    MechReps.insert( pair<string, vector<int>>( Vechs[i], v ) );
  }

  indClu = 0;
  for( map<int, vector<int>>::iterator it = Mreps.begin(); it != Mreps.end(); it++ ) {
    
    outMrFH << '\t' << it->first;

    for( int j = 0; j < it->second.size(); j++ ) { 
      string ech( Vechs[j] );

      MechReps[ech][indClu] = it->second[j];
    }

    indClu++;

    if( indClu % 10000 == 0 ) {
      cout << "transposition: clu no " << indClu << endl;
    }

  }

  outMrFH << endl;

  // blâh!

  for( map<string, vector<int>>::iterator it = MechReps.begin(); it != MechReps.end(); it++ ) {
    outMrFH << it->first;

    for( int j = 0; j < it->second.size(); j++ ) {
      outMrFH << '\t' << it->second[j];
    }
    
    outMrFH << endl;
  }

  outMrFH.close();

  cout << "burp!" << endl;

  return(0);

}

    
