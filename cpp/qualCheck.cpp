#include <fstream>
#include <iostream>
#include <sstream>

#include <string>

#include <math.h>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patates" << endl;
  
  // établissement du flux pour l'ouverture des fichiers fastq

  string pathFqIn = argv[1],
         pathFaOut = argv[2];

  double seuilErr = atof( argv[3] );
  
  int tailleMw = atoi( argv[4] );

  ifstream inPathFqFH( pathFqIn );
  ofstream outPathFaFH( pathFaOut );
    
  // parcourt fastq
  
  string ligne,
         titre,
         seq;
  
  int indLigne( 0 );

  while( getline( inPathFqFH, ligne ) ) {

    // titre
    if( indLigne % 4 == 0 ) {
      titre = ligne;
    }
    
    // seq
    if( indLigne % 4 == 1 ) {
      seq = ligne;
    }
    
    // score
    if( indLigne % 4 == 3 ) {
      
      // calcul de la fenetre minimum
      
      double probaMax( 0 );
      int seqScrap( 0 );

      while( ligne.size() >= tailleMw ) {
        
        string subSeq( ligne.substr( 0, tailleMw ) );
        double proba( 0 );
        
        for( int j = 0; j < subSeq.size(); j++ ) {
          //proba += pow( 10.0, -( subSeq[j]-33.0 )/10.0 );
          proba += subSeq[j];
        }
        
        proba /= tailleMw;
        
        if( proba > probaMax ) {
        //if( proba < probaMax ) {
          probaMax = proba;
          if( probaMax > seuilErr ) {
          //if( probaMax < seuilErr ) {
            seqScrap++;
            break;
          }
        }

        ligne.erase( ligne.begin() );
      }

      // écriture du fasta
      
      if( seqScrap == 0 ) {
        outPathFaFH << '>' << titre.substr( 1, titre.length()-1 ) << endl << seq << endl;
      }
    
    }

    if( indLigne % 100000 == 0 ) {
      cout << indLigne / 4 << endl;
    }

    indLigne++;
  }

  inPathFqFH.close();
  outPathFaFH.close();

  //

  cout << "pilées" << endl;
  return(0);
}

