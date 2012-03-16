#include <iostream>
#include <algorithm>

using namespace std;

struct Node {
  Node(): left_child(NULL), right_child(NULL) {}
  Node(int weight_,
       char sym_,
       Node* left_child_ = NULL,
       Node* right_child_ = NULL):
    weight(weight_), sym(sym_),
    left_child(left_child_), right_child(right_child_) {}
  int weight;
  char sym;
  Node* left_child;
  Node* right_child;
  bool operator< (Node& n) { return weight < n.weight; }

  void dump(int offset = 0) {
    for (int i = 0; i < offset; ++i) { cout << "  "; }
    cout << weight << "[" << int(sym)
      //<< ":" << sym
         << "]\n";
    if (left_child != NULL) { left_child->dump(offset + 1); }
    if (right_child != NULL) { right_child->dump(offset + 1); }
  };
};

bool heap_less(Node* a, Node* b) {
  return *a < *b;
}

bool cmp(int* a, int* b) {
  return *a > *b;
}

int main() {

#if 1

  int table[SYM_COUNT];
  for (int i = 0; i < SYM_COUNT; ++i) { table[i] = i; }
  random_shuffle(table, table + SYM_COUNT);
  Node* heap[SYM_COUNT];

  for (int i = 0; i < SYM_COUNT; ++i) {
    heap[i] = new Node(i, i);
  }

  make_heap(heap, heap + SYM_COUNT, &heap_less);

  cout << "====================" << 0 << endl;
  for (int j = 0; j < SYM_COUNT; ++j) {
    heap[j]->dump();
  }


  for (int i = SYM_COUNT - 1; i > 0 ; --i) {
    int scd = i;
    int fst = i - 1;
    pop_heap(heap, heap + scd + 1, &heap_less);
    pop_heap(heap, heap + fst + 1, &heap_less);
    Node* b = heap[scd];
    Node* a = heap[fst];
    heap[fst] = new Node(b->weight + a->weight, 0, a, b);
    push_heap(heap, heap + scd + 1, &heap_less);


    cout << "====================" << i << endl;
    for (int j = 0; j < scd; ++j) {
      heap[j]->dump();
    }
  }


#else
  int* a[50];
  for (int i = 0; i < 50; ++i) {
    a[i] = new int(i);
  }
  make_heap(a, a + 50, cmp);
  for (int i = 0; i < 50; ++i) {
    pop_heap(a, a + 50 - i, cmp);
  }
  for (int i = 0; i < 50; ++i) {
    cout << *a[i] << ' ';
  }
#endif

  return 0;
}
