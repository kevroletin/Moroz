#ifndef __COMPRESSORS_H
#define __COMPRESSORS_H

#include "bitstring.h"

#include <string>
#include <vector>

const int SYM_COUNT = 256;

struct Node;

class Haffman {
public:
  Haffman();
  //  void compress(vector<string> files);
  void preprocess();
  void preprocess_dummy();
  void build_codes();
  void compress(std::vector<std::string>& files);
  void decompress(std::string& file);
  unsigned char restore_symbol();
  void dump_table();
  void dump_codes();
  void dump_header();
  //protected:
  void write_magic();
  void check_magic();
  void check_magic(char const* msg);
  //  static const unsigned long long magic = 0x1234567890abcdef;
  static const unsigned long long magic = 0xbaaaaaaaaaaaaaac;

  void read_header();
  void write_header();
  void write_table();

  std::vector<std::string> names;
  std::vector<long long unsigned> sizes;
  BitsIO io;
  Node* tree_root;
  long long unsigned table[SYM_COUNT];
  BitStringComputedShifts codes[SYM_COUNT];
};

#endif

