#include <cstdio>
#include <vector>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;

string char2bin(char c) {
  char buff[9] = { 0 };
  char mask = 1;
  for (int j = 0; j < 8; ++j, mask <<= 1) {
    buff[7 - j] = (c & mask) ? '1' : '0';
  }
  return buff;
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
  int shift();
  
  void dump();
  void dump_raw();
  //protected:
  char data[32];
  // BitStringComputedShifts can contain strings with length == 0 && shift < 0
  int size;
};

class BitStringComputedShifts {
public:
  BitString strings[8];
  char and_masks[8];
  char or_masks[8];

  BitStringComputedShifts(BitString& base_string);
  void dump();
};

BitStringComputedShifts::BitStringComputedShifts(BitString& base_string) {
  strings[0] = base_string;
  or_masks[0] = 0;
  and_masks[0] = 0xff;
  char base_mask = 0xff;
  for (int i = 1; i < 8; ++i) {
    or_masks[i] = (or_masks[i - 1] << 1) | strings[i - 1][0];
    and_masks[i] = base_mask | or_masks[i];
    base_mask <<= 1;
    int j = 0;
    int len = strings[i - 1].bytes();
    for (; j < len ? len - 1 : 0; ++j) {
      strings[i].data[j] = (strings[i - 1].data[j] << 1) | strings[i - 1][8 * (j + 1)];
    }
    strings[i].data[j] = (strings[i - 1].data[j] << 1);
    strings[i].size = strings[i - 1].size - 1;
    if (strings[i].size < 0) { strings[i].size = 0; }
  }
}

void BitStringComputedShifts::dump() {
  for (int i = 0; i < 8; ++i) {
    cout << i << ": &(" << char2bin(and_masks[i]) << ") "
         << " |(" << char2bin(or_masks[i]) << ")  " ;
    strings[i].dump();
  }  
}

class BitsIO {
public:
  static const int BUFFER_MAX_SIZE = 128;

  BitsIO();
  
  void flush_with_padding();
  void partial_flush();
  BitsIO& operator<< (BitStringComputedShifts& b);

  //protected:
  char buffer[BUFFER_MAX_SIZE];
  unsigned size;
  unsigned shift;
  long long writed;
  
  void dump();
};

BitsIO::BitsIO(): size(0), shift(0), writed(0) {}

void BitsIO::flush_with_padding() {
  if (shift != 0) {
    char mask = 0xff << shift;
    buffer[size] &= mask;
    ++size;
    shift = 0;
  } 
  partial_flush();
}

BitsIO& BitsIO::operator<< (BitStringComputedShifts& b) {
  if (shift != 0) {
    buffer[size - 1] &= b.and_masks[shift];
    buffer[size - 1] |= b.or_masks[shift];
  }
  memcpy(buffer + size, b.strings[shift].data, b.strings[shift].bytes());
  size += b.strings[shift].bytes();
  if (b.strings[shift].bytes() != 0) {
    shift = b.strings[shift].shift();
  } else {
    shift -= b.strings[0].size;
  }
  return *this;
}

void BitsIO::dump() {
  printf("[%i:%i] ", size, shift);
  for (int i = 0; i < size - (shift != 0); ++i) {
    cout << char2bin(buffer[i]);
    cout << ' ';
  }
  if (shift != 0) {
    char tmp = (0xff << shift) & buffer[size - 1];
    cout << char2bin(tmp);
  }
  cout << endl;
}

void BitsIO::partial_flush() {
  // TODO: find smth like write block
  fwrite(buffer, 1, size, stdin);  
  if (shift != 0) {
    buffer[0] = buffer[size];
  }
  size = 0;
}

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
  return !size ? 0 : (size - 1) / 8 + 1;
}

int BitString::shift() {
  return (8 - size % 8) % 8; 
}

void BitString::dump() {
  for (int i = 0; i < size; ++i) {
    cout << (*this)[i];
    if (!((i + 1) % 8)) { cout << ' '; }
  }
  cout << " [" << bytes() << ":" << shift() << "]" 
       << " size:" << size
       << endl;
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
  
  BitString b, b2, b3;

  if (1) {
    b   << 1 << 0 << 1 << 0 << 1 << 0 << 1 << 0 
        << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1
        << 0 << 0 << 0 << 0 << 1;

    b2  << 1 << 0 << 1 << 0 << 1 << 0 << 1 << 0 
        << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1
        << 0 << 0 << 0 << 0 << 0 << 0 << 0 << 1;

    b3  << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1
        << 1 << 1 << 1;
  } else {
    for (int i = 0; i < 32; ++i) {
      b << ((i + 1) % 8);
    }
  }
  

  // b.dump();
  // b.dump_raw();

  b.dump();
  b2.dump();
  
  BitsIO bio;
  bio.dump();
  BitStringComputedShifts p(b), p2(b2), p3(b3);
  bio << p;
  bio.dump();
  bio << p2;
  bio.dump();
  bio << p3;
  bio.dump();
  //p.dump();
}

#endif
