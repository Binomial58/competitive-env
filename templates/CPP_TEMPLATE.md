# C++ テンプレート仕様（`templates/cpp_template.cpp`）

`sh/mkprob.sh` で `cpp` を指定したときにコピーされるテンプレートの、**現在の実装内容**をまとめたドキュメントです。

---

## 1. 基本構成

### ヘッダ・名前空間

```cpp
#include <bits/stdc++.h>
using namespace std;
```

### 型エイリアス

```cpp
using ll = long long;
using u32 = uint32_t;
using u64 = uint64_t;
```

### ループ/汎用マクロ

```cpp
#define rep0(i, n) for (int i = 0; i < (int)(n); ++i)
#define rep(i, a, b) for (int i = (int)(a); i < (int)(b); i++)
#define rrep(i, a, b) for (int i = (int)(a); i > (int)(b); --i)
#define srep(i, a, b, step) \
    for (long long i = (a); (step) > 0 ? i < (b) : i > (b); i += (step))

#define all(v) (v).begin(), (v).end()
#define MIN(v) *min_element(all(v))
#define MAX(v) *max_element(all(v))
```

### 定数

```cpp
const int INF = (1 << 30);
const ll INFLL = (1LL << 62);
const ll MOD = 998244353;
const ll MOD2 = 1000000007;
```

---

## 2. 入出力ユーティリティ（`fastio`）

### 入力: `read(...)`

`cin` ベースの入力関数です。可変引数でまとめて読めます。

対応型:
- 基本型（`int`, `ll`, `double`, `string` など）
- `pair`
- `tuple`
- `array`
- `vector`
- `deque`

例:

```cpp
int n;
ll x;
string s;
read(n, x, s);

vector<int> a(n);
read(a);
```

### 出力: `print(...)`

`print(a, b, c)` は空白区切りで出力し、最後に改行します。

内部 `wt(...)` が対応している型:
- 基本型
- `string`, `const char*`
- `pair`, `tuple`
- `array`, `vector`, `vector<vector<T>>`, `deque`
- `priority_queue`
- `set`, `multiset`, `unordered_set`
- `map`, `unordered_map`

`priority_queue` はコピーを作って `top()/pop()` で出力するため、元のキューは変更されません（優先度順に表示）。

小数は常に小数点以下10桁で固定表示:
- `float`, `double`, `long double`: `fixed << setprecision(10)`

---

## 3. 宣言+入力マクロ

宣言してすぐ `read` するためのショートカットです。

```cpp
#define INT(...)  int __VA_ARGS__; read(__VA_ARGS__)
#define LL(...)   ll __VA_ARGS__; read(__VA_ARGS__)
#define U32(...)  u32 __VA_ARGS__; read(__VA_ARGS__)
#define U64(...)  u64 __VA_ARGS__; read(__VA_ARGS__)
#define STR(...)  string __VA_ARGS__; read(__VA_ARGS__)
#define CHAR(...) char __VA_ARGS__; read(__VA_ARGS__)
#define DBL(...)  double __VA_ARGS__; read(__VA_ARGS__)

#define VEC(type, name, size) \
    vector<type> name(size); \
    read(name)

#define VV(type, name, h, w) \
    vector<vector<type>> name(h, vector<type>(w)); \
    read(name)

#define VEC0(type, name, size) vector<type> name(size)
#define VV0(type, name, h, w) vector<vector<type>> name(h, vector<type>(w))
#define VECI(type, name, size, init) vector<type> name(size, init)
#define VVI(type, name, h, w, init) vector<vector<type>> name(h, vector<type>(w, init))
```

使用例:

```cpp
INT(n, m);
VEC(int, a, n);
VV0(ll, dist, n, n);
VECI(ll, dp, n, -1);          // 任意の初期値
VVI(ll, cost, n, n, (1LL << 60)); // 任意の初期値
```

---

## 4. `set` / `multiset` 補助（近傍取得・削除）

### `set` の Python 風集合演算

`std::set` 同士で以下の演算子が使えます（`multiset` は対象外）。

- `A | B`: 和集合
- `A & B`: 積集合
- `A - B`: 差集合
- `A ^ B`: 対称差
- `A |= B`, `A &= B`, `A -= B`, `A ^= B`: 破壊的更新

