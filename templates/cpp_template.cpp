#include <bits/stdc++.h>
using namespace std;

using ll = long long;
using u32 = uint32_t;
using u64 = uint64_t;

#define rep0(i, n) for (int i = 0; i < (int)(n); ++i)
#define rep(i, a, b) for (int i = (int)(a); i < (int)(b); i++)
#define rrep(i, a, b) for (int i = (int)(a); i > (int)(b); --i)
#define srep(i, a, b, step) \
    for (long long i = (a); (step) > 0 ? i < (b) : i > (b); i += (step))

#define all(v) (v).begin(), (v).end()
#define MIN(v) *min_element(all(v))
#define MAX(v) *max_element(all(v))

const int INF = (1 << 30);
const ll INFLL = (1LL << 62);
const ll MOD = 998244353;
const ll MOD2 = 1000000007;

namespace fastio
{
    // 入力
    template <class T>
    void read(T &x) { cin >> x; }

    template <class A, class B>
    void read(pair<A, B> &p)
    {
        read(p.first);
        read(p.second);
    }

    template <size_t I = 0, class... Ts>
    inline enable_if_t<I == sizeof...(Ts)> read_tuple(tuple<Ts...> &) {}
    template <size_t I = 0, class... Ts>
        inline enable_if_t < I<sizeof...(Ts)> read_tuple(tuple<Ts...> &t)
    {
        read(get<I>(t));
        read_tuple<I + 1>(t);
    }
    template <class... Ts>
    void read(tuple<Ts...> &t) { read_tuple(t); }

    template <class T, size_t N>
    void read(array<T, N> &a)
    {
        for (auto &x : a)
            read(x);
    }
    template <class T>
    void read(vector<T> &v)
    {
        for (auto &x : v)
            read(x);
    }
    template <class T>
    void read(deque<T> &v)
    {
        for (auto &x : v)
            read(x);
    }

    template <class Head, class... Tail>
    void read(Head &head, Tail &...tail)
    {
        read(head);
        if constexpr (sizeof...(Tail))
            read(tail...);
    }

    // 基本型
    template <class T>
    void wt(const T &x) { cout << x; }

    // 小数は十分な桁数で出力
    inline void wt(float x) { cout << setprecision(15) << x; }
    inline void wt(double x) { cout << setprecision(15) << x; }
    inline void wt(long double x) { cout << setprecision(20) << x; }

    // 文字列系
    inline void wt(const char *s) { cout << s; }
    inline void wt(const string &s) { cout << s; }

    // pair
    template <class A, class B>
    void wt(const pair<A, B> &p)
    {
        wt(p.first);
        cout << ' ';
        wt(p.second);
    }

    // tuple
    template <size_t I = 0, class... Ts>
    inline enable_if_t<I == sizeof...(Ts)> wt_tuple(const tuple<Ts...> &) {}
    template <size_t I = 0, class... Ts>
        inline enable_if_t < I<sizeof...(Ts)> wt_tuple(const tuple<Ts...> &t)
    {
        if (I)
            cout << ' ';
        wt(get<I>(t));
        wt_tuple<I + 1>(t);
    }
    template <class... Ts>
    void wt(const tuple<Ts...> &t) { wt_tuple(t); }

    // forward declarations (two-phase lookup for container elements)
    template <class T>
    void wt(const set<T> &s);
    template <class T>
    void wt(const multiset<T> &s);
    template <class T>
    void wt(const unordered_set<T> &s);
    template <class K, class V>
    void wt(const map<K, V> &m);
    template <class K, class V>
    void wt(const unordered_map<K, V> &m);

    // array / vector / deque
    template <class T, size_t N>
    void wt(const array<T, N> &a)
    {
        for (size_t i = 0; i < N; i++)
        {
            if (i)
                cout << ' ';
            wt(a[i]);
        }
    }
    template <class T>
    void wt(const vector<T> &v)
    {
        for (size_t i = 0; i < v.size(); i++)
        {
            if (i)
                cout << ' ';
            wt(v[i]);
        }
    }
    template <class T>
    void wt(const vector<vector<T>> &v)
    {
        for (size_t i = 0; i < v.size(); i++)
        {
            if (i)
                cout << '\n';
            wt(v[i]);
        }
    }
    template <class T>
    void wt(const deque<T> &v)
    {
        for (size_t i = 0; i < v.size(); i++)
        {
            if (i)
                cout << ' ';
            wt(v[i]);
        }
    }

