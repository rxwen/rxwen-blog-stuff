// =====================================================================================
// 
//       Filename:  ex15_4_5.cpp
// 
//    Description:  
// 
//        Version:  1.0
//        Created:  1/19/2010 ARRAYSIZE:09:24 PM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================

#include	<iostream>
#include	<vector>
#include	<time.h>
#include	<cstdlib>

using namespace std;
vector<int> s;
static int ARRAYSIZE;

int random()
{
    static int initialized = false;
    if(!initialized)
    {
        srand(static_cast<unsigned int>(time(NULL)));
        initialized = true;
    }

    return rand()%100;
}		// ----------  end of function random ----------

void LMIS(const vector<int> &a)
{
    int size = static_cast<int>(a.size());
    for(int i = 0; i < size; ++i)
    {
        s[i] = 1;
        for(int j = 0; j < i; ++j)
        {
            if(s[i] <= s[j] && a[i] > a[j])
                s[i] = s[j] + 1;
        }
    }
}

int main ( int argc, char *argv[] )
{
    vector<int> a;
    ARRAYSIZE = 5;
    if(argc > 1)
        ARRAYSIZE = atoi(argv[1]);
    for(int k = 0; k < ARRAYSIZE; ++k)
    {
        a.push_back(random());
        cout << a[k] << ' ';
        s.push_back(0);
    }
    cout << endl;
    LMIS(a);
    cout << "S:\t";
    for(int i = 0; i < ARRAYSIZE; ++i)
        cout << s[i] << ' ';
    cout << endl;
    return 0;
}				// ----------  end of function main  ----------
