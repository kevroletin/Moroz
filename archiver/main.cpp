#include "exception.h"
#include "compressors.h"

#include <iostream>
#include <iterator>
#include <algorithm>
#include <string>
#include <cstring>
#include <vector>

using namespace std;

class CmdLineParser {
public:
  CmdLineParser();
  bool parse_cmd_line(int argc, char* argv[]);

  enum State { ST_INIT,
               ST_COMPRESSION_TYPE,
               ST_FILES,
               ST_ERROR };

  enum Action { ACT_NONE,
                ACT_COMPRESSION,
                ACT_DECOMPRESSION,
                ACT_PRINT_HELP };

  enum Compression { COMPR_LWZ,
                     COMPR_HAFFMAN };

  State state;
  Action action;
  Compression compression;
  string last_error;
  vector<string> files;

  void error(string msg);
  void print_help();
  void dump();
};

CmdLineParser::CmdLineParser():
  state(ST_INIT),
  action(ACT_NONE),
  compression(COMPR_LWZ)
{}

bool CmdLineParser::parse_cmd_line(int argc, char* argv[]) {
  bool repeat = false;
  for (int i = 1;
       i < argc &&
       this->state != ST_ERROR &&
       this->action != ACT_PRINT_HELP;
       (repeat ? 0: ++i), repeat = false)
    {
    string argument = argv[i];
    switch (this->state) {
    case (ST_INIT): {
      if (argument == "-c") {
        this->state  = ST_COMPRESSION_TYPE;
        this->action = ACT_COMPRESSION;
      } else if (argument == "-d") {
        this->state = ST_FILES;
        this->action = ACT_DECOMPRESSION;
      } else if (argument == "-h") {
        this->state = ST_FILES;
        this->action = ACT_PRINT_HELP;
      } else {
        this->state = ST_FILES;
        repeat = true;
      }
      } break;
    case (ST_COMPRESSION_TYPE): {
      if (argument == "l") {
        this->compression = COMPR_LWZ;
        this->state = ST_FILES;
      } else if (argument == "h") {
        this->compression = COMPR_HAFFMAN;
        this->state = ST_FILES;
      } else {
        error("wrong compression type");
      }
      } break;
    case (ST_FILES): {
      files.push_back(argument);
    };
    }
  }

  if (this->action == ACT_NONE) {
    if (this->files.size() > 1) {
      this->action = ACT_COMPRESSION;
    } else if (this->files.size() == 1) {
      this->action = ACT_DECOMPRESSION;
    }
  }

  if (this->state != ST_ERROR && files.size() == 0) {
    error("no files specified");
  }
  return this->state != ST_ERROR;
}

void CmdLineParser::error(string msg) {
  this->state = ST_ERROR;
  this->last_error = msg;
}

void CmdLineParser::print_help() {
  std::cout << "\n"
               "    Usage: simple-arch [parameters] output_file input_file_1 [input_file_2 [...]]\n"
               "    where parameters are:\n"
               "        -c - compress; next after -c should be cpecified compression algorithm\n"
               "             available compression algorithms:\n"
               "             l - lwz\n"
               "             h - haffman(default)\n"
               "        -d - decompress\n";
}

void CmdLineParser::dump() {
  static const char* state_descr[] = { "ST_INIT",
                                       "ST_COMPRESSION_TYPE",
                                       "ST_FILES",
                                       "ST_ERROR" };
  static const char* action_descr[] =  { "ACT_NONE",
                                         "ACT_COMPRESSION",
                                         "ACT_DECOMPRESSION",
                                         "ACT_PRINT_HELP" };
  static const char* compression_descr[] = { "COMPR_LWZ",
                                             "COMPR_HAFFMAN" };

  cout << "State: " << state_descr[this->state] << endl
       << "Action: " << action_descr[this->action] << endl
       << "Compressoin: " << compression_descr[this->compression] << endl
       << "Last error: " << this->last_error << endl
       << "Files:";
  for (int i = 0; i < this->files.size(); ++i) {
    cout << " " << this->files[i];
  }
  cout << endl;
}

int main(int argc, char* argv[]) {
  CmdLineParser cmdp;
  if (false == cmdp.parse_cmd_line(argc, argv)) {
    cerr << "    error: " << cmdp.last_error << "\n";
    cmdp.print_help();
  } else {
    Haffman h;
    try {
      switch (cmdp.action) {
      case (CmdLineParser::ACT_COMPRESSION): {
        h.compress(cmdp.files);
      } break;
      case (CmdLineParser::ACT_DECOMPRESSION): {
        h.decompress(cmdp.files[0]);
      } break;
      case (CmdLineParser::ACT_PRINT_HELP):{
        cmdp.print_help();
      }
      }
    }
    catch (Error& e) {
      std::cerr << e.message();
    }
  }

  return 0;
}
