#!/usr/bin/env python3
"""Competitive Companion 用のローカル受信サーバ。

ブラウザ拡張 Competitive Companion が問題ページで送信する JSON を
http://127.0.0.1:<port>/ (デフォルト 10043) で受け取り、
  <cwd>/<contest_id>/<task_id>/
        samples/sample-1.in, sample-1.out, ...
        tl.txt (timeLimit, ms)
を生成する。task_id ディレクトリが存在しなければ mkprob.sh で
言語テンプレも合わせて生成し、既に存在する場合は samples/tl.txt だけ
上書きする(作業中のソースは壊さない)。
"""

import argparse
import json
import os
import re
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ATCODER_URL_RE = re.compile(r"/contests/([^/]+)/tasks/([^/]+)")


def slugify(text):
    s = re.sub(r"[^A-Za-z0-9_-]+", "_", text.strip().lower())
    s = re.sub(r"_+", "_", s).strip("_")
    return s or "problem"


def resolve_ids(payload):
    url = payload.get("url", "") or ""
    m = ATCODER_URL_RE.search(url)
    if m:
        return m.group(1), m.group(2)
    contest_id = slugify(payload.get("group", "contest"))
    task_id = slugify(payload.get("name", "problem"))
    return contest_id, task_id


def handle_payload(payload, lang, root):
    contest_id, task_id = resolve_ids(payload)
    contest_dir = os.path.join(root, contest_id)
    prob_dir = os.path.join(contest_dir, task_id)

    os.makedirs(contest_dir, exist_ok=True)

    scaffolded = False
    if not os.path.isdir(prob_dir):
        mkprob = os.path.join(SCRIPT_DIR, "mkprob.sh")
        result = subprocess.run([mkprob, lang, task_id], cwd=contest_dir)
        if result.returncode == 0:
            scaffolded = True
        else:
            print(f"[companion] {task_id}: mkprob failed, samples のみ書き込みます", file=sys.stderr)
            os.makedirs(prob_dir, exist_ok=True)
    else:
        os.makedirs(prob_dir, exist_ok=True)

    tests = payload.get("tests", []) or []
    samples_dir = os.path.join(prob_dir, "samples")
    os.makedirs(samples_dir, exist_ok=True)
    for i, t in enumerate(tests, start=1):
        with open(os.path.join(samples_dir, f"sample-{i}.in"), "w") as f:
            f.write(t.get("input", ""))
        with open(os.path.join(samples_dir, f"sample-{i}.out"), "w") as f:
            f.write(t.get("output", ""))

    tl = payload.get("timeLimit")
    if tl:
        with open(os.path.join(prob_dir, "tl.txt"), "w") as f:
            f.write(f"{int(tl)}\n")

    tag = "new" if scaffolded else "update"
    tl_note = f", tl={int(tl)}ms" if tl else ""
    print(f"[companion:{tag}] {contest_id}/{task_id}: samples {len(tests)} 件{tl_note}")
    return contest_id, task_id, len(tests)


class Handler(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else b""

        try:
            payload = json.loads(body)
        except json.JSONDecodeError as e:
            print(f"[companion] invalid JSON: {e}", file=sys.stderr)
            self.send_response(400)
            self._cors()
            self.end_headers()
            return

        try:
            handle_payload(payload, self.server.lang, self.server.root)
        except Exception as e:
            print(f"[companion] error: {e}", file=sys.stderr)

        body_out = b'{"status":"ok"}'
        self.send_response(200)
        self._cors()
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body_out)))
        self.end_headers()
        self.wfile.write(body_out)

    def log_message(self, fmt, *args):
        pass


def main():
    # リダイレクト/パイプ時でもログ行がすぐ見えるように行バッファリングにする
    sys.stdout.reconfigure(line_buffering=True)
    sys.stderr.reconfigure(line_buffering=True)

    parser = argparse.ArgumentParser(description="Competitive Companion receiver")
    parser.add_argument("--port", type=int, default=10043)
    parser.add_argument("--lang", choices=["cpp", "py"], default="cpp")
    args = parser.parse_args()

    root = os.getcwd()
    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    server.lang = args.lang
    server.root = root

    print(f"[companion] listening on http://127.0.0.1:{args.port}/  (root: {root}, lang: {args.lang})")
    print("[companion] AtCoder の問題ページで Competitive Companion のアイコンをクリックしてください。Ctrl-C で停止。")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[companion] stopped.")


if __name__ == "__main__":
    main()
