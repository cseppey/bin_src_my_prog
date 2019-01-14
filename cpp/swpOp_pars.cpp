#include <fstream>
#include <sstream>
#include <iostream>

#include <string>
#include <vector>
#include <map>

#include <algorithm>

#include <cctype>

using namespace std;



int main( int argc, char * argv[] ) {

  // établissement du flux 

  string pathSopIn( argv[1] ),
         pathFaBdIn( argv[2] ),
         pathFaSeqMajoIn( argv[3] ),
         pathAssOut( argv[4] );

  bool dbName( argv[5] );

  ifstream inSopFH( pathSopIn ),
           inFaBdFH( pathFaBdIn ),
           inFaSeqMajoFH( pathFaSeqMajoIn );
  ofstream outAssFH( pathAssOut );

  // parcourt de la base de donné

  string ligne;
  vector<string> Vbd;

  while( getline( inFaBdFH, ligne ) ) {
    if( ligne.at( 0 ) == '>' ) {
      Vbd.push_back( ligne );
    }
  }

  // parcourt du fasta de query
  
  string nomSeq;
  map<string, string> Mquery;

  while( getline( inFaSeqMajoFH, ligne ) ) {
    if( ligne.at( 0 ) == '>' ) {
      nomSeq = ligne;
    }
    else {
      Mquery.insert( pair<string, string>( nomSeq, ligne ) );
    }
  }

  // parcourt du sop
  
  int indClu( 1 );

  while( getline( inSopFH, ligne ) ) {

    string partLigne,
           seqMajo,
           evalue,
           taxo,
           idGb,
           pid,
           seqLength;
    
    int indCol( 0 );
    istringstream iss( ligne );

    while( getline( iss, partLigne, '\t' ) ) {
      
      // seqMajo
      if( indCol == 0 ) {
        outAssFH << indClu << '_' << partLigne << '\t';
        seqMajo = Mquery.find( '>' + partLigne )->second;
      }

      // taxo
      if( indCol == 1 ) {


        string partLigne2;
        istringstream iss2( partLigne );
        int indCol2( 0 );
  
        while( getline( iss2, partLigne2, '|' ) ) {
          // recup de l'index ds la bd
          if( indCol2 == 2 ) {
            
            if( dbName == 1 ) {
              taxo = Vbd[atoi( partLigne2.c_str() )];
            }
            else {

              // recup de la taxo et gb
              string partLigne3;
              int indCol3( 0 );
              istringstream iss3( Vbd[atoi( partLigne2.c_str() )] );
  
              while( getline( iss3, partLigne3, '|' ) ) {
                if( indCol3 == 0 ) {
                  idGb = partLigne3;
                }
                else {
                  taxo += '|' + partLigne3;
                }
                indCol3++;
              }
  
              taxo = taxo.substr( 1, taxo.length() );
            }

          }
  
          indCol2++;
        }
      }

      //pid
      if( indCol == 2 ) {
        pid = partLigne;
      }

      // seqLength
      if( indCol == 3 ) {
        seqLength = partLigne;
      }

      // evalue et ecriture de l'assignation
      if( indCol == 10 ) {
        outAssFH << partLigne << '\t' << pid << '\t' << seqLength << '\t' << taxo << '\t' << idGb << '\t' << seqMajo << endl;
      }

      indCol++;
    }

    indClu++;
  }


  inSopFH.close();
  outAssFH.close();

  return(0);

}

    


    
  
