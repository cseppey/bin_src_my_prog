#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>


using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patates" << endl;
  
  // établissement du flux pour l'ouverture des fichiers fastq

  string pathFaIn = argv[1],
         pathFaOut = argv[2];

  ifstream inPathFaFH( pathFaIn );
  ofstream outPathFaFH( pathFaOut );
    
  // parcourt fasta
  
  string ligne;
  int indLigne( 0 );

  while( getline( inPathFaFH, ligne ) ) {

    int noSeq,
        repet( 0 ); 

    // titre, eval, pid, lgt, ass, seq
    string partLigne;
    int indPartLigne( 0 );
    istringstream iss( ligne );
    while( getline( iss, partLigne, '\t' ) ) {

      // noSeq et repet
      if( indPartLigne == 0 ) {

        string partLigne2;
        istringstream iss2( partLigne );
        int indPartLigne2( 0 );
        while( getline( iss2, partLigne2, '-' ) ) {

          string partLigne3;
          istringstream iss3( partLigne2 );
          int indPartLigne3( 0 );
          while( getline( iss3, partLigne3, '_') ) {
            
            // noSeq
            if( indPartLigne2 == 0 && indPartLigne3 == 1 ) {
   
              noSeq = atoi( partLigne3.c_str() );
              break;
              
            }
            // repet
            if( indPartLigne2 != 0 && indPartLigne3 == 1 ) {

              repet += atoi( partLigne3.c_str() );

            }
          
            indPartLigne3++;
          }

          indPartLigne2++;
        }
      }
      
      // seq et écriture
      if( indPartLigne == 6 ) {

        for( int i = 1; i <= repet; i++ ) {
          outPathFaFH << '>' << noSeq << '_' << i << endl << partLigne << endl;
        }

      }

      indPartLigne++;
    }

    indLigne++;
  }


  inPathFaFH.close();
  outPathFaFH.close();

  //

  cout << "plate" << endl;
  return(0);
}

