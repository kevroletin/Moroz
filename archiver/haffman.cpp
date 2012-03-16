#include "bitstring.h"

#include <iostream>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>

#include "exception.h"

using namespace std;

const int SYM_COUNT = 256;

struct Node;

class Haffman {
public:
  Haffman();
  //  void compress(vector<string> files);
  void preprocess(vector<string> files);
  void preprocess_dummy(vector<string> files);
  void build_codes();
  void compress(string file);
  void decompress(string file);
  unsigned char restore_symbol();
  void dump_table();
  void dump_codes();
  //protected:
  BitsIO io;
  Node* tree_root;
  unsigned table[SYM_COUNT];
  //  vector<int> file_sized;
  BitStringComputedShifts codes[SYM_COUNT];
};

struct Node {
  Node(): left_child(NULL), right_child(NULL) {}
  Node(unsigned weight_,
       unsigned char sym_,
       Node* left_child_ = NULL,
       Node* right_child_ = NULL):
    weight(weight_), sym(sym_),
    left_child(left_child_), right_child(right_child_) {}
  unsigned weight;
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

Haffman::Haffman(): tree_root(NULL) {
  memset(table, 0, sizeof(table));
}

void Haffman::preprocess(vector<string> files) {
  for (int i = 0; i < files.size(); ++i) {
    freopen(files[i].c_str(), "rb", stdin);
    if (stdin == NULL) {
      throw Error(string("can't open file: ") + files[i]);
    } else {
      while (!feof(stdin)) {
        unsigned char c;
        scanf("%c", &c);
        ++table[c];
      }
    }
    fclose(stdin);
  }
  build_codes();
}

void Haffman::dump_table() {
  cerr << "\nTable:\n";
  int j = 0;
  for (int i = 0; i < SYM_COUNT; ++i) {
    fprintf(stderr, "%-3u: %-7u \n", i, this->table[i]);
  }
}

void Haffman::dump_codes() {
  for (int i = 0; i < SYM_COUNT; ++i) {
    cerr << i << ": ";
    codes[i].strings[0].dump();
  }
}

void Haffman::preprocess_dummy(vector<string> files) {
  for (int i = 0; i < SYM_COUNT; ++i) {
    table[i] = i;
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

void Haffman::compress(string file) {
  freopen(file.c_str(), "rb", stdin);

  while (!feof(stdin)) {
    unsigned char c;
    scanf("%c", &c);

    //    codes[c].strings[0].dump();

    io << codes[c];
  }
  fclose(stdin);
}

unsigned char Haffman::restore_symbol() {
  Node* n = tree_root;
  while (n->right_child != NULL || n->left_child != NULL) {
    bool bit = io.read_bit();
    n = bit ? n->right_child : n->left_child;
  }
  return n->sym;
}

void Haffman::decompress(string file) {
  freopen(file.c_str(), "rb", stdin);

  //while (!feof(stdin)) {
  for (int i = 0; i < 100; ++i) {
    unsigned char c = restore_symbol();
    printf("%c", c);
  }
  fclose(stdin);
}

#ifdef SEPARATE_BUILD_HAFFMAN

int main(int argc, char* argv[]) {

  freopen("result", "wb", stdout);

  vector<string> f;
  for (int i = 1; i < argc; ++i) {
    f.push_back(argv[i]);
  }
  Haffman h;
  try {
    h.preprocess_dummy(f);
    //h.preprocess(f);

    //h.dump_table();
    //h.dump_codes();

    //h.compress(f[0]);
    h.decompress(f[0]);
  }
  catch (Error e) {
    std::cerr << e.message();
  }
  //h.dump_table();
  //h.dump_codes();
}

#endif