    // set / multiset / unordered_set
    template <class T>
    void wt(const set<T> &s)
    {
        bool first = true;
        for (auto &x : s)
        {
            if (!first)
                cout << ' ';
            first = false;
            wt(x);
        }
    }
    template <class T>
    void wt(const multiset<T> &s)
    {
        bool first = true;
        for (auto &x : s)
        {
            if (!first)
                cout << ' ';
            first = false;
            wt(x);
        }
    }
    template <class T>
    void wt(const unordered_set<T> &s)
    {
        bool first = true;
        for (auto &x : s)
        {
            if (!first)
                cout << ' ';
            first = false;
            wt(x);
        }
    }

    // map / unordered_map
    template <class K, class V>
    void wt(const map<K, V> &m)
    {
        bool first = true;
        for (auto &kv : m)
        {
            if (!first)
                cout << " | ";
            first = false;
            wt(kv.first);
            cout << ':';
            wt(kv.second);
        }
    }
    template <class K, class V>
    void wt(const unordered_map<K, V> &m)
    {
        bool first = true;
        for (auto &kv : m)
        {
            if (!first)
                cout << " | ";
            first = false;
            wt(kv.first);
            cout << ':';
            wt(kv.second);
        }
    }

    // 出力本体
    void print() { cout << '\n'; }

    template <class Head, class... Tail>
    void print(const Head &head, const Tail &...tail)
    {
        wt(head);
        if (sizeof...(Tail))
            cout << ' ';
        print(tail...);
    }
} // namespace fastio

// debug output (enabled only when LOCAL is defined)
namespace debugio
{
    // 基本型
    template <class T>
    void dwt(const T &x) { cerr << x; }

    inline void dwt(float x) { cerr << setprecision(15) << x; }
    inline void dwt(double x) { cerr << setprecision(15) << x; }
    inline void dwt(long double x) { cerr << setprecision(20) << x; }

    inline void dwt(const char *s) { cerr << s; }
    inline void dwt(const string &s) { cerr << s; }

    template <class A, class B>
    void dwt(const pair<A, B> &p)
    {
        cerr << '(';
        dwt(p.first);
        cerr << ',';
        dwt(p.second);
        cerr << ')';
    }

    template <size_t I = 0, class... Ts>
    inline enable_if_t<I == sizeof...(Ts)> dwt_tuple(const tuple<Ts...> &) {}
    template <size_t I = 0, class... Ts>
        inline enable_if_t < I<sizeof...(Ts)> dwt_tuple(const tuple<Ts...> &t)
    {
        if (I)
            cerr << ',';
        dwt(get<I>(t));
        dwt_tuple<I + 1>(t);
    }
    template <class... Ts>
    void dwt(const tuple<Ts...> &t)
    {
        cerr << '(';
        dwt_tuple(t);
        cerr << ')';
    }

    // forward declarations (two-phase lookup for container elements)
    template <class T>
    void dwt(const set<T> &s);
    template <class T>
    void dwt(const multiset<T> &s);
    template <class T>
    void dwt(const unordered_set<T> &s);
    template <class K, class V>
    void dwt(const map<K, V> &m);
    template <class K, class V>
    void dwt(const unordered_map<K, V> &m);

    // array / vector / deque
    template <class T, size_t N>
    void dwt(const array<T, N> &a)
    {
        cerr << '[';
        for (size_t i = 0; i < N; i++)
        {
            if (i)
                cerr << ',';
            dwt(a[i]);
        }
        cerr << ']';
    }
    template <class T>
    void dwt(const vector<T> &v)
    {
        cerr << '[';
        for (size_t i = 0; i < v.size(); i++)
        {
            if (i)
                cerr << ',';
            dwt(v[i]);
        }
        cerr << ']';
    }
    template <class T>
    void dwt(const deque<T> &v)
    {
        cerr << '[';
        for (size_t i = 0; i < v.size(); i++)
        {
            if (i)
                cerr << ',';
            dwt(v[i]);
        }
        cerr << ']';
    }

    // set / multiset / unordered_set
    template <class T>
    void dwt(const set<T> &s)
    {
        cerr << '{';
        bool first = true;
        for (const auto &x : s)
        {
            if (!first)
                cerr << ',';
            first = false;
            dwt(x);
        }
        cerr << '}';
    }
    template <class T>
    void dwt(const multiset<T> &s)
    {
        cerr << '{';
        bool first = true;
        for (const auto &x : s)
        {
            if (!first)
                cerr << ',';
            first = false;
            dwt(x);
        }
        cerr << '}';
    }
    template <class T>
    void dwt(const unordered_set<T> &s)
    {
        cerr << '{';
        bool first = true;
        for (const auto &x : s)
        {
            if (!first)
                cerr << ',';
            first = false;
            dwt(x);
        }
        cerr << '}';
    }