あわせて、判定関数も定義されています。

- `is_subset(a, b)`: `a ⊆ b`
- `is_superset(a, b)`: `a ⊇ b`
- `is_disjoint(a, b)`: `a` と `b` が互いに素

例:

```cpp
set<int> A = {1, 2, 3};
set<int> B = {3, 4, 5};

auto uni = A | B; // {1,2,3,4,5}
auto inter = A & B; // {3}
auto diff = A - B; // {1,2}
auto sym = A ^ B; // {1,2,4,5}

if (is_subset(inter, uni)) {
    print("ok");
}
```

### 近傍取得（iterator）

```cpp
GE_IT(c, x)
```
- `x` 以上の最小要素を指す iterator（`lower_bound`）
- 存在しなければ `c.end()`

```cpp
LE_IT(c, x)
```
- `x` 以下の最大要素を指す iterator
- 存在しなければ `c.end()`

例:

```cpp
auto it1 = GE_IT(st, x);
if (it1 != st.end()) {
    ll v = *it1;
}

auto it2 = LE_IT(st, x);
if (it2 != st.end()) {
    ll v = *it2;
}
```

### 近傍取得（値）

```cpp
GE_VAL(c, x)
LE_VAL(c, x)
```

- 戻り値は `typename C::value_type`（値を直接返す）
- 要素が存在しない場合は `std::out_of_range` を送出

例:

```cpp
ll a = GE_VAL(st, x); // x以上の最小要素
ll b = LE_VAL(st, x); // x以下の最大要素
```

存在しない可能性がある場合:

```cpp
try {
    ll a = GE_VAL(st, x);
    print(a);
} catch (const out_of_range &) {
    // 見つからないときの処理
}
```

### 削除

```cpp
DISCARD_ONE(c, x)
```
- `set`: `x` を削除（0 or 1 個）
- `multiset`: `x` を **1個だけ** 削除
- 戻り値: `bool`（削除成功なら `true`）

```cpp
DISCARD_ALL(c, x)
```
- `set`: `x` を削除（0 or 1 個）
- `multiset`: `x` を **全部** 削除
- 戻り値: `int`（削除した個数）

例:

```cpp
bool ok = DISCARD_ONE(ms, x); // multiset で1個だけ
int cnt = DISCARD_ALL(ms, x); // multiset で全部
```

---

## 5. 補助関数

### 二分探索（`vector`）

```cpp
template <class T>
int bisect_left(const vector<T> &v, const T &x);

template <class T>
int bisect_right(const vector<T> &v, const T &x);
```

- `bisect_left`: `x` 以上の最初の位置
- `bisect_right`: `x` より大きい最初の位置

### べき乗

```cpp
long long ipow(long long a, long long e);
```

- 単純な繰り返し二乗法
- オーバーフローは呼び出し側で注意

### `join` 系

```cpp
template <class It>
string join(It first, It last, const string &sep);

string join(const vector<string> &v, const string &sep);
string join(const string &s, const string &sep);

template <class C>
string join(const C &c, const string &sep);
```

用途:
- コンテナを区切り文字付き文字列にまとめる
- 文字列 `s` の各文字の間に `sep` を挟む

### 反転コピー

```cpp
template <class C>
C reversed(C c);
```

- 引数のコピーを反転して返す（元データは変更しない）

### 総和

```cpp
template <class T>
long long sum(const vector<T> &v);
```

- `accumulate(..., 0LL)` で合計を返す

---

## 6. Graph（無向・重みなし）

```cpp
struct Graph
{
    int n;
    vector<vector<int>> g;

    Graph(int n = 0);
    void add_edge(int u, int v, bool undirected = true);
    vector<int> &operator[](int i);
    const vector<int> &operator[](int i) const;
};
```

使用例:

```cpp
Graph G(n);
G.add_edge(u, v);        // 無向
G.add_edge(u, v, false); // 有向

for (int to : G[u]) {
    // ...
}
```

---

## 7. main 雛形

```cpp
int main()
{
    // ここにコードを書く
}
```

必要に応じて以下を先頭に追加:

```cpp
ios::sync_with_stdio(false);
cin.tie(nullptr);
```
