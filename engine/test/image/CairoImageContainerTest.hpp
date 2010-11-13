#ifndef KIWI_CAIRO_IMAGECONTAINER_TEST
#define KIWI_CAIRO_IMAGECONTAINER_TEST


#include "cairo/ImageContainer/ImageContainer.hpp"

#include "generic/ArrayContainerTest.hpp"

#include "core/Commons.hpp"

#include "core/Filter.hpp"

#include "generic/ArrayContainerTest.hpp"


int CairoImageContainerTest()
{
ScopedBlockMacro(__scp, "kiwi::cairo::ImageContainer Test" );

	typedef kiwi::generic::Point<kiwi::uint32_t,2> Point2u;
	typedef kiwi::generic::ArrayWriter<kiwi::uint8_t, 2> myWriter;
	
	kiwi::image::cairo::RGBAImageContainer img1( Point2u(800,600) );
	assert( img1.width() == img1.spanSize()[0] );
	assert( img1.width() == 800 );

	assert( img1.height() == img1.spanSize()[1] );
	assert( img1.height() == 600 );

	Debug::print() << "increment(0): " << img1.increments(0)[0]; 
	
	kiwi::image::cairo::RGBAImageContainer img2( Point2u(800,600) );
	
	
	myWriter img1Writer0( img1, 0 );
	ArrayIterator<kiwi::uint8_t> it = img1Writer0.getIterator();
	do { *it = 0; } while ( it.onIteration() );
	
	myWriter img1Writer1( img1, 1 );
	it = img1Writer1.getIterator();
	do { *it = 255; } while ( it.onIteration() );
	
	myWriter img1Writer2( img1, 2 );
	it = img1Writer2.getIterator();
	do { *it = 0; } while ( it.onIteration() );
	
	myWriter img1Writer3( img1, 3 );
	it = img1Writer3.getIterator();
	do { *it = 255; } while ( it.onIteration() );
	
	
	img1.saveToPng("testCairoContainer.png");
	
	
	
	return 0;
}




#endif
