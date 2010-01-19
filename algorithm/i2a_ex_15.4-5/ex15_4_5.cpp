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
vector<int> m;
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
    int j = 0;
    for(; j < ARRAYSIZE; ++j)
    {
        if(j == 0)
        {
            s[j] = 1;
            m[j] = a[j];
        }
        else
        {
            for(int i = 0; i <= j - 1; ++i)
            {
                if(a[j] > m[i])
                {
                    s[j] = s[i] + 1;
                    m[j] = a[j];
                }
                else
                {
                    if(s[j] < s[i])
                    {
                        s[j] = s[i];
                        m[j] = m[i] < a[j] ? m[i] : a[j];
                    }
                }
           }
        }
    }
}

int main ( int argc, char *argv[] )
{
    vector<int> a;
    ARRAYSIZE = 3;
    if(argc > 1)
        ARRAYSIZE = atoi(argv[1]);
    for(int k = 0; k < ARRAYSIZE; ++k)
    {
        a.push_back(random());
        cout << a[k] << ' ';
        m.push_back(0);
        s.push_back(0);
    }
    cout << endl;
    LMIS(a);
    cout << "S:\t";
    for(int i = 0; i < ARRAYSIZE; ++i)
        cout << s[i] << ' ';
    cout << endl;
    cout << "M:\t";
    for(int i = 0; i < ARRAYSIZE; ++i)
        cout << m[i] << ' ';
    cout << endl;
    return 0;
}				// ----------  end of function main  ----------
