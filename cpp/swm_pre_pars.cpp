#include <fstream>
#include <sstream>
#include <iostream>

#include <string>
#include <vector>
#include <map>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "miam!" << endl;
  
  // établissement des flux d'entre et sortie
   
  string pathCorrespIn( argv[1] ),
         pathSwmIn( argv[2] ),
         pathSwmOut( argv[3] );

  ifstream inCorrespFH( pathCorrespIn.c_str() ),
           inSwmFH( pathSwmIn.c_str() );
  ofstream outSwmFH( pathSwmOut.c_str() );

  // parcourt du fichier de correspondance
  
  int indLine = 0;
  string ligne;
  map<string, string> Mcorresp;
  
  while( getline( inCorrespFH, ligne ) ) {

    //indLine++;
    //if( indLine % 10000 == 0 ) {
    //  cout << "crsp " << indLine << endl;
    //}

    string partLigne,
           idSeqDerep;
    istringstream iss( ligne );
    while( getline( iss, partLigne, '-' ) ) {
      idSeqDerep = partLigne;
      break;
    }

    Mcorresp.insert( pair<string, string>( idSeqDerep, ligne ) );

  }

  inCorrespFH.close();

  // parcourt du fichier swm op

  while( getline( inSwmFH, ligne ) ) {

    string partLigne;
    istringstream iss( ligne );
    while( getline( iss, partLigne, ' ' ) ) {
      
      string partLigne2;
      istringstream iss2( partLigne );

      while( getline( iss2, partLigne2, ';' ) ) {
	outSwmFH << Mcorresp.find( '>' + partLigne2 )->second << ' ';
      	Mcorresp.erase( Mcorresp.find( '>' + partLigne2 ) );
	break;
      }
      
    }
    outSwmFH << endl;

  }

  inSwmFH.close();
  outSwmFH.close();

  cout << "burp!" << endl;

  //

  return(0);
}

