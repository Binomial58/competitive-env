# C++ テンプレート（mkprob 生成）

`sh/mkprob.sh` で `cpp` を指定したときに生成される C++ テンプレートの概要です。

## 生成されるファイル

- `<problem>/<problem>.cpp`
- `<problem>/in.txt`
- `<problem>/out.txt`

## テンプレート内容（概要）

### 1) Includes と using

```cpp
#include <bits/stdc++.h>
using namespace std;
```

### 2) 型エイリアス

```cpp
using ll = long long;
using u32 = uint32_t;
using u64 = uint64_t;
```

### 3) ループ系マクロ

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

### 4) 定数

```cpp
const int INF = (1 << 30);
const ll INFLL = (1LL << 62);
const ll MOD = 998244353;
const ll MOD2 = 1000000007;
```

用途の目安:
- `INF` / `INFLL`: 最短路や DP の初期値に使う「十分大きい値」
- `MOD` / `MOD2`: 剰余演算用（問題で指定された MOD を使う）

### 5) fastio 名前空間（入出力ユーティリティ）

#### 入力: `read`

`cin >>` をベースにした入力関数です。  
以下の型が利用できます（ネストも可）:

- 基本型 (`int`, `long long`, `double`, `string` など)
- `pair`
- `tuple`
- `array`
- `vector`
- `deque`

可変引数でまとめて入力可能:

```cpp
int a; string s; 
fastio::read(a, s);
```

#### 出力: `wt` / `print`

`print` は引数を空白区切りで出力し、最後に改行を出力します。

```cpp
fastio::print(a, b, c); // "a b c\n"
```

対応型（小数は自動で高精度出力）:

- 基本型
- `string` / `const char*`
- `pair`
- `tuple`
- `array`
- `vector`（`vector<vector<T>>` は行ごとに改行）
- `deque`
- `set` / `multiset` / `unordered_set`
- `map` / `unordered_map`

### 6) 入力ショートカットマクロ

宣言と `read` を一度に行うマクロです。

```cpp
#define INT(...)  int __VA_ARGS__; read(__VA_ARGS__)
#define LL(...)   ll __VA_ARGS__; read(__VA_ARGS__)
#define U32(...)  u32 __VA_ARGS__; read(__VA_ARGS__)
#define U64(...)  u64 __VA_ARGS__; read(__VA_ARGS__)
#define STR(...)  string __VA_ARGS__; read(__VA_ARGS__)
#define CHAR(...) char __VA_ARGS__; read(__VA_ARGS__)
#define DBL(...)  double __VA_ARGS__; read(__VA_ARGS__)
#define VEC(type, name, size) vector<type> name(size); read(name)
#define VV(type, name, h, w) vector<vector<type>> name(h, vector<type>(w)); read(name)
#define VEC0(type, name, size) vector<type> name(size)
#define VV0(type, name, h, w) vector<vector<type>> name(h, vector<type>(w))
```

注意:
- 複数文に展開されるため、`if` 直下で使う場合は必ず `{}` を付けるのが安全です。

### 7) 補助関数

```cpp
template <class T>
int bisect_left(const vector<T> &v, const T &x)

template <class T>
int bisect_right(const vector<T> &v, const T &x)

long long ipow(long long a, long long e)

template <class It>
string join(It first, It last, const string &sep)

string join(const vector<string> &v, const string &sep)

string join(const string &s, const string &sep)

template <class C>
string join(const C &c, const string &sep)

template <class C>
C reversed(C c)

template <class T>
long long sum(const vector<T> &v)
```

### 8) main の雛形

```cpp
int main()
{
    // ここにコードを書く
}
```

## 使い方例

```cpp
INT(n);
VEC(int, a, n);
LL(x, y);
STR(s);
print(n, x, s);
```

このテンプレートは基本的に `cin/cout` ベースなので、より高速な入出力が必要な場合は `ios::sync_with_stdio(false); cin.tie(nullptr);` を追加したり、別の高速 I/O に差し替える運用も可能です。
