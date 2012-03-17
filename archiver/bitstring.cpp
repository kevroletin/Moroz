#include "bitstring.h"

#include <cstdio>
#include <vector>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;

string char2bin(unsigned char c) {
  char buff[9] = { 0 };
#if 0
  unsigned char mask = 1;
  for (int j = 0; j < 8; ++j, mask <<= 1) {
    buff[7 - j] = (c & mask) ? '1' : '0';
  }
#else
  sprintf(buff, "%hhx", c);
#endif
  return buff;
}

BitStringComputedShifts::BitStringComputedShifts() {}

BitStringComputedShifts::BitStringComputedShifts(BitString base_string) {
  strings[0] = base_string;
  or_masks[0] = 0;
  and_masks[0] = 0xff;
  unsigned char base_mask = 0xff;
  for (int i = 1; i < 8; ++i) {
    or_masks[i] = (or_masks[i - 1] << 1) | strings[i - 1][0];
    base_mask <<= 1;
    and_masks[i] = base_mask | or_masks[i];
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

BitStringComputedShifts::BitStringComputedShifts(BitStringComputedShifts& b) {
  memcpy(and_masks, b.and_masks, sizeof(and_masks));
  memcpy(or_masks, b.or_masks, sizeof(or_masks));
  for (int i = 0; i < 8; ++i) {
    strings[i] = b.strings[i];
  }
}

void BitStringComputedShifts::dump() {
  for (int i = 0; i < 8; ++i) {
    cerr << i << ": &(" << char2bin(and_masks[i]) << ") "
         << " |(" << char2bin(or_masks[i]) << ")  " ;
    strings[i].dump();
  }
}


BitsIO::BitsIO(): size(0), shift(0), writed(0),
                  read_buffer_shift(-1) {}

bool BitsIO::read_bit() {
  if (read_buffer_shift == -1) {
    scanf("%c", &read_buffer);
    read_buffer_shift = 7;
  }
  return read_buffer & (1 << read_buffer_shift--);
}

void BitsIO::flush_with_padding() {
  if (shift != 0) {
    unsigned char mask = 0xff << shift;
    buffer[size- 1] &= mask;
    shift = 0;
  }
  partial_flush();
}

BitsIO& BitsIO::operator<< (BitStringComputedShifts& b) {
  if (size + b.strings[shift].bytes() > BitsIO::BUFFER_MAX_SIZE) {
    partial_flush();
  }

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
  fprintf(stderr, "[%i:%i] ", size, shift);
  for (int i = 0; i < size - (shift != 0); ++i) {
    cerr << char2bin(buffer[i]);
    cerr << ' ';
  }
  if (shift != 0) {
    unsigned char tmp = (0xff << shift) & buffer[size - 1];
    cerr << char2bin(tmp);
  }
  cerr << endl;
}

void BitsIO::partial_flush() {
  for (int i = 0; i < size - (shift != 0); ++i) {
    printf("%c", buffer[i]);
    //    printf("%hhx", buffer[i]);
  }
  if (shift == 0) {
    //fwrite(buffer, 1, size, stdin);
    size = 0;
  } else {
    //fwrite(buffer, 1, size - 1, stdin);
    buffer[0] = buffer[size - 1];
    size = 1;
  }
}

BitString::BitString(): size(0) {
  memset(data, 0, sizeof(data));
}

BitString::BitString(BitString& b) {
  memcpy(data, b.data, 32);
  size = b.size;
}

BitString& BitString::operator<< (bool bit_value) {
  (*this)[size++] = bit_value;
  return *this;
}

BitString::BitProxy BitString::operator[] (unsigned index) {
  return BitProxy(*this, index);
}

bool BitString::pop() {
  bool res = int((*this)[size - 1]);
  --size;
  return res;
}

unsigned BitString::bytes() {
  return !size ? 0 : (size - 1) / 8 + 1;
}

int BitString::shift() {
  return (8 - size % 8) % 8;
}

void BitString::dump() {
#if 0
  for (int i = 0; i < size; ++i) {
    cerr << (*this)[i];
    if (!((i + 1) % 8)) { cerr << ' '; }
  }
#else
  for (int i = 0; i < bytes(); ++i) {
    fprintf(stderr, "%hhx", data[i]);
  }
#endif
  cerr << " [" << bytes() << ":" << shift() << "]"
       << " size:" << size
       << endl;
}

void BitString::dump_raw() {
  for (int i = 0; i < 8; ++i) {
    fprintf(stderr, "%02hhx ", data[i]);
    //if (!((i + 1) % 4)) { cerr << endl; }
  }
  cerr << endl;
}

#ifdef SEPARATE_BUILD_BIT_STRING

#include <cstdlib>

int main(int argc, char* argv[]) {

  if (1) {
    BitsIO bio;
    BitString b;
    b << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1
      << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1;
    BitStringComputedShifts bb(b);

    freopen("tmp.txt", "wb", stdout);

    bio << bb;
    bio.dump();
    bio.flush_with_padding();
    //    bio << bb;
    //bio.dump();
    //bio.flush_with_padding();

    fclose(stdout);

    //    freopen("tmp.txt", "rb", stdin);
    //fclose(stdin);
    return 0;
  }


#if 1

  BitsIO bio;
  freopen(argv[1], "rb", stdin);
  freopen(argv[2], "wb", stdout);

  BitString b;

  while (!feof(stdin)) {
    b.size = 0;
    int i = rand() % 32 + 1;
    int j = 0;
    while (!feof(stdin) && j++ < i) {
      b << bio.read_bit();
      if (feof(stdin)) { b.size--; }
    }
    if (j) {
      //b.dump();
      BitStringComputedShifts bb(b);
      //bb.dump();
      bio << bb;

      if (10*rand() < 2) { bio.partial_flush(); std::cerr << "flush"; }

      //bio.dump();
    }
  }
  cerr << bio.shift;
  //  bio.flush_with_padding();
  //bio.partial_flush();
  bio.flush_with_padding();
  fclose(stdin);
  fclose(stdout);

#else

  BitString b1, b2, b3, b4;
  b1 << 0 << 0 << 1 << 0 << 0 << 0 << 1 << 1;
  b2 << 0 << 0 << 1 << 0 << 0 << 0 << 0;
  b3 << 0 << 0 << 1 << 0 << 0 << 0 << 0 << 0;
  b4 << 1 << 0 << 0 << 0 << 0 << 1 << 0 << 0
     << 1 << 0 << 0 << 0 << 0 << 1 << 1 << 0
     << 1 << 0 << 0 << 0;

  BitStringComputedShifts p1(b1), p2(b2), p3(b3), p4(b4);
  BitsIO bio;

  bio << p1;
  bio.dump();
  bio << p2;
  bio.dump();
  bio << p3;
  bio.dump();
  bio << p4;
  bio.dump();

#endif

  return 0;
}

#endif
