#include <fstream>
#include <sstream>
#include <iostream>

#include <string>
#include <vector>
#include <map>

#include <algorithm>

#include <cctype>

using namespace std;



int main( int argc, char * argv[] ) {

  // établissement du flux 

  string pathGgopIn( argv[1] ),
         pathFaBdIn( argv[2] ),
         pathFaSeqMajoIn( argv[3] ),
         pathAssOut( argv[4] );

  bool dbName( argv[5] );

  ifstream inGgopFH( pathGgopIn.c_str() ),
           inFaBdFH( pathFaBdIn.c_str() ),
           inFaSeqMajoFH( pathFaSeqMajoIn.c_str() );
  ofstream outAssFH( pathAssOut.c_str() );


  // parcourt de la base de donné

  cout << "check data base" << endl; 

  string line;

  map<string, string> Mdb; // map<idGB, fullName>

  while( getline( inFaBdFH, line ) ) {
    if( line.at( 0 ) == '>' ) {
    
      line.erase( line.begin() );

      size_t pos = line.find( '\t' );

      string str1 = line.substr( 0, pos ),
             str2 = line.substr( pos+1 );

      Mdb.insert( pair<string,string>( str1, str2 ) );

    }
  }

  inFaBdFH.close();

  //for( map<string,string>::iterator it = Mdb.begin(); it != Mdb.end(); it++ ) {
  //  cout << "<<" << it->first << "><" << it->second << ">>" << endl;
  //}


  // parcourt du fasta de query
  
  cout << "check query fasta" << endl; 

  //int indClu( 1 );

  string seqId;

  vector<string> Vquery; // vector<seqId>
  map<string, string> Mquery; // map<seqId,seq>

  while( getline( inFaSeqMajoFH, line ) ) {
    if( line.at( 0 ) == '>' ) {
      line.erase( line.begin() );
      seqId = line;
    }
    else {
      Mquery.insert( pair<string, string>( seqId, line ) );
      Vquery.push_back( seqId );
    }
  }

  inFaSeqMajoFH.close();

  //for( map<string,string>::iterator it = Mquery.begin(); it != Mquery.end(); it++ ) {
  //  cout << "<<" << it->first << "><" << it->second << ">>" << endl;
  //}


  // parcourt du gg
  
  cout << "check gg" << endl; 

  map<string, vector<string> > Mgg; //map<seqId, vector<info> >

  while( getline( inGgopFH, line ) ) {

    int indCol( 0 );

    string partLigne;

    vector<string> Vinfo;

    istringstream iss( line );

    while( getline( iss, partLigne, '\t' ) ) {
      
      // seqId
      if( indCol == 0 ) {
        seqId = partLigne;
      }

      // dbID, pid, evalue
      if( indCol == 1 || indCol == 2 || indCol == 10) {
        Vinfo.push_back( partLigne );
      }

      indCol++;
    }

    // increment the map
    Mgg.insert( pair<string, vector<string> >( seqId, Vinfo ) );

  }

  inGgopFH.close();

  //for( map<string,vector<string>>::iterator it = Mgg.begin(); it != Mgg.end(); it++ ) {
  //  cout << "<<" << it->first << "><";
  //  for( vector<string>::iterator jt = it->second.begin(); jt != it->second.end(); jt++ ) {
  //    cout << *jt << "><";
  //  }
  //  cout << endl;
  //}


  // retreive the output
  
  cout << "output" << endl;
  
  int indClu = 1;

  //for( map<string,string>::iterator it = Mquery.begin(); it != Mquery.end(); it++ ) {
  for( vector<string>::iterator it = Vquery.begin(); it != Vquery.end(); it++ ) {
    
    outAssFH << indClu << '_' << *it << '\t';

    if( Mgg.find( *it ) != Mgg.end() ) {

      vector<string> Vinfo = Mgg[*it];

      outAssFH << Vinfo[1] << '\t' << Vinfo[2] << '\t' << Mdb[Vinfo[0]] << '\t' << Vinfo[0] << '\t' << Mquery[*it] << endl;

    }
    else {
      outAssFH << '\t' << '\t' << '\t' << '\t' << Mquery[*it] << endl;
    }

    indClu++;
  }







  //int indClu( 1 );

  //while( getline( inGgopFH, line ) ) {

  //  string partLigne,
  //         seqIdGg,
  //         seqMajo,
  //         evalue,
  //         taxo,
  //         idGb,
  //         pid;

  //  int indCol( 0 ),
  //      indPid;
  //  istringstream iss( line );

  //  while( getline( iss, partLigne, '\t' ) ) {
  //    
  //    // seqMajo
  //    if( indCol == 0 ) {
  //      outAssFH << indClu << '_' << partLigne << '\t';
  //      seqIdGg = partLigne.substr( 0, 498 );
  //      seqMajo = Mquery.find( '>' + seqIdGg )->second;
  //    }

  //    // taxo
  //    if( indCol == 1 ) {

  //      if( dbName == 1 ) {
  //        taxo = partLigne;
  //      }
  //      else {

  //        string partLigne2;
  //        istringstream iss2( partLigne );
  //        while( getline( iss2, partLigne2, '|' ) ) {
  //          // recup de l'index ds la bd
  //          
  //          string partLigne3;
  //          int indCol3( 0 );
  //          istringstream iss3( Mdb.find( partLigne2 )->second );
  //
  //          while( getline( iss3, partLigne3, '|' ) ) {
  //            if( indCol3 == 0 ) {
  //              idGb = partLigne3;
  //            }
  //            else {
  //              taxo += '|' + partLigne3;
  //            }
  //            indCol3++;
  //          }
  //
  //          size_t PR2 = partLigne.find( ';' ); // bug PR2 "|" vs Silva ";"
  //          if( PR2 != std::string::npos ) {
  //            taxo = taxo.substr( 1, taxo.length() );
  //            break;         
  //          }
  //          else{
  //            taxo = partLigne.substr( 1, partLigne.length() );
  //          }
  //  
  //        }
  //      }

  //    }

  //    // Pid
  //    
  //    if( indCol == 2 ) {
  //      pid = partLigne;
  //    }

  //    // evalue et ecriture de l'assignation
  //    if( indCol == 10 ) {
  //      outAssFH << partLigne << '\t' << pid << '\t' << taxo << '\t' << idGb << '\t' << seqMajo << endl;
  //    }

  //    indCol++;
  //  }

  //  indClu++;
  //}

  outAssFH.close();

  return(0);

}

    


    
  
