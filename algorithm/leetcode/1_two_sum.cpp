/*
 *
 * http://leetcode.com/onlinejudge#question_1
 *
 * Two SumMar 14 '116343 / 20069
 *
 * Given an array of integers, find two numbers such that they add up to a specific target number.
 *
 * The function twoSum should return indices of the two numbers such that they add up to the target, where index1 must be less than index2. Please note that your returned answers (both index1 and index2) are not zero-based.
 *
 * You may assume that each input would have exactly one solution.
 *
 * Input: numbers={2, 7, 11, 15}, target=9
 * Output: index1=1, index2=2
 * 
 */

#include <iostream>
#include <vector>

using namespace std;

class Solution {
    public:
        vector<int> twoSum(vector<int> &numbers, int target) {
            vector<int> result;
            for(int i = 0; i < numbers.size(); ++i) {
                for(int j = i+1; j < numbers.size(); ++j) {
                    if(numbers[i] + numbers[j] == target) {
                        result.push_back(i+1);
                        result.push_back(j+1);
                        break;
                    }
                }
            }
            return result;
        }
};

int main(int argc, const char *argv[]) {
    Solution s;
    int array[] = //{2, 7, 11, 15};
    {678,227,764,37,956,982,118,212,177,597,519,968,866,121,771,343,561};//, 295
    vector<int> v(array, array+sizeof(array)/sizeof(array[0]));
    vector<int> r = s.twoSum(v, 295);
    for(vector<int>::const_iterator iter = r.begin(); iter != r.end(); ++iter)
        cout << *iter;
    return 0;
}
