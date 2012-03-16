#ifndef __EXCEPTION_H
#define __EXCEPTION_H

#include <string>

enum ErrorCode {
  ERR_UNDEFUNED
};

class BaseError {
public:
  virtual std::string message() = 0;
  virtual ErrorCode code() = 0;
};

class Error {
public:
  Error(ErrorCode code);
  Error(ErrorCode code, std::string msg);
  Error(std::string msg);
  
  virtual std::string message();
  virtual ErrorCode code();
private:
  std::string msg;
  ErrorCode code_val;
};

Error::Error(ErrorCode code_):
  code_val(code_),
  msg("unspecified") {}

Error::Error(ErrorCode code_, std::string msg_): 
  msg(msg_), 
  code_val(code_) {}

Error::Error(std::string msg_): msg(msg_), code_val(ERR_UNDEFUNED) {}

std::string Error::message() {
  return this->msg;
}

ErrorCode Error::code() {
  return this->code_val;
}


#endif
