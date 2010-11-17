// Copyright (c) 2010 Nicolas Silva
// All rights reserved.
//      Redistribution and use in source and binary forms, with or without
//      modification, are permitted provided that the following conditions are
//      met:
//      
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above
//        copyright notice, this list of conditions and the following disclaimer
//        in the documentation and/or other materials provided with the
//        distribution.
//      * Neither the name of the  nor the names of its
//        contributors may be used to endorse or promote products derived from
//        this software without specific prior written permission.
//      
//      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//      A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "SimplePipeline.hpp"
#include <set>
#include <utility>

namespace kiwi
{
namespace core
{


SimplePipeline::SimplePipeline()
	: AbstractPipeline()
{
	ScopedBlockMacro(s1, "kiwi::core::SimplePipeline: constructor");

}



bool SimplePipeline::contains(Node* node)
{
	ScopedBlockMacro(s1, "kiwi::core::SimplePipeline: contains");
	Filter* fPtr = dynamic_cast<Filter*>(node);
	if(fPtr)
	{
		if(findFilter(fPtr) >= 0) return true;
	}
	
	// TODO findResource
	return false;
}


int SimplePipeline::findFilter(Filter* toFind)
{
	for(std::list<Filter*>::iterator it = _filters.begin()
		; it != _filters.end(); ++it)
	{
		
	}
	//for (int i = 0; i < _filters.size(); ++i)
	for(std::list<Container*>::iterator it = _containers.begin()
		; it != _containers.end(); ++it)
	{
		
	}
	
	return -1; //if not found
}


bool SimplePipeline::add(Node* toAdd)
{
	ScopedBlockMacro(s1, "kiwi::core::SimplePipeline::add()");
	if(!contains(toAdd))
	{
		if(toAdd->nodeType() == Node::FILTER)
		{
			_filters.push_back(static_cast<Filter*>(toAdd));
			return true;
		}
		else
		{
			_containers.push_back( static_cast<Container*>(toAdd) );
			return true;
		}
	}
	return false;
}

unsigned int SimplePipeline::index(unsigned int x, unsigned int y)
{
	return x + y * _filters.size();
}

void SimplePipeline::update()
{
	

}
	
	

	
void SimplePipeline::process()
{
	ScopedBlockMacro(s1, "kiwi::core::SimplePipeline::process()");


}





}//namespace core
}//namespace kiwi

