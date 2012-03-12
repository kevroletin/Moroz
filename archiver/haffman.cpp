#include <iostream>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

#include "exception.h"

using namespace std;

class Haffman {
public:
  Haffman();
  //  void compress(vector<string> files);
  void preprocess(vector<string> files);
  void decompress(string file);
  void dump();
protected:
  int table[256];
};

Haffman::Haffman() {
  memset(table, 0, sizeof(table));
}

void Haffman::preprocess(vector<string> files) {
  for (int i = 0; i < files.size(); ++i) {
    FILE* f = (FILE*)1;
    freopen(files[i].c_str(), "r", stdin);
    if (f == NULL ) {
      throw Error(string("can't open file: ") + files[i]);
    } else {
      char c = getchar();
      while (c != EOF) {
        ++table[c];
        c = getchar();
      }
    }
    fclose(stdin);
  }
}

void Haffman::dump() {
  cout << "\nTable:\n";
  int j = 0;
  for (int i = 0; i < 256; ++i) {
    printf("%-3i: %-7i ", i, this->table[i]);
  }
}

#ifdef SEPARATE_BUILD

int main(int argc, char* argv[]) {
  vector<string> f;
  for (int i = 1; i < argc; ++i) {
    f.push_back(argv[i]);
  }
  Haffman h;
  try {
    h.preprocess(f);
  }
  catch (Error e) {
    std::cout << e.message();
  }
  h.dump();
}

#endif
