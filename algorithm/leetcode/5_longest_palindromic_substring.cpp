/*
 * http://leetcode.com/onlinejudge#question_5
 *
 * Longest Palindromic SubstringNov 11 '114008 / 13367
 *
 * Given a string S, find the longest palindromic substring in S. You may assume that the maximum length of S is 1000, and there exists one unique longest palindromic substring.
 *
 */

#include <iostream>
#include <string>

using namespace std;
class Solution {
    public:
        enum { MAXLEN = 1000 };
        Solution() {
            for(int i = 0; i < MAXLEN; ++i)
                for(int j = 0; j < MAXLEN; ++j)
                matrix[i][j] = -1;
        }

        string longestPalindrome(string s) {
            // initialization
            for(int i = 0; i < s.length(); ++i) {
                matrix[i][i] = true;
                matrix[0][i] = isPalindromicString(s, 0, i);
            }

            for(int i = 1; i < s.length()-1; ++i) {
                for(int j = i+1; j < s.length(); ++j) {
                    if(matrix[i][j] != -1)
                        continue;
                    isPalindromicString_dp(s, i, j);
                }
            }

            // find longest string
            for(int len = s.length(); len > 0; --len) {
                for(int i = 0, j = len - i - 1; i <= s.length()-len; ++i, ++j) {
                    if(matrix[i][j]) {
                        return s.substr(i, j-i+1);
                    }
                }
            }
            return s;
        }


    private:

        // the matrix is used for recording if str[i~j] is palindromic
        int matrix[MAXLEN][MAXLEN];

        void isPalindromicString_dp(string s, int i, int j) {
            if((i+1<=j-1) && matrix[i+1][j-1] == -1)
                isPalindromicString_dp(s, i+1, j-1);
            if((i+1>j-1 || matrix[i+1][j-1]) && s[i] == s[j])
                matrix[i][j] = 1;
            else
                matrix[i][j] = 0;
        }

        int isPalindromicString(string s, int start, int end) {
            while(end > start) {
                if(s[end] != s[start]) 
                    return 0;

                --end;
                ++start;
            }
            return 1;
        }

};

int main(int argc, const char *argv[]) {
    Solution slu;
    string s("banana");
    cout << slu.longestPalindrome(s) << endl;
    //cout << s << endl;
    return 0;
}
