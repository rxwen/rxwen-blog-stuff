/*
 *
 * http://codeforces.com/problemset/problem/2/B
 *
 * B. The least round way
 * time limit per test5 seconds
 * memory limit per test64 megabytes
 * inputstandard input
 * outputstandard output
 * There is a square matrix n × n, consisting of non-negative integer numbers. You should find such a way on it that
 *
 * starts in the upper left cell of the matrix;
 * each following cell is to the right or down from the current cell;
 * the way ends in the bottom right cell.
 * Moreover, if we multiply together all the numbers along the way, the result should be the least "round". In other words, it should end in the least possible number of zeros.
 *
 * Input
 * The first line contains an integer number n (2 ≤ n ≤ 1000), n is the size of the matrix. Then follow n lines containing the matrix elements (non-negative integer numbers not exceeding 109).
 *
 * Output
 * In the first line print the least number of trailing zeros. In the second line print the correspondent way itself.
 *
 * Sample test(s)
 * input
 * 3
 * 1 2 3
 * 4 5 6
 * 7 8 9
 * output
 * 0
 * DDRR
 *
 *
 * Note: take care of the special case that there is 0 in the matrix.
 *
 */

#include <iostream>

using namespace std;
const int MAX_SIZE = 1024;

int gm[MAX_SIZE][MAX_SIZE], gm2[MAX_SIZE][MAX_SIZE], gm5[MAX_SIZE][MAX_SIZE];
char gd2[MAX_SIZE][MAX_SIZE], gd5[MAX_SIZE][MAX_SIZE];
int zero_flag, zero_row, zero_col;

template<typename T>
void print_matrix(T **m, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            cout << m[i][j] << ' ';
        }
        cout << endl;
    }
}

void get_number_of_factor(int **m, int **mo, int n, int p) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            int x = m[i][j];
            if(zero_flag == 0 && x == 0) {
                zero_flag = 1;
                zero_row = i;
                zero_col = j;
            }
            while(x!=0 && x%p==0) {
                ++mo[i][j];
                x/=p;
            }
        }
    }
}

void dp(int **m, char **d, int n) {
    d[0][0] = ' ';
    for (int i = 1; i < n; ++i) {
        m[0][i] += m[0][i-1];
        m[i][0] += m[i-1][0];
        d[0][i] = 'R';
        d[i][0] = 'D';
    }

    for (int i = 1; i < n; ++i) {
        for (int j = 1; j < n; ++j) {
            if(m[i-1][j] >= m[i][j-1]) {
                m[i][j] += m[i][j-1];
                d[i][j] = 'R';
            }
            else {
                m[i][j] += m[i-1][j];
                d[i][j] = 'D';
            }
        }
    }
}

void output_path(char** d, int n) {
    int path_len = 2*(n-1)+1;
    char *path = new char[path_len];
    path[path_len-1] = '\0';
    int i = n-1, j = n-1, k = path_len-2;
    while(k != -1) {
        path[k]=d[i][j];
        //cout << path_len << ' ' << i << ' ' << j << ' ' << k << ' ' << path[k] << endl;
        --k;
        if(d[i][j] == 'D')
            --i;
        else
            --j;
    }
    cout << path << endl;
    delete[] path;
}

int main(int argc, const char *argv[]) {
    int n = 0;
    int **m, **m2, **m5;
    char **d2, **d5;
    m = (int**)gm;
    m2 = (int**)gm2;
    m5 = (int**)gm5;
    d2 = (char**)gd2;
    d5 = (char**)gd5;
    cin >> n;
    m = new int*[n];
    m2 = new int*[n];
    m5 = new int*[n];
    d2 = new char*[n];
    d5 = new char*[n];
    for (int i = 0; i < n; ++i) {
        m[i] = new int[n];
        for (int j = 0; j < n; ++j) {
            cin >> m[i][j];
        }
        m2[i] = new int[n];
        m5[i] = new int[n];
        for (int j = 0; j < n; ++j) {
            m2[i][j] = 0;
            m5[i][j] = 0;
        }
        d2[i] = new char[n];
        d5[i] = new char[n];
    }

    get_number_of_factor(m, m2, n, 2);
    get_number_of_factor(m, m5, n, 5);

    dp(m2, d2, n);
    dp(m5, d5, n);

    int count2 = m2[n-1][n-1], count5 = m5[n-1][n-1];
    if(count2 < 1 || count5 < 1 || zero_flag == 0) {
        if(count2 > count5) {
            cout << count5 << endl;
            output_path(d5, n);
        }
        else {
            cout << count2 << endl;
            output_path(d2, n);
        }
    }
    else { // the path that contains 0 is the least one
        cout << 1 << endl;
        for(int i = 0; i < zero_row; ++i)
            cout << 'D';
        for(int i = 0; i < n-1; ++i)
            cout << 'R';
        for(int i = zero_row; i < n-1; ++i)
            cout << 'D';
        cout << endl;
    }

    return 0;
}
