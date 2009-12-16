// =====================================================================================
// 
//       Filename:  9_3_8.cpp
// 
//    Description:  solution to exercise 9.3-8 of Introduction to algorithms
// 
//        Version:  1.0
//        Created:  12/16/2009 7:44:56 PM
//       Revision:  none
//       Compiler:  cl.exe
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================

#include	<time.h>
#include	<cstdlib>
#include	<vector>
#include	<iostream>

typedef std::vector<int> int_vector;

int random()
{
    static int initialized = false;
    if(!initialized)
    {
        srand(static_cast<unsigned int>(time(NULL)));
        initialized = true;
    }

    return rand();
}		// ----------  end of function random ----------

void printVec (const int_vector& vec)
{
   for each(int i in vec)
       std::cout << i << " ";
   std::cout << std::endl;
}		// -----  end of function printVec  -----

int getMedian(const int_vector& x, int lx, int hx, const int_vector& y, int ly, int hy)
{
    int cx, cy, mx, my, z = 0;
    cx = (lx+hx)/2;
    cy = hy-(cx-lx);
    mx = x[cx];
    my = y[cy];
    if(mx <= my)
    {
        if(cy < 1 || mx >= y[cy-1])
            return mx;
        else
            return getMedian(x, cx+1, hx, y, ly, cy-1);
    }
    else
    {
        if(cx < 1 || my >= x[cx-1])
            return my;
        else
            return getMedian(x, lx, cx-1, y, cy+1, hy);
    }
}

int main ( int argc, char *argv[] )
{
    int n = 8;
    const int limit = 100;
    if(argc > 1)
        n = atoi(argv[1]);
    int_vector x,y;
    int xbase = 0, ybase = 0;
    for(int i = 0; i < n; ++i)
    {
        xbase += random() % limit;
        ybase += random() % limit;
        x.push_back(xbase);
        y.push_back(ybase);
    }
    printVec(x);
    printVec(y);

    int z = getMedian(x, 0, x.size()-1, y, 0, y.size()-1);
    std::cout << z << std::endl;
    return 0;
}	    // ----------  end of function main  ----------

