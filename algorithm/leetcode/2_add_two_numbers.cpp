/*
 *
 * http://leetcode.com/onlinejudge#question_2
 *
 * Add Two NumbersNov 1 '114923 / 15944
 *
 * You are given two linked lists representing two non-negative numbers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.
 *
 * Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
 * Output: 7 -> 0 -> 8
 *
 */

#include <iostream>

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(NULL) {}
};

using namespace std;
class Solution {
    public:
        ListNode *addTwoNumbers(ListNode *l1, ListNode *l2) {
            int carry = 0;
            ListNode *cur_digit = NULL;
            ListNode *result = NULL;
            ListNode *new_digit = cur_digit;
            while(NULL != l1 || NULL != l2 || 0 != carry) {
                new_digit = new ListNode(0);
                if(NULL == cur_digit) {
                    cur_digit = new_digit;
                    result = cur_digit;
                }
                else {
                    cur_digit->next = new_digit;
                    cur_digit = new_digit;
                }
                int v1 = NULL == l1 ? 0 : l1->val;
                int v2 = NULL == l2 ? 0 : l2->val;
                cur_digit->val = carry + v1 + v2;
                carry = 0;
                if(cur_digit->val > 9) {
                    cur_digit->val %= 10;
                    carry = 1;
                }
                l1 = NULL == l1 ? l1 : l1->next;
                l2 = NULL == l2 ? l2 : l2->next;
            }
            return result;
        }
};

void print_list(ListNode* l) {
    while(NULL != l) {
        cout << l->val << ' ';
        l = l->next;
    }
    cout << endl;
}
int main(int argc, const char *argv[]) {
    ListNode *l1 = new ListNode(5);
    //ListNode *c1 = l1, *t1;
    //t1 = new ListNode(4);
    //c1->next = t1;
    //c1 = t1;
    //t1 = new ListNode(3);
    //c1->next = t1;
    //c1 = t1;

    ListNode *l2 = new ListNode(5);
    //ListNode *c2 = l2, *t2;
    //t2 = new ListNode(1);
    //c2->next = t2;
    //c2 = t2;
    //t2 = new ListNode(4);
    //c2->next = t2;
    //c1 = t2;
    print_list(l1);
    print_list(l2);

    Solution s;

    ListNode *result = s.addTwoNumbers(l1, l2);
    print_list(result);
    return 0;
}
