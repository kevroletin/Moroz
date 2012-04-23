#include "bitstring.h"
#include "exception.h"
#include "bitstring.h"
#include "compressors.h"

#include <iostream>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>

void write_arr(const void* p, unsigned size) {
  fwrite(p, 1, size, stdout);
}

void write_ll(unsigned long long i)  {
  fwrite(&i, sizeof(long long int), 1, stdout);
}

unsigned long long read_ll() {
  unsigned long long i;
  if (feof(stdin)) { throw Error("unexpected end of file"); }
  fread(&i, sizeof(long long int), 1, stdin);
  return i;
}

using namespace std;

struct Node {
  Node(): left_child(NULL), right_child(NULL) {}
  Node(long long unsigned weight_,
       unsigned char sym_,
       Node* left_child_ = NULL,
       Node* right_child_ = NULL):
    weight(weight_), sym(sym_),
    left_child(left_child_), right_child(right_child_) {}
  long long unsigned weight;
  unsigned char sym;
  Node* left_child;
  Node* right_child;
  bool operator< (Node& n) { return weight < n.weight; }

  void dump(int offset = 0) {
    for (int i = 0; i < offset; ++i) { cerr << "  "; }
    cerr << weight << "[" << int(sym)
      //<< ":" << sym
         << "]\n";
    if (left_child != NULL) { left_child->dump(offset + 1); }
    if (right_child != NULL) { right_child->dump(offset + 1); }
  };
  static bool heap_less(Node* a, Node* b) {
    return *a < *b;
  }
  static bool heap_gt(Node* a, Node* b) {
    return !(*a < *b);
  }
  void restore_codes(BitString& path, Haffman& haffman) {
    if (left_child == NULL && right_child == NULL) {
      haffman.codes[sym] = BitStringComputedShifts(path);
    }
    path << 0;
    if (left_child != NULL) {
      left_child->restore_codes(path, haffman);
    }
    --path.size;
    path << 1;
    if (right_child != NULL) {
      right_child->restore_codes(path, haffman);
    }
    --path.size;
  }
};

Haffman::Haffman(): tree_root(NULL) {}

void Haffman::preprocess() {
  memset(table, 0, sizeof(table));
  sizes.clear();
  for (unsigned i = 0; i < names.size(); ++i) {
    freopen(names[i].c_str(), "rb", stdin);
    if (stdin == NULL) {
      throw Error(string("can't open file: ") + names[i]);
    } else {
      sizes.push_back(0);
      while (!feof(stdin)) {
        unsigned char c;
        scanf("%c", &c);
        ++table[c];
        ++sizes[i];
      }
      --sizes[i];
    }
    fclose(stdin);
  }
  build_codes();
}

void Haffman::dump_table() {
  cerr << "\nTable:\n";
  for (int i = 0; i < SYM_COUNT; ++i) {
    fprintf(stderr, "%-3u: %-7llu \n", i, this->table[i]);
  }
}

void Haffman::dump_codes() {
  for (int i = 0; i < SYM_COUNT; ++i) {
    cerr << i << ": ";
    codes[i].strings[0].dump();
  }
}

void BaseCompressor::dump_header() {
  fprintf(stderr, "size: %i\n", sizes.size());
  for (unsigned i = 0; i < sizes.size(); ++i) {
    fprintf(stderr, "%llu %s\n", sizes[i], names[i].c_str());
  }
  fprintf(stderr, "\n");
}

void BaseCompressor::read_header() {
  sizes.clear();
  names.clear();
  char buff[1024];
  unsigned long long size = read_ll();
  for (unsigned i = 0; i < size; ++i) {
    unsigned long long s = read_ll();
    sizes.push_back(s);
    scanf("%s ", buff);
    names.push_back(buff);
  }
}

void Haffman::read_header() {
  BaseCompressor::read_header();
  read_table();
}

void Haffman::read_table() {
  check_magic("table start");
  fread(table, sizeof(table[0]), 256, stdin);
  check_magic("header finish");
}

void BaseCompressor::write_header() {
  write_ll(sizes.size());
  for (unsigned i = 0; i < sizes.size(); ++i) {
    write_ll(sizes[i]);
    printf("%s ", names[i].c_str());
  }
}

void Haffman::write_header() {
  BaseCompressor::write_header();
  write_table();
}

