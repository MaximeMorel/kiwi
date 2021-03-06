
#ifndef KIWI_MPL_SAMETYPE_HPP
#define KIWI_MPL_SAMETYPE_HPP

#include "kiwi/core/Commons.hpp"

namespace kiwi{
namespace mpl{


template<typename T1, typename T2>
struct SameType{
  static const int value = 0;
  typedef kiwi::false_t type;
};
template<typename T>
struct SameType<T,T>{
  static const int value = 1;
  typedef kiwi::true_t type;
};


}//namespace
}//namespace

#endif
