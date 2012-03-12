#include <cstdio>
#include <vector>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;

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
  unsigned bytes();
  
  void dump();
  void dump_raw();
  //protected:
  char data[32];
  int size;
};

class BitStringComputedShifts {
public:
  BitString strings[8];
  // TODO: remove after finishing debugging
  char values[8];
  char and_masks[8];

  BitStringComputedShifts(BitString& base_string);
  string char2bin(char c);
  void dump();
};

BitStringComputedShifts::BitStringComputedShifts(BitString& base_string) {
  strings[0] = base_string;
  values[0] = 0;
  and_masks[0] = 0xff;
  char base_mask = 0xff;
  for (int i = 1; i < 8; ++i) {
    values[i] = (values[i - 1] << 1) | strings[i - 1][0];
    and_masks[i] = base_mask | values[i];
    base_mask <<= 1;
    int j = 0;
    int len = strings[i - 1].bytes();
    for (; j <  len ? len - 1 : 0; ++j) {
      strings[i].data[j] = (strings[i - 1].data[j] << 1) | strings[i - 1][8 * j];
    }
    strings[i].data[j] = strings[i - 1].data[j];
    strings[i].size = strings[i - 1].size - 1;
  }
}

string BitStringComputedShifts::char2bin(char c) {
  char buff[9] = { 0 };
  char mask = 1;
  for (int j = 0; j < 8; ++j, mask <<= 1) {
    buff[7 - j] = (c & mask) ? '1' : '0';
  }
  return buff;
}

void BitStringComputedShifts::dump() {
  for (int i = 0; i < 8; ++i) {
    cout << i << ": (" << char2bin(and_masks[i]) << ") " << char2bin(values[i]) << " ";
    strings[i].dump();
  }  
}

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

unsigned BitString::bytes() {
  return !size ? 0 : (size - 1) / 8 + 1 ;
}

void BitString::dump() {
  for (int i = 0; i < size; ++i) {
    cout << (*this)[i];
    if (!((i + 1) % 8)) { cout << ' '; }
  }
  cout << endl;
}

void BitString::dump_raw() {
  for (int i = 0; i < 8; ++i) {
    printf("%02hhx ", data[i]);
    //if (!((i + 1) % 4)) { cout << endl; }
  }
  cout << endl;
}

#ifdef SEPARATE_BUILD

int main(int argc, char* argv[]) {
  BitString b;

  if (1) {
    b << 1 << 0 << 1 << 1 << 0 << 1 << 1 << 1 
      << 0 << 1 << 1 << 1 << 1 << 1 << 1 << 1
      << 0 << 0 << 0 << 0 << 0 << 0 << 0 << 0;
  } else {
    for (int i = 0; i < 32; ++i) {
      b << ((i + 1) % 8);
    }
  }
  
  b.dump();
  b.dump_raw();
  
  BitStringComputedShifts p(b);
  p.dump();
}

#endif
