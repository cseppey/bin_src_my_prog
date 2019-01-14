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

  string pathGgopIn( argv[1] ),
         pathFaBdIn( argv[2] ),
         pathFaSeqMajoIn( argv[3] ),
         pathAssOut( argv[4] );

  bool dbName( argv[5] );

  ifstream inGgopFH( pathGgopIn ),
           inFaBdFH( pathFaBdIn ),
           inFaSeqMajoFH( pathFaSeqMajoIn );
  ofstream outAssFH( pathAssOut );

  // parcourt de la base de donné

  string ligne;
  map<string, string> Mbd;

  while( getline( inFaBdFH, ligne ) ) {
    if( ligne.at( 0 ) == '>' ) {

      string partLigne;
      istringstream iss( ligne );
      while( getline( iss, partLigne, '|' ) ) {
        partLigne.erase( partLigne.begin() );
        Mbd.insert( pair<string, string>( partLigne, ligne ) );
        break;
      }

    }
  }

  // parcourt du fasta de query
  
  string nomSeq;
  map<string, string> Mquery;

  while( getline( inFaSeqMajoFH, ligne ) ) {
    if( ligne.at( 0 ) == '>' ) {
      nomSeq = ligne.substr( 0, 499 );
    }
    else {
      Mquery.insert( pair<string, string>( nomSeq, ligne ) );
    }
  }

  // parcourt du gg
  
  int indClu( 1 );

  while( getline( inGgopFH, ligne ) ) {

    string partLigne,
           nomSeqGg,
           seqMajo,
           evalue,
           taxo,
           idGb,
           pid;

    int indCol( 0 ),
        indPid;
    istringstream iss( ligne );

    while( getline( iss, partLigne, '\t' ) ) {
      
      // seqMajo
      if( indCol == 0 ) {
        outAssFH << indClu << '_' << partLigne << '\t';
        nomSeqGg = partLigne.substr( 0, 498 );
        seqMajo = Mquery.find( '>' + nomSeqGg )->second;
      }

      // taxo
      if( indCol == 1 ) {

        if( dbName == 1 ) {
          taxo = partLigne;
        }
        else {

          string partLigne2;
          istringstream iss2( partLigne );
          while( getline( iss2, partLigne2, '|' ) ) {
            // recup de l'index ds la bd
            
            string partLigne3;
            int indCol3( 0 );
            istringstream iss3( Mbd.find( partLigne2 )->second );
  
            while( getline( iss3, partLigne3, '|' ) ) {
              if( indCol3 == 0 ) {
                idGb = partLigne3;
              }
              else {
                taxo += '|' + partLigne3;
              }
              indCol3++;
            }
  
            size_t PR2 = partLigne.find( '|' );
            if( PR2 != std::string::npos ) {
              taxo = taxo.substr( 1, taxo.length() );
              break;         
            }
            else{
              taxo = partLigne.substr( 1, partLigne.length() );
            }
          }
        }

      }

      // Pid
      
      if( indCol == 2 ) {
        pid = partLigne;
      }

      // evalue et ecriture de l'assignation
      if( indCol == 10 ) {
        outAssFH << partLigne << '\t' << pid << '\t' << taxo << '\t' << idGb << '\t' << seqMajo << endl;
      }

      indCol++;
    }

    indClu++;
  }


  inGgopFH.close();
  outAssFH.close();

  return(0);

}

    


    
  
