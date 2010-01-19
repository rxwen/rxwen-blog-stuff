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
            if(a[j] > m[j-1])
            {
                s[j] = s[j-1] + 1;
                m[j] = a[j];
            }
            else
            {
                s[j] = s[j-1];
                if(a[j] > m[j-1])
                    m[j] = m[j-1];
                else
                {
                    // find out the smallest value for M[j]
                    int min = m[j-1];
                    int i;
                    for(i = j - 1; i >= 0; --i)
                    {
                        if(s[j] > s[i])
                        {
                            if(a[j] > m[i])
                                min = a[j];
                            break;
                        }
                    }
                    if(i < 0 && a[j] < m[0])
                        min = a[j];
                    m[j] = min;
                }
            }
        }
        cout << j << endl;
    cout << "S:\t";
    for(int k = 0; k < ARRAYSIZE; ++k)
        cout << s[k] << ' ';
    cout << endl;
    cout << "M:\t";
    for(int k = 0; k < ARRAYSIZE; ++k)
        cout << m[k] << ' ';
    cout << endl;
 
    }
}

int main ( int argc, char *argv[] )
{
    vector<int> a;
    ARRAYSIZE = 5;
    if(argc > 1)
        ARRAYSIZE = atoi(argv[1]);
//    a.push_back(70);
//    a.push_back(62);
//    a.push_back(27);
//    a.push_back(57);
//    a.push_back(47);
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
