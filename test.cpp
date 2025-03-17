#include <bits/stdc++.h>
using namespace std;
// #define int long long

void diffeqsolver(int x, int u, int dx, int a) {
    int y = 0, y1 = 0, u1 = 0, x1 = 0;
    
    // Print initial values for debugging
    cout << "Initial: x=" << x << ", u=" << u << ", dx=" << dx << ", a=" << a << endl;
    
    while (x < a) {
        u1 = u - (3 * x * u * dx) - (3 * y * dx);
        y1 = y + (u * dx);
        x1 = x + dx;
        
        // Print intermediate values for debugging
        cout << "Step: x=" << x1 << ", y=" << y1 << ", u=" << u1 << endl;
        
        // Check for overflow
        if (abs(u1) > 1e15 || abs(y1) > 1e15 || abs(x1) > 1e15) {
            cout << "Warning: Potential overflow detected, terminating early" << endl;
            break;
        }
        
        x = x1, y = y1, u = u1;
    }
    cout << "Step: x=" << x1 << ", y=" << y1 << ", u=" << u1 << endl;
}

void compute() {

    diffeqsolver(3,9,1,7);
}

signed main() {
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);
    int t = 1;
    while (t--) compute();
    return 0;
}