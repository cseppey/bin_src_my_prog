#include <fstream>
#include <iostream>
#include <sstream>

#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

#include <string>
#include <vector>

#include <algorithm>

using namespace std;

//////////

vector<string> &split(const string &s, char delim, vector<string> &elems) {
  stringstream ss(s);
  string item;
  while (getline(ss, item, delim)) {
    elems.push_back(item);
  }
  return elems;
}

vector<string> split(const string &s, char delim) {
  vector<string> elems;
  split(s, delim, elems);
  return elems;
}

//////////


int main( int argc, char * argv[] ) {

  // établissement des flux pour l'ouverture des fichiers et répertoire

  string dirMrAgregIn( argv[1] ),
	     pathAssIn( argv[3] ),
	     pathMrIn( argv[5] );	 
  
  cout << dirMrAgregIn << endl;

  DIR *DH( 0 );
  DH = opendir( dirMrAgregIn.c_str() );

  ifstream inPathMrFH( pathMrIn.c_str() );	   
  
  // établissement des flux de sortie

  string pathMrOut = argv[2],
         pathAssOut = argv[4];

  ofstream outPathMrFH( pathMrOut.c_str() ),
	       outPathAssFH( pathAssOut.c_str() );

  // recherche des nom d'échantillon

  vector<string> Vech;
  string ligneEch;
  
  while( getline( inPathMrFH, ligneEch ) ) {
    vector<string> vs( split( ligneEch, '\t' ) );
    Vech.push_back( vs[0] );
  }

  inPathMrFH.close();  

  // établissement de la liste des path
 
  vector<int> VnoTaxo;
  string suf;

  struct dirent *nomFichier( 0 );
  struct stat filestat;

  while( nomFichier = readdir( DH ) ) {
    
    string pathMrAgreg = dirMrAgregIn + "/" + nomFichier->d_name;
    
    if ( stat( pathMrAgreg.c_str(), &filestat )) continue;
    if ( S_ISDIR( filestat.st_mode )) continue;
    
    vector<string> partNomFichier( split( nomFichier->d_name, '_' ) );
    
    suf = partNomFichier[0];

    int no( atoi( partNomFichier[1].c_str() ) );

    VnoTaxo.push_back( no );
  
  }

  sort( VnoTaxo.begin(), VnoTaxo.end() );

  
  // boucle sur les mat_rep agrégé 

  cout << "boucle sur mat agreg" << endl;

  vector<vector<string>> VVrep;

  for( int i=0; i < VnoTaxo.size(); i++ ) {
    
    if( i % 10 == 0 ){
      cout << i << '/' << VnoTaxo.size() << endl;
    }

    // ouverture du FH

    stringstream ss;
    ss << VnoTaxo[i];
    string pathMrAgregIn( dirMrAgregIn + "/" + suf + "_" + ss.str() );
    
    ifstream inPathMrAgregFH( pathMrAgregIn );

    // parcourt du mat rep agreg
  
    string ligneMrAgreg, 
           taxo; 

    int indLigne( 0 );
 
    while( getline( inPathMrAgregFH, ligneMrAgreg ) ) {
    
      if( indLigne > 0 ) {

    	// récupération des réponses
    
    	vector<string> Vrep;
        istringstream iss( ligneMrAgreg );
        string partLigne;
        while( getline( iss, partLigne, '\t' ) ) {
          Vrep.push_back( partLigne );
        }
    	VVrep.push_back( Vrep );

        outPathAssFH << '>' << Vrep[0] << '\t';
    
    	// établissement de tout les cluster en ordre croissant
    
        vector<int> VclusInt;
    	istringstream iss2( Vrep[0] );
        string partLigne2; 
        while( getline( iss2, partLigne2, '_' ) ) {
          int clu( atoi( partLigne2.c_str() ) );
          VclusInt.push_back( clu );
        }
        
        sort( VclusInt.begin(), VclusInt.end() );

        vector<string> VclusStr;
        for( int j=0; j < VclusInt.size(); j++ ) {
          
          stringstream ss2;
          ss2 << VclusInt[j];
          string cluStr( ss2.str() + '_' );
          VclusStr.push_back( cluStr );

        }

        // recherche des lignes des clusters
        
        ifstream inPathAssFH( pathAssIn.c_str() );
           
        string ligneAss;

        int indClu( 0 );

        while( getline( inPathAssFH, ligneAss ) ) {

          if( ligneAss.find( VclusStr[indClu] ) == 0 ) {
            
            istringstream iss3( ligneAss );
            string partLigne3,
                   nomClus,
                   evalue;
            
            int indPartLigne( 0 );
            
            while( getline( iss3, partLigne3, '\t' ) ) {
              
              if( indPartLigne == 0 ) {
                nomClus = partLigne3;
              }

              if( indPartLigne == 1 ) {
                evalue = partLigne3;
              }

              if(( indPartLigne == 2 ) && ( indClu == 0 )) {
                outPathAssFH << partLigne3 << endl;
              }

              if( indPartLigne == 3 ) {
                outPathAssFH << nomClus << '_' << evalue << '_' << partLigne3 << '\t';
              }

              if( indPartLigne == 4 ) {
                outPathAssFH << partLigne3 << endl;
              }

              indPartLigne++;
            }

            if( indClu == VclusStr.size()-1 ) {
              break;
            }
            
            indClu++;
          }
          
        }
        
        inPathAssFH.close();

      }

      indLigne++;
    }

    inPathMrAgregFH.close();
  }

  outPathAssFH.close();


  ////////////


  // écriture de la matrice de réponse

  int indEch( 0 );


  for( int i=0; i < Vech.size(); i++ ){

    outPathMrFH << Vech[i] << '\t';

    vector<string> VrepEch;
    for( int j=0; j < VVrep.size(); j++ ) {
      VrepEch.push_back( VVrep[j][i] );
      outPathMrFH << VVrep[j][i] << '\t';
    }

    outPathMrFH << endl;
  }
    
  outPathMrFH.close();

  return(0);
}

    


    
  
