#include <fstream>
#include <iostream>
#include <sstream>

#include <string>
#include <vector>
#include <set>
#include <map>


using namespace std;

//////////

int main( int argc, char * argv[] ) {

  // établissement des flux pour l'ouverture des fichiers et répertoire

  string pathDbcIn( argv[1] ),
         pathAssIn( argv[2] ),
         pathMrOut( argv[3] ),
         pathAssOut( argv[4] );

  ifstream inDbcFH( pathDbcIn ),
           inAssFH( pathAssIn );
  ofstream outMrFH( pathMrOut ),
           outAssFH( pathAssOut );

  // parcourt dbc454

  string ligne;
  int indLigne( 0 );
  map<int, set<int>> Mdbc;

  while( getline( inDbcFH, ligne ) ) {
    if( indLigne > 0 ) {

      string partLigne;
      istringstream iss( ligne );
      int indPartLigne( 0 ),
          clu;
      while( getline( iss, partLigne, '\t' ) ) {
  
        // inclusion des nouveau cluster
        if( indPartLigne == 1 ) {

          clu = atoi( partLigne.c_str() );
          if( Mdbc.find( clu ) == Mdbc.end() ) {
            set<int> s;
            Mdbc.insert( pair<int, set<int>>( atoi( partLigne.c_str() ), s ) );
          }

        }
        // inclusion des seq derep
        if( indPartLigne == 2 ) {

          size_t pos( partLigne.find( '_' ) );
          int derep( atoi( partLigne.substr( 1, pos ).c_str() ) );

          set<int> Sderep( Mdbc[ clu ] );
          Sderep.insert( derep );
          Mdbc[ clu ] = Sderep;
        }

        indPartLigne++;
      }

    }
    indLigne++;
  }

  // parcourt ass

  map<int, pair<pair<map<string, int>, string>, int>> Mass; // map<derep, pair<pair<map<ech, abds_ech>, info>, abds_derep>>

  while( getline( inAssFH, ligne ) ) {

    string partLigne,
           info;
    int derep,
        abdsDerep;
    map<string, int> Mrep;

    istringstream iss( ligne );
    int indPartLigne( 0 );
    while( getline( iss, partLigne, '\t' ) ) {

      // derep, abds derep, rep
      if( indPartLigne == 0 ) {
      
        string partLigne2;
        istringstream iss2( partLigne );
        int indPartLigne2( 0 );
        while( getline( iss2, partLigne2, '-' ) ) {

          string partLigne3,
                 ech;
          istringstream iss3( partLigne2 );
          int indPartLigne3( 0 );
          while( getline( iss3, partLigne3, '_' ) ) {

            // derep, abds
            if( indPartLigne2 == 0 ) {
              if( indPartLigne3 == 1 ) {    // derep
                derep = atoi( partLigne3.c_str() );
              }
              if( indPartLigne3 == 2 ) {    // abds
                abdsDerep = atoi( partLigne3.c_str() );
              }
            }

            // reponse
            else {
              if( indPartLigne3 == 0 ) {    // ech
                ech = partLigne3;
              }
              else {    // abds ech
                Mrep.insert( pair<string, int>( ech, atoi( partLigne3.c_str() ) ) );
              }
            }

            indPartLigne3++;
          }

          indPartLigne2++;        
        }
      }

      // evalue
      if( indPartLigne == 1 ) {
        info = partLigne;
      }

      // pid
      if( indPartLigne == 2 ) {
        info += '%';
        info += partLigne;
      }

      // taxo
      if( indPartLigne == 4 ) {
        info += '%';
        info += partLigne;
      }

      // seq
      if( indPartLigne == 6 ) {
        info += '%';
        info += partLigne;
      }

      indPartLigne++;
    }

    // insersion map

    pair<map<string, int>, string> p1( Mrep, info );
    pair<pair<map<string, int>, string>, int> p2( p1, abdsDerep );
    Mass.insert( pair<int, pair<pair<map<string, int>, string>, int>>( derep, p2 ) );

  }

  // output

  map<string, vector<int>> MrepEch;

  for( map<int, set<int>>::iterator it = Mdbc.begin(); it != Mdbc.end(); it++ ) {
    
    outMrFH << '\t' << it->first;

    map<string, int> MrepClu;
    pair<int, pair<int, string>> PderepMajoInfo;    // pair<abds, pair<derep, info>>
    
    // recherche réponse et info dominant
    for( set<int>::iterator jt = it->second.begin(); jt != it->second.end(); jt++ ) {
  
      // addition des réponses
      map<string, int> Mrep( Mass[ *jt ].first.first );
      
      for( map<string, int>::iterator kt = Mrep.begin(); kt != Mrep.end(); kt++ ) {
        if( MrepClu.size() == 0 ) {
          MrepClu = Mrep;
        }
        else {
          MrepClu[ kt->first ] += kt->second;
        }
      }

      // recherche derep dominant
      int abds( Mass[ *jt ].second );
      if( abds > PderepMajoInfo.first ) {
        pair<int, string> p1( *jt, Mass[ *jt ].first.second );
        pair<int, pair<int, string>> p2( abds, p1 );
        PderepMajoInfo = p2;
      }
    
    }


    // écriture ass
    outAssFH << it->first << '_' << PderepMajoInfo.second.first << '_' << PderepMajoInfo.first;

    string partLigne; 
    istringstream iss( PderepMajoInfo.second.second );
    while( getline( iss, partLigne, '%' ) ) {
      outAssFH << '\t' << partLigne;
    }
    outAssFH << endl;

    // reorganisation reponses
    int indClu( 0 );
    for( map<string, int>::iterator jt = MrepClu.begin(); jt != MrepClu.end(); jt++ ) {
      if( MrepEch.find( jt->first ) == MrepEch.end() ) {
        vector<int> v;
        v.push_back( jt->second );
        MrepEch.insert( pair<string, vector<int>>( jt->first, v ) );
      }
      else {
        MrepEch.find( jt->first )->second.push_back( jt->second );
      } 
            
      indClu++;
    }

  }

  // écriture de la matrice de reponse

  for( map<string, vector<int>>::iterator it = MrepEch.begin(); it != MrepEch.end(); it++ ) {
    outMrFH << endl << it->first;
    for( vector<int>::iterator jt = it->second.begin(); jt != it->second.end(); jt++ ) {
      outMrFH << '\t' << *jt;
    }
  }


  return(0);
}

    


    
  
