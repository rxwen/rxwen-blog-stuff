/*
 *
 * http://leetcode.com/onlinejudge#question_4
 *
 * Median of Two Sorted ArraysMar 28 '112995 / 15696
 *
 * There are two sorted arrays A and B of size m and n respectively. Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).
 *
 */

#include <iostream>

using namespace std;

class Solution {
    private:
        int findKthElement(int A[], int m, int B[], int n, int k) {
            int i = 0, j = 0, index = 0, result = 0;
            while(index++ < k) {
                cout << i << ' ' << j << ' ' << k << ' ' << index << endl;
                if(j >= n || (i < m && A[i] <= B[j])) {
                    result = A[i++]; 
                    continue;
                }
                if(i >= m || (j < n && A[i] > B[j])) {
                    result = B[j++];
                    continue;
                }
            }
            return result;
        }

    public:
        double findMedianSortedArrays(int A[], int m, int B[], int n) {
            double ans = findKthElement(A, m, B, n, (m+n+1)/2);
            if((m+n)%2 == 0)
                ans = (ans+findKthElement(A, m, B, n, (m+n+2)/2))/2;
            return ans;
        }
};

int main(int argc, const char *argv[]) {
    int A[] = {};
    int B[] = {1, 4, 5, 6, 7};
    Solution s;
    cout << s.findMedianSortedArrays(A, sizeof(A)/sizeof(A[0]), B, sizeof(B)/sizeof(B[0])) << endl;
    return 0;
}
