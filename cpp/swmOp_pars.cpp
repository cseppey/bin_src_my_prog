#include <fstream>
#include <sstream>
#include <iostream>

#include <string>
#include <vector>
#include <map>
#include <set>

#include <algorithm>

using namespace std;



int main( int argc, char * argv[] ) {

  // établissement du flux

  string pathSmopIn( argv[1] ),
         pathFaDerepIn( argv[2] ),
         
         pathMrOut( argv[3] ),
         pathFaSeqMajo( argv[4] );

  ifstream inSmopFH( pathSmopIn.c_str() ),
           inFaDerepFH( pathFaDerepIn.c_str() );
  
  ofstream outMrFH( pathMrOut.c_str() ),
           outFaSeqMajoFH( pathFaSeqMajo.c_str() );

  // parcourt derep

  int ind( 1 );
  string ligne,
         nomFaDerep,
         idDerep;
  vector<string> Vsmp;
  map<string, string> MseqDerep; // map<idDerep, seq>
  map<string, map<string,int> > MoccDerep; //map<idDerep, map<smp,occ_derep>>

  while( getline( inFaDerepFH, ligne ) ) {
    if( ligne.at( 0 ) == '>' ) {
      int sepSmp( ligne.find_first_of( '-' )-1 );
      idDerep = ligne.substr( 1, sepSmp );
      map<string, int> MsmpOcc; // map<smp,occ>

      ligne += '-';
      ligne.erase( 0, sepSmp+2 );

      // fill vector pr pair smp occ
      while( ligne.length() > 0 ) {
        sepSmp = ligne.find_first_of( '-' );

        string smpOcc( ligne.substr( 0, sepSmp ) );

        int sepOcc( smpOcc.find_first_of( '_' ) );

        string smp( smpOcc.substr( 0, sepOcc ) );
        int occ( atoi( smpOcc.substr( sepOcc+1, smpOcc.length() ).c_str() ) );

        MsmpOcc.insert( pair<string, int>( smp, occ) );

        if( ind == 1 ) {
          Vsmp.push_back( smp );
        }

        ligne.erase( 0, sepSmp+1 );
      }

      // populate the map of seq derep
      MoccDerep.insert( pair<string, map<string, int> >( idDerep, MsmpOcc ) );

    }
    else { //populate the map of sequence
      MseqDerep.insert( pair<string, string>( idDerep, ligne ) );
    }

  }
    
  // parcourt swm OP

  int indClu( 1 );
  map<string, map<string, int> > Mreps; //map<no_otu, map<smp, occ_OTUs> >

  while( getline( inSmopFH, ligne ) ) {
    
    ligne += ' ';

    // initialisation of the OTU and its response

    string idOTU;
    map<string, int> Mocc; // map<smp, occ_OTU>

    for( vector<string>::iterator it = Vsmp.begin(); it != Vsmp.end(); it++ ) {
      Mocc.insert( pair<string, int>( *it, 0 ) );
    }

    // loop in the derep

    int sepDerep( ligne.find_first_of( ' ' ) );
    idOTU = ligne.substr( 0, sepDerep );
    idDerep = idOTU;

    ligne.erase( 0, sepDerep+1 );

    while( ligne.length() > 0 ) {

      map<string, int> Mderep( MoccDerep[idDerep] ); // map<smp,occ_derep>

      for( map<string, int>::iterator it = Mderep.begin(); it != Mderep.end(); it++ ) {
        Mocc[it->first] += it->second;
      }

      //---
      
      sepDerep = ligne.find_first_of( ' ' );
      idDerep = ligne.substr( 0, sepDerep );

      ligne.erase( 0, sepDerep+1 );
    }

    // save OTU id and reps

    Mreps.insert( pair<string, map<string, int> >( idOTU, Mocc ) );

    indClu++;

    // write fasta

    outFaSeqMajoFH << '>' << idOTU << endl;
    outFaSeqMajoFH << MseqDerep[idOTU] << endl;

  }


  // write the community matrix

  for( map<string, map<string, int> >::iterator it = Mreps.begin(); it != Mreps.end(); it++ ) {
    outMrFH << '\t' << it->first << '_';
  }

  for( vector<string>::iterator it = Vsmp.begin(); it != Vsmp.end(); it++ ) {
    outMrFH << endl << *it;

    for( map<string, map<string, int> >::iterator jt = Mreps.begin(); jt != Mreps.end(); jt++ ) {
      outMrFH << '\t' << Mreps[jt->first][*it]; 
    }
  }


  cout << "burp!" << endl;

  return(0);

}

    