    // map / unordered_map
    template <class K, class V>
    void dwt(const map<K, V> &m)
    {
        cerr << '{';
        bool first = true;
        for (const auto &kv : m)
        {
            if (!first)
                cerr << ',';
            first = false;
            dwt(kv.first);
            cerr << ':';
            dwt(kv.second);
        }
        cerr << '}';
    }
    template <class K, class V>
    void dwt(const unordered_map<K, V> &m)
    {
        cerr << '{';
        bool first = true;
        for (const auto &kv : m)
        {
            if (!first)
                cerr << ',';
            first = false;
            dwt(kv.first);
            cerr << ':';
            dwt(kv.second);
        }
        cerr << '}';
    }

    // 出力本体
    void printd() { cerr << '\n'; }

    template <class Head, class... Tail>
    void printd(const Head &head, const Tail &...tail)
    {
        dwt(head);
        if (sizeof...(Tail))
            cerr << ' ';
        printd(tail...);
    }
} // namespace debugio

using fastio::print;
using fastio::read;

#ifdef LOCAL
using debugio::printd;
#else
template <class... Args>
void printd(const Args &...) {}
#endif

#define INT(...)   \
    int __VA_ARGS__; \
    read(__VA_ARGS__)
#define LL(...)   \
    ll __VA_ARGS__; \
    read(__VA_ARGS__)
#define U32(...)   \
    u32 __VA_ARGS__; \
    read(__VA_ARGS__)
#define U64(...)   \
    u64 __VA_ARGS__; \
    read(__VA_ARGS__)
#define STR(...)      \
    string __VA_ARGS__; \
    read(__VA_ARGS__)
#define CHAR(...)   \
    char __VA_ARGS__; \
    read(__VA_ARGS__)
#define DBL(...)      \
    double __VA_ARGS__; \
    read(__VA_ARGS__)
#define VEC(type, name, size) \
    vector<type> name(size);    \
    read(name)
#define VV(type, name, h, w)                     \
    vector<vector<type>> name(h, vector<type>(w)); \
    read(name)
#define VEC0(type, name, size) \
    vector<type> name(size)
#define VV0(type, name, h, w)                     \
    vector<vector<type>> name(h, vector<type>(w))

template <class T>
int bisect_left(const vector<T> &v, const T &x)
{
    return int(lower_bound(v.begin(), v.end(), x) - v.begin());
}

template <class T>
int bisect_right(const vector<T> &v, const T &x)
{
    return int(upper_bound(v.begin(), v.end(), x) - v.begin());
}

long long ipow(long long a, long long e)
{
    long long r = 1;
    while (e > 0)
    {
        if (e & 1)
            r *= a;
        a *= a;
        e >>= 1;
    }
    return r;
}

template <class It>
string join(It first, It last, const string &sep)
{
    ostringstream oss;
    bool first_elem = true;
    for (auto it = first; it != last; ++it)
    {
        if (!first_elem)
            oss << sep;
        first_elem = false;
        oss << *it;
    }
    return oss.str();
}

inline string join(const vector<string> &v, const string &sep)
{
    size_t total = 0;
    if (!v.empty())
        total = (v.size() - 1) * sep.size();
    for (const auto &s : v)
        total += s.size();
    string res;
    res.reserve(total);
    for (size_t i = 0; i < v.size(); ++i)
    {
        if (i)
            res += sep;
        res += v[i];
    }
    return res;
}

inline string join(const string &s, const string &sep)
{
    if (s.empty())
        return "";
    string res;
    if (!sep.empty())
        res.reserve(s.size() + (s.size() - 1) * sep.size());
    for (size_t i = 0; i < s.size(); ++i)
    {
        if (i)
            res += sep;
        res += s[i];
    }
    return res;
}

template <class C>
string join(const C &c, const string &sep)
{
    return join(c.begin(), c.end(), sep);
}

template <class C>
C reversed(C c)
{
    reverse(c.begin(), c.end());
    return c;
}

template <class T>
long long sum(const vector<T> &v)
{
    return accumulate(v.begin(), v.end(), 0LL);
}

struct Graph
{
    int n;
    vector<vector<int>> g;

    Graph(int n = 0) : n(n), g(n) {}

    void add_edge(int u, int v, bool undirected = true)
    {
        g[u].push_back(v);
        if (undirected)
            g[v].push_back(u);
    }

    vector<int> &operator[](int i) { return g[i]; }
    const vector<int> &operator[](int i) const { return g[i]; }
};

int main()
{
    // ここにコードを書く
}
