# gen-keybind-cheatsheet

`gen-keybind-cheatsheet` スキルのドメインモデル。対象ソフトウェアのキーバインドについて、公式デフォルトと設定ファイルによる上書きを突き合わせ、HTML形式のチートシートを生成するスキルの用語を定義する。

## Language

**Keybind**:
特定の操作(コマンド実行)に紐づけられたキー入力の組み合わせ。
_Avoid_: ショートカット, ホットキー, キーバインディング

**Target Software**:
チートシート生成の対象として選ばれた、単一のソフトウェア。
_Avoid_: 対象アプリ, 選択ツール

**Software Catalog**:
Target Softwareの候補を検出するための、「ソフトウェアID → 設定ファイルのパターン・公式ドキュメント参照先」の対応表。スキル実行のたびに未知のソフトウェアを検出・確認して追記され、育っていく永続データ。
_Avoid_: レジストリ, データベース

**Default Keybind**:
Target Softwareが設定ファイル未指定時に持つ、標準のKeybind。可能な場合はソフトウェア自身の内省コマンド(例: `ghostty +show-config --default`)から取得し、内省手段が無い場合のみ公式ドキュメントから取得する。取得元はチートシート上に出典として明記する。Default Keybindが存在しない/取得できないソフトウェアでは空集合として扱う。
_Avoid_: 標準ショートカット, 初期値

**Keybind Status**:
チートシート上で各Keybindに付与する3分類のいずれか。
- **Default** — Default Keybindと完全一致(キー・動作とも変更なし)
- **Overridden** — Default Keybindに存在する動作が別のキーに再割当て、または同じキーが別の動作に変更されている
- **Custom** — Default Keybindには存在しない、設定ファイル固有のKeybind
_Avoid_: 上書き種別, 変更フラグ
