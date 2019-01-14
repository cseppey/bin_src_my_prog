#include <fstream>
#include <sstream>
#include <iostream>

#include <string.h>
#include <vector>
#include <map>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "miam!" << endl;
  
  // établissement des flux d'entre et sortie
   
  string pathCorrespIn = argv[1],
         pathSwmIn = argv[2],
         pathSwmOut = argv[3];

  ifstream inCorrespFH( pathCorrespIn ),
           inSwmFH( pathSwmIn );
  ofstream outSwmFH( pathSwmOut );

  // parcourt du fichier de correspondance
  
  string ligne;
  map<string, string> Mcorresp;
  
  while( getline( inCorrespFH, ligne ) ) {

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
      outSwmFH << Mcorresp.find( '>' + partLigne )->second << ' ';
      Mcorresp.erase( Mcorresp.find( '>' + partLigne ) );
    }
    outSwmFH << endl;

  }

  inSwmFH.close();
  outSwmFH.close();

  cout << "burp!" << endl;

  //

  return(0);
}

