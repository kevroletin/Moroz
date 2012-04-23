#ifndef __COMPRESSORS_H
#define __COMPRESSORS_H

#include "bitstring.h"

#include <string>
#include <vector>
#include <map>

extern void write_arr(const void* p, unsigned size);
extern void write_ll(unsigned long long i);
extern unsigned long long read_ll();

const int SYM_COUNT = 256;

struct Node;

extern void write_arr(const void* p, unsigned size);
extern void write_ll(unsigned long long i);
extern unsigned long long read_ll();

class BaseCompressor {
public:
  virtual void compress(std::vector<std::string>& files) = 0;
  virtual void decompress(std::string& file) = 0;  

  void read_header();
  void write_header();
  void dump_header();
  void write_magic();
  void check_magic();
  void check_magic(char const* msg);
  //  static const unsigned long long magic = 0x1234567890abcdef;
  void report_compression(std::string& file);
  void report_decompression(std::string& file);
  
  static const unsigned long long magic = 0xbaaaaaaaaaaaaaac;
  std::vector<std::string> names;
  std::vector<long long unsigned> sizes;
};

class Haffman: public BaseCompressor {
public:
  Haffman();
  //  void compress(vector<string> files);
  void preprocess();
  void preprocess_dummy();
  void build_codes();
  virtual void compress(std::vector<std::string>& files);
  virtual void decompress(std::string& file);
  unsigned char restore_symbol();
  void dump_table();
  void dump_codes();

  //protected:
  void write_table();
  void read_table();

  void read_header();
  void write_header();

  BitsIO io;
  Node* tree_root;
  long long unsigned table[SYM_COUNT];
  BitStringComputedShifts codes[SYM_COUNT];
};

class LZW: public BaseCompressor {
public:
  typedef std::map<std::string, unsigned short> StrIntMap;
  typedef std::map<unsigned short, std::string> IntStrMap;


  virtual void compress(std::vector<std::string>& files);
  virtual void decompress(std::string& file);

  //protectd:
  unsigned long long compute_file_size(std::string file);
  
  StrIntMap str_to_int;
  IntStrMap int_to_str;
  void init_tables();
  void dump_tables();
  void compress_std_in_out(unsigned file_num);
  void decompress_std_in_out(unsigned long long bytes);
};

#endif

