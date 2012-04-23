#include "exception.h"
#include "compressors.h"

#include <iostream>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <limits>
#include <cassert>

using namespace std;

const unsigned TABLE_SIZE = std::numeric_limits<unsigned short>::max() + 1;

void write_num(unsigned short c) {
  //  printf("%hu", c);
  fwrite(&c, sizeof(unsigned short), 1, stdout);
}

void read_num(unsigned short& c) {
  //  scanf("%hu", &c);
  fread(&c, sizeof(unsigned short), 1, stdin);
}

void write_str(string& str) {
  cout << str;
}

void LZW::compress(vector<string>& files) {
  freopen(files[0].c_str(), "wb", stdout);

  sizes.clear();
  names.clear();
  for (unsigned i = 1; i < files.size(); ++i) {
    sizes.push_back(0);
    names.push_back(files[i]);
  }
  write_header();
  write_magic();
  
  for (unsigned i = 1; i < files.size(); ++i) {
    report_compression(files[i]);
    freopen(files[i].c_str(), "rb", stdin);
    compress_std_in_out(i - 1);
    write_magic();
    fclose(stdin);
  }

  fseek(stdout, 0, SEEK_SET);
  write_header();
  fclose(stdout);
}

void LZW::decompress(string& file) {
  freopen(file.c_str(), "rb", stdin);
  read_header();
  check_magic();

  for (unsigned i = 0; i < names.size(); ++i) {
    report_decompression(names[i]);
    freopen(names[i].c_str(), "wb", stdout);
    decompress_std_in_out(sizes[i]);
    check_magic();
    fclose(stdout);
  }
  fclose(stdin);
}

void LZW::compress_std_in_out(unsigned file_num) {
  init_tables();

  unsigned short last_value = 0;
  string buff;
  char c = getchar();
  
  unsigned long long out_size = 0;
  while (!feof(stdin)) {    
    buff.push_back(c);
    StrIntMap::iterator it = str_to_int.find(buff);
    if (it != str_to_int.end()) {
      last_value = it->second;
    } else {
      int i = str_to_int.size();
      if (str_to_int.size() < TABLE_SIZE) {
          str_to_int[buff] = i;
          int_to_str[i] = buff;
      }
      write_num(last_value);
      ++out_size;
      buff.erase(buff.begin(), --buff.end());
      last_value = str_to_int.find(buff)->second;
    }
    c = getchar();
  }
  if (buff.size()) {
    write_num(str_to_int[buff]);
    ++out_size;
  }
  sizes[file_num] = out_size;
}

unsigned long long LZW::compute_file_size(std::string file) {
    FILE* f = fopen(file.c_str(), "rb");
    fseek(f, 0, SEEK_END);
    int size = ftell(f);
    fclose(f);
    return size;
}

void LZW::decompress_std_in_out(unsigned long long symbols) {
  init_tables();

  unsigned short c;
  string last_str;
  bool first_time = true;
  for (unsigned long long i = 0; i < symbols; ++i) {
    read_num(c);
    std::map<unsigned short, std::string>::iterator it = int_to_str.find(c);
    string str;
    if (it == int_to_str.end()) {
      assert(c == int_to_str.size());
      last_str.push_back( last_str[0] );
      str = last_str;
    } else {
      str = it->second;
      last_str.push_back( str[0] );
    }
    unsigned short i = int_to_str.size();
    if (i < TABLE_SIZE && !first_time) {
      int_to_str[i] = last_str;
      str_to_int[last_str] = i;
    }
    write_str(str);
    last_str = str;
    first_time = false;
  }
}

void LZW::init_tables() {
  str_to_int.clear();
  int_to_str.clear();
  for (int i = 0; i < 256; ++i) {
    string str;
    str.push_back(i);
    str_to_int[str] = i;
    int_to_str[i] = str;
  }
}

void LZW::dump_tables() {
  for (unsigned i = 0; i < int_to_str.size(); ++i) {
    cerr << i << ": " << int_to_str[i].c_str() << endl;
  }
}

#ifdef SEPARATE_BUILD_LZW

int main(int argc, char* argv[]) {
  LZW lzw;
  vector<string> f;
  f.push_back("out.txt");
  f.push_back("in.txt");
  f.push_back("in2.txt");

  lzw.compress(f);

  lzw.decompress(f[0]);

  return 0;
}

#endif
