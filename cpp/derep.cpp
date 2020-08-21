#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>

#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

#include <algorithm>

using namespace std;



// départ!

int main( int argc, char * argv[] ) {
 
  cout << "patates" << endl;
  
  // établissement du flux pour l'ouverture des fichiers fasta

  string pathDosFaIn = argv[1],
         pathFaOut = argv[2];

  int seuilNbEch = atoi( argv[3] ),
      seuilNbOcc = atoi( argv[4] );

  DIR *DH( 0 );
  DH = opendir( pathDosFaIn.c_str() );

  struct dirent *nomFichier( 0 );
  struct stat filestat;

  ofstream outPathFH( pathFaOut );


  // établissement map éch

  set<string> Sechs;
  map<string,int> MseqEch; // map<nomFa, cnt>

  while( nomFichier = readdir( DH ) ) {
    string pathFaIn( pathDosFaIn + "/" + nomFichier->d_name );

    if ( stat( pathFaIn.c_str(), &filestat )) continue;
    if ( S_ISDIR( filestat.st_mode )) continue;

    string nomFa( nomFichier->d_name ),
           idEch,
	   ligne;

    Sechs.insert( nomFa );

    istringstream iss( nomFa );
    while( getline( iss, ligne, '.' ) ) {
      idEch = ligne;
      break;
    }
    
    MseqEch.insert( pair<string,int>( idEch, 0 ) );
  }


  // parcourt du répertoire et décompte sÉquences pour chaque fa
  
  cout << "parcourt" << endl;

  map<string, pair< pair<int,int>, map<string,int> > > MseqTot;
    // map<seq, pair< pair<nbEch,nbSeq>, map<idEch,cnt> >>

  for( set<string>::iterator it = Sechs.begin(); it != Sechs.end(); it++ ) {
    
    string pathFaIn( pathDosFaIn + "/" + *it );

    ifstream inPathFaFH( pathFaIn );

    string ligne,
           idEch;

    // récupération de l'identifiant d'ech
    
    istringstream iss( *it );
    while( getline( iss, ligne, '.' ) ) {
      idEch = ligne;
      break;
    }

    cout << idEch << endl;

    // parcourt fasta
    
    while( getline( inPathFaFH, ligne ) ) {

      if( ! ligne.empty() ) {

	if( ligne.at( 0 ) != '>' ) {

      	  // si première rencontre de la séquence
	  if( MseqTot.find( ligne ) == MseqTot.end() ) {

	    // create the pair of counts and map of samples
	    pair<int,int> p( 1, 1 );
	    map<string,int> m = MseqEch;
	    
	    // increment m
	    m[idEch]++;

	    // create the pair of p and m
	    pair< pair<int,int>, map<string,int> > P( p, m );

	    // increment the map of sequences
	    MseqTot.insert( pair<string, pair< pair<int,int>, map<string,int> > > ( ligne, P ) );

	  }

	  // if the sequence is already in the map of seq
	  else {

	    // retreive P, p and m
	    pair< pair<int,int>, map<string,int> > P = MseqTot[ligne];
	    pair<int,int> p = P.first;
	    map<string,int> m = P.second;

	    // increment the nb of smp in p if it is the first occurrence in the sample
	    if( m[idEch] == 0 ) {
	      p.first++;
	    }

	    // increment the sequence counts in p and m
	    p.second++;
	    m[idEch]++;

	    // increment the MseqTot
	    MseqTot[ligne] = pair< pair<int,int>, map<string,int> > ( p, m );

	  }
	      
      	}
      }
    }

    inPathFaFH.close();

  }


  // writing of the dereplicated fasta

  cout << "dereplication" << endl;

  int seqNb( 0 );

  for( map< string, pair< pair<int,int>, map<string,int> > >::iterator it = MseqTot.begin(); it != MseqTot.end(); it++ ) {

    string seq = it->first;
    pair<int,int> p = it->second.first;
    map<string,int> m = it->second.second;

    // check if the sequence respect the threshold of smp nb and occurrence nb
    if( p.first >= seuilNbEch && p.second >= seuilNbOcc ) {
      
      // write the sequence name
      seqNb++;

      outPathFH << '>' << seqNb << '_' << p.second;

      for( map<string,int>::iterator jt = m.begin(); jt != m.end(); jt++ ) {
	outPathFH << '-' << jt->first << '_' << jt->second;
      }

      // write the sequence
      outPathFH << endl << seq << endl;

    }
  }
    
  outPathFH.close();

  //

  cout << "pilées" << endl;
  return(0);
}

