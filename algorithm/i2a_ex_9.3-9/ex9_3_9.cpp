// =====================================================================================
// 
//       Filename:  9_3_9.cpp
// 
//    Description:  solution to exercise 9.3-9 of Introduction to algorithms
// 
//        Version:  1.0
//        Created:  12/14/2009 8:32:45 PM
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

void printVec (const int_vector& vec);
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

void swap(int_vector& vec, int i, int j)
{
    int temp = vec[i];
    vec[i] = vec[j];
    vec[j] = temp;
}		// ----------  end of function swap ----------

int partition(int_vector& vec)
{
    if(vec.size() == 1)
        return 0;
    int i = 0, j = 1;
    int r = random() % vec.size();
    swap(vec, 0, r); 
    int pivot = vec[0];

    while(j < vec.size())
    {
        if(vec[j] <= pivot)
        {
            int temp = vec[j];
            vec[j] = vec[i+1];
            vec[i] = temp;
            ++i;
        }
        ++j;
    }
    vec[i] = pivot;

    return i;
}		// ----------  end of function partition ----------

void quickSort(int_vector& vec)
{
    if(vec.size() < 2)
        return;
    int p = partition(vec);
    int pivot = vec[p];
    int_vector low, high;
    high.insert(high.begin(), vec.begin()+p+1, vec.end());
    low.insert(low.begin(), vec.begin(), vec.begin()+p);
    vec.clear();
    quickSort(low);
    quickSort(high);
    vec.insert(vec.end(), low.begin(), low.end());
    vec.push_back(pivot);
    vec.insert(vec.end(), high.begin(), high.end());
}		// ----------  end of function quickSort----------

void printVec (const int_vector& vec)
{
   for each(int i in vec)
       std::cout << i << " ";
   std::cout << std::endl;
}		// -----  end of function printVec  -----

int main ( int argc, char *argv[] )
{
    int_vector vec;
    int size = 5;
    if(argc > 1)
        size = atoi(argv[1]);
    for(int i = 0; i < size; ++i)
        vec.push_back(random()%100);
    printVec(vec);
    quickSort(vec);
    printVec(vec);
    return 0;
}		// ----------  end of function main  ----------
