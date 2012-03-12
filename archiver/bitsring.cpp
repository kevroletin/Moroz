#include <cstdio>
#include <vector>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;

class BitStringComputedShifts {
public:
  char arraya[7][32];
  char shifts[6];

  BitStringComputedShifts(char data[32]);
  void dump();
};

BitStringComputedShifts::BitStringComputedShifts(char data[32]) {

}

void BitStringComputedShifts::dump() {
  
}

class BitString {
public:
  class BitProxy {
  public:
    BitProxy(BitString& parent_, unsigned index_): 
      parent(parent_), index(index_) {}
    BitProxy& operator= (bool bit_value) {
      int byte = index / 8;
      int bit  = 7 - index % 8;
      int mask = (1 << bit);
      if (bit_value) {
        parent.data[byte] |= mask;
      } else {
        parent.data[byte] &= (~mask);
      }

      int data = parent.data[byte] & mask;
      cout << bool(data) << endl;
    };
    operator int() {
      int byte = index / 8;
      int bit  = 7 - index % 8;
      int mask = (1 << bit);
      char value = parent.data[byte] & mask;

      return (value ? 1 : 0);
    }
    BitString& parent;
    unsigned index;
  };
  friend class BitProxy;

  BitString();

  BitString& operator<< (bool bit);
  BitProxy operator[] (unsigned index);
  
  void dump();
  void dump_raw();
  //protected:
  char data[32];
  int size;
};

class BitBuffer {
public:
  void flush_with_padding();

  unsigned buff_size();  
protected:
  unsigned capacity;

  unsigned partial_flush();
};

BitString::BitString(): size(0) { 
  memset(data, 0, sizeof(data));
}

BitString& BitString::operator<< (bool bit_value) {
  (*this)[size++] = bit_value;
  return *this;
}

BitString::BitProxy BitString::operator[] (unsigned index) {
  return BitProxy(*this, index);
}

void BitString::dump() {
  for (int i = 0; i < size; ++i) {
    cout << (*this)[i];
  }
  cout << endl;
}

void BitString::dump_raw() {
  for (int i = 0; i < 8; ++i) {
    printf("%02hhx ", data[i]);
    if (!((i + 1) % 4)) { cout << endl; }
  }
}

#ifdef SEPARATE_BUILD

int main(int argc, char* argv[]) {
  BitString b;
  b << 1 << 0 << 1 << 0;
  cout << endl;
  b.dump();
  b.dump_raw();
}

#endif
