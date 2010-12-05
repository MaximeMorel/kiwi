#pragma once

#ifndef KIWI_UPPERCASEFILTER_HPP
#define KIWI_UPPERCASEFILTER_HPP

#include "kiwi/core/Commons.hpp"
#include "kiwi/core/CanonicalFilter.hpp"
#include "kiwi/text/TextReader.hpp"
#include "kiwi/text/TextWriter.hpp"
#include "kiwi/generic/Point.hpp"
#include "kiwi/utils/types.hpp"
#include "kiwi/text/TextContainer.hpp"
#include "kiwi/core/NodeFactory.hpp"





namespace kiwi
{
namespace text
{


class UpperCaseFilter : public core::CanonicalFilter
{
public:
	
	UpperCaseFilter() : CanonicalFilter(1)
	{
	//ScopedBlockMacro(scp_block, "UpperCaseFilter::constructor");
		// CanonicalFilter's constructor automatically adds one reader output port
		// and one writer input port.
		
		addReaderInputPort();
	}
	
	~UpperCaseFilter() 
	{
		
	}



	// Main entry point of the filter. This is the method to verride in order to 
	// make the filter do whatever it is supposed to do. 
	void process()
	{
		//ScopedBlockMacro(_cpm, "UpperCaseFilter::process")
		
		if( !writerInputPort(0).isConnected() )
		{
			addWriteNode(new TextContainer, 0);
		}
	
		TextReader input( readerInputPort(0) );
		TextWriter result( writerInputPort(0) );
		result.reset();
		while(input.currentLine() < input.nbLines() - 1)
		{
			input.gotoNextLine();
			result.insertLine("", -1);
			result.gotoNextLine();
			for(uint32_t i = 0; i < input.nbChars(); ++i )
			{
				result.setChar( i, std::toupper(input.getChar(i)) );
			}
		}
		
		
		
		return;
	}
	

	// This is optionnal. Override this method readyCondition() if this filter
	// needs to perform custom checks to tell if it's ready.
	bool readyCondition()
	{
		return (readerInputPort(0).isConnected() );
	}
	
	
	kiwi::string readerInputName( portIndex_t index )
	{
		return kiwi::string("in");	
	}
	kiwi::string writerInputName( portIndex_t index )
	{
		return kiwi::string("write");	
	}
	kiwi::string readerOutputName( portIndex_t index )
	{
		return kiwi::string("out");	
	}
	
	kiwi::string readerInputType( portIndex_t index )
	{
		return kiwi::string("#text");
	}
	// same idea with writer inputs
	kiwi::string writerInputType( portIndex_t index )
	{
		return kiwi::string("#text");
	}
	
	static Filter* newUpperCaseFilter() { return new UpperCaseFilter; }
	
	static void registerToFactory(kiwi::core::NodeFactory& factory, const kiwi::string& filterId)
	{
		factory.registerNode( filterId
				, kiwi::core::Descriptor<kiwi::core::Filter>(
					"UpperCaseFilter"
					, newUpperCaseFilter
					, "#Filter#text" )
			);
	}
	
};

kiwi::core::Filter* __newUpperCaseFilter(){return new UpperCaseFilter; }

}// namespace
}// namespace

#endif
