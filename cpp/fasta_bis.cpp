#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <map>
#include <vector>

#include <algorithm>

using namespace std;

//////////


int main( int argc, char * argv[] ) {

  // établissement des flux 
  
  string pathOtuBsIn( argv[1] ),
         pathDbcIn( argv[2] ),
         pathFaOut( argv[3] );

  ifstream inPathOtuBsFh( pathOtuBsIn.c_str() ),
           inPathDbcFh( pathDbcIn.c_str() );
  ofstream outPathFaFh( pathFaOut.c_str() );

  // établissement des cluster à chercher

  string ligneOtuBs;
  vector<string> VclusterOk;

  cout << "pouet" << endl;

  while( getline( inPathOtuBsFh, ligneOtuBs ) ) {
    VclusterOk.push_back( ligneOtuBs );
  }

  // recherche des cluster et idFa ds le dbc OP 

  string ligneDbc;

  int indOtuBs( 0 );
  
  cout << "prout" << endl;

  while( getline( inPathDbcFh, ligneDbc ) ) {

    string partLigne,
           cluster;
    istringstream iss( ligneDbc );
    int indPartLigne( 0 );

    while( getline( iss, partLigne, '\t' ) ) {
      
      if( indPartLigne == 1 ) {
        cluster = partLigne;
        cout << cluster << endl;
        if( find( VclusterOk.begin(), VclusterOk.end(), cluster) == VclusterOk.end() ) {
          break;
        }
      }
      if(( indPartLigne == 2 ) || ( indPartLigne == 3 )) {
        outPathFaFh << partLigne << endl;
      }

      indPartLigne++;
    }
  }


  inPathOtuBsFh.close();
  inPathDbcFh.close();
  outPathFaFh.close();
  

  return(0);
}

    


    
  
