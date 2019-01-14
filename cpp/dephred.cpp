#include <fstream>
#include <iostream>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#include <vector>

using namespace std;

#include <Bpp/Seq/Alphabet.all>
#include <Bpp/Seq/Sequence.h>
#include <Bpp/Seq/SequenceWithQuality.h>
#include <Bpp/Seq/Io.all>
#include <Bpp/Seq/Container/SiteContainerTools.h>

using namespace bpp;


// fonction split

vector<string> &split( const string &s, char delim, vector<string> &elems ) {
  stringstream ss( s );
  string item;
  while ( getline( ss, item, delim )) {
    elems.push_back( item );
  }
  return elems;
}

vector<string> split( const string &s, char delim ) {
  vector<string> elems;
  split( s, delim, elems );
  return elems;
}

// départ!

int main( int argc, char * argv[] ) {
 
  // établissement du phred score et variables d'ouverture du fichier fastq
  
  string seuilPhredScoreChar = argv[1];
  int seuilPhredScore = atoi( seuilPhredScoreChar.c_str());

  int seuilAscii( seuilPhredScore + 33 );

  DNA *alpha(0);
  alpha = new DNA;

  Fastq fq;

  // établissement du flux pour l'ouverture des fichiers fastq mergé

  string cheminFichierEntre = argv[2];

  cout << cheminFichierEntre << endl;

  ifstream inputFH;
  inputFH.open( cheminFichierEntre.c_str() );
  
  // établissement du flux de sortie

  string cheminFichierSortieDephred = argv[3];

  string cheminFichierSortieFasta = argv[4];

  ofstream outputDephredFH( cheminFichierSortieDephred.c_str() );
  ofstream outputFastaFH( cheminFichierSortieFasta.c_str() );

  // boucle sur toute les séquences du fastq

  SequenceWithQuality seqFq ( alpha );

  while ( fq.nextSequence( inputFH, seqFq )) {
    
    // déphrédage
    
    vector<int> qual = seqFq.getQualities();

    for ( int i( 0 ); i < qual.size(); ++i ) {
      if ( qual[i] < seuilAscii ) {
        seqFq.setElement( i, "N" );
      }
    }

    fq.writeSequence ( outputDephredFH, seqFq );

    // écriture du fasta

    Fasta fa ( qual.size() );
    
    string nameSeq = seqFq.getName();
    string sequenceSeq = seqFq.toString();

    BasicSequence seqFa ( nameSeq,
  		    sequenceSeq,
  		    alpha );

    fa.writeSequence ( outputFastaFH, seqFa );

  //

  }

  inputFH.close();
  outputDephredFH.close();
  outputFastaFH.close();

  //

  return(0);
}

