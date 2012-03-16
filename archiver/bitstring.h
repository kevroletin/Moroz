#ifndef __BISTRING_H
#define __BISTRING_H

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
  BitString(BitString& b);

  BitString& operator<< (bool bit);
  bool pop();
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

  BitStringComputedShifts();
  BitStringComputedShifts(BitString base_string);
  BitStringComputedShifts(BitStringComputedShifts& b);

  void dump();
};

class BitsIO {
public:
  static const int BUFFER_MAX_SIZE = 128;
  //static const int BUFFER_MAX_SIZE = ;

  BitsIO();
  
  void flush_with_padding();
  void partial_flush();
  bool read_bit();
  BitsIO& operator<< (BitStringComputedShifts& b);

  //protected:
  char buffer[BUFFER_MAX_SIZE];
  unsigned char read_buffer;
  int read_buffer_shift;
  unsigned size;
  unsigned shift;
  long long writed;
  
  void dump();
};

#endif
