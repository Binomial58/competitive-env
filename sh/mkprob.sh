#!/bin/bash

# 使い方チェック
if [ $# -lt 2 ]; then
    echo "usage: mkprob <cpp|py> <problem_name>"
    echo "example: mkprob cpp abc365_a"
    exit 1
fi

LANG="$1"
FULL="$2"

# フォルダ名・ファイル名は問題名そのまま
PROB="$FULL"


# 既存チェック
if [ -e "$PROB" ]; then
    echo "error: $PROB already exists."
    exit 1
fi

# ディレクトリ作成
mkdir "$PROB"

case "$LANG" in
    cpp)
        touch "$PROB/$PROB.cpp"
        touch "$PROB/in.txt"
        touch "$PROB/out.txt"

        cat << 'EOF' > "$PROB/$PROB.cpp"
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

using fastio::print;
using fastio::read;

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

int main()
{
    // ここにコードを書く
}

EOF
        echo "created C++ problem: $PROB (from $FULL)"
        ;;
    py)
        touch "$PROB/$PROB.py"
        echo "created Python problem: $PROB (from $FULL)"
        ;;
    *)
        echo "error: language must be 'cpp' or 'py'"
        exit 1
        ;;
esac
