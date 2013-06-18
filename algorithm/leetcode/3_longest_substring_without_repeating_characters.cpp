/*
 *
 * http://leetcode.com/onlinejudge#question_3
 *
 * Longest Substring Without Repeating Characters May 16 '114362 / 13161
 *
 * Given a string, find the length of the longest substring without repeating characters. For example, the longest substring without repeating letters for "abcabcbb" is "abc", which the length is 3. For "bbbbb" the longest substring is "b", with the length of 1.
 *
 */

#include <iostream>
#include <set>
#include <string>

using namespace std;
class Solution {
    public:
        int lengthOfLongestSubstring(string s) {
            set<char> appeared_chars;
            int count = 0;
            int max_count = 0;
            
            for(int i = 0; i < s.length(); ++i) {
                for(int j = i; j < s.length(); ++j) {
                    if(appeared_chars.end() == appeared_chars.find(s[j])) {
                        appeared_chars.insert(s[j]);
                        ++count;
                    }
                    else
                        break;
                }
                if(count > max_count)
                    max_count = count;
                appeared_chars.clear();
                count = 0;
            }

            return max_count;
        }
};

int main(int argc, const char *argv[]) {
    Solution slu;
    string s("abcdcefcg");
    cout << slu.lengthOfLongestSubstring(s) << endl;
    return 0;
}