void Haffman::write_table() {
  write_magic();
  fwrite(table, sizeof(table[0]), 256, stdout);
  write_magic();
}

void Haffman::preprocess_dummy() {
  for (int i = 0; i < SYM_COUNT; ++i) {
    table[i] = i;
  }
  sizes.clear();
  for (unsigned i = 0; i < names.size(); ++i) {
    sizes.push_back(0);
    freopen(names[i].c_str(), "rb", stdin);
    while(!feof(stdin)) {
      getchar();
      ++sizes[i];
    }
    --sizes[i];
    fclose(stdin);
  }
  //random_shuffle(table, table + SYM_COUNT);
  build_codes();
}

void Haffman::build_codes() {
  Node* heap[SYM_COUNT];
  for (int i = 0; i < SYM_COUNT; ++i) {
    unsigned freq = table[i];
    heap[i] = new Node(freq, i);
  }

  make_heap(heap, heap + SYM_COUNT, &Node::heap_gt);

  for (int i = SYM_COUNT - 1; i > 0 ; --i) {
    int scd = i;
    int fst = i - 1;
    pop_heap(heap, heap + scd + 1, &Node::heap_gt);
    pop_heap(heap, heap + fst + 1, &Node::heap_gt);
    Node* b = heap[scd];
    Node* a = heap[fst];
    heap[fst] = new Node(b->weight + a->weight, 0, a, b);
    push_heap(heap, heap + fst + 1 , &Node::heap_gt);
  }
  tree_root = heap[0];

  BitString path;
  heap[0]->restore_codes(path, *this);
}

void Haffman::compress(vector<string>& files) {
  string out_file = files[0];
  names.clear();
  for (unsigned i = 1; i < files.size(); ++i) {
    names.push_back(files[i]);
  }
  preprocess();
  freopen(out_file.c_str(), "wb", stdout);
  write_header();

  for (unsigned i = 0; i < names.size(); ++i) {
    report_compression(names[i]);
    freopen(names[i].c_str(), "rb", stdin);
    unsigned char c;
    scanf("%c", &c);
    while (!feof(stdin)) {
      io << codes[c];
      scanf("%c", &c);
    }
    io.flush_with_padding();
    //    write_magic();
    fclose(stdin);
  }

  fclose(stdout);
}

unsigned char Haffman::restore_symbol() {
  Node* n = tree_root;
  while (n->right_child != NULL || n->left_child != NULL) {
    bool bit = io.read_bit();
    n = bit ? n->right_child : n->left_child;
  }
  return n->sym;
}

void Haffman::decompress(string& file) {
  freopen(file.c_str(), "rb", stdin);
  read_header();
  build_codes();

  for (unsigned i = 0; i < names.size(); ++i) {
    report_decompression(names[i]);
    io.refresh();
    freopen(names[i].c_str(), "wb", stdout);
    for (unsigned long long j = 0; j < sizes[i]; ++j) {
      unsigned char c = restore_symbol();
      printf("%c", c);
    }
    //check_magic("file finish");
    fclose(stdout);
  }
  fclose(stdin);
}

void BaseCompressor::write_magic() {
  write_ll(Haffman::magic);
}

void BaseCompressor::check_magic() {
  unsigned long long u = read_ll();
  if (u != BaseCompressor::magic) {
    fprintf(stderr, "%llx\n", u);
    throw Error("wrong magic (corrupted file?)");
  }
}

void BaseCompressor::check_magic(char const* msg) {
#ifdef DEBUG
  fprintf(stderr, "magic: %s ", msg);
#endif
  check_magic();
#ifdef DEBUG
  fprintf(stderr, " ok\n");
#endif
}

void BaseCompressor::report_compression(string& file) {
  std::cerr << "compressing " << file.c_str() << endl;
}

void BaseCompressor::report_decompression(string& file) {
  std::cerr << "decompressing " << file.c_str() << endl;
}

#ifdef SEPARATE_BUILD_HAFFMAN

int main(int argc, char* argv[]) {

  Haffman h;

  string o;
  vector<string> f;
  for (int i = 2; i < argc; ++i) {
    f.push_back(argv[i]);
  }
  try {
    if (0) {
      h.compress(f);
    } else {
      h.decompress(f[0]);
    }
  }
  catch (Error e) {
    std::cerr << e.message();
  }
  //h.dump_table();
  //h.dump_codes();
}

#endif
