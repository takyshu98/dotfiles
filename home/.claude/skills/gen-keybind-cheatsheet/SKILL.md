---
name: gen-keybind-cheatsheet
description: Generate an HTML keybind cheat sheet for a piece of software found in the current repo, reconciling its official default keybinds against overrides defined in the repo's config file. Use when the user wants a shortcut/keybind cheat sheet, or asks to document a tool's keybindings including config-file overrides.
---

Generate a self-contained HTML cheat sheet of Keybinds for one Target Software detected in the current repository, showing which Keybinds come from the software's own defaults and which are overridden or added by the repo's config file.

Domain vocabulary (Keybind, Target Software, Software Catalog, Default Keybind, Keybind Status) is defined in [CONTEXT.md](./CONTEXT.md) — read it before doing anything else, and keep it updated if this skill's vocabulary changes. The reasoning behind the agent-driven, low-maintenance approach used throughout is recorded in [docs/adr/0001-agent-driven-low-maintenance-design.md](./docs/adr/0001-agent-driven-low-maintenance-design.md).

## Step 1 — Resolve the Target Software

- If invoked with an argument (e.g. `/gen-keybind-cheatsheet tmux`), treat it as the requested software id.
  - If it matches an id in [references/catalog.yaml](./references/catalog.yaml), skip straight to confirming its config file(s) exist in the current repo, then go to Step 2.
  - If it doesn't match any catalog id, tell the user it's not in the Software Catalog yet and fall back to the detection flow below (do not silently ignore the argument).
- Otherwise (no argument), detect candidates:
  1. Read `references/catalog.yaml` and search the current repo for files matching each entry's `config_patterns`.
  2. Separately, look for other plausible config files (dotfiles-shaped paths, e.g. under `.config/*/`) that don't match any known pattern.
  3. For any unmatched candidates found in step 2, infer what software each belongs to (filename, directory name, file contents/syntax). Collect all of them and ask the user to confirm the guesses **in a single batched question**, not one at a time.
  4. For each confirmed guess, append a new entry to `references/catalog.yaml` (id, `config_patterns`, a short `notes` description) so future runs recognize it without asking again. Reject/skip anything the user didn't confirm — never write unconfirmed guesses to the catalog.
  5. Present the full candidate list (known + newly confirmed) and ask the user to pick one Target Software.

## Step 2 — Resolve the Default Keybind set

Check `references/defaults/<software-id>.json` first — if present, reuse it (it caches a prior resolution: the Keybind list, `source`, and `fetched_at`). Otherwise resolve fresh and write the cache:

1. **Prefer introspection**: if the software has a way to print its own default keybinds (a CLI flag, a `--default`/`--docs` style option, a `list-keys` style command), run it and parse the output. This tracks whatever version is actually installed.
2. **Fall back to documentation**: if no introspection path exists or it fails, look up the official docs (WebFetch/WebSearch) and read the default keybind reference from there.
3. If neither yields anything (e.g. the software ships with no built-in keybinds, like AeroSpace or Karabiner), record an empty set — this is expected, not an error.
4. Write `references/defaults/<software-id>.json` with the resolved Keybind list plus `source` (command invoked, or doc URL) and `fetched_at` (ask the user for today's date if you need to stamp it, since you cannot read the system clock directly). This cache is what gets cited on the rendered page.

## Step 3 — Extract config-defined Keybinds

Locate the Target Software's config file(s) in the current repo via its `config_patterns`. Read the raw file content and extract every Keybind definition (key combination + the action/command it triggers) by reading and understanding the file — do not write a format-specific parser (see ADR 0001). This applies uniformly whether the file is TOML, JSON, Lua, or a bespoke DSL like `tmux.conf`.

## Step 4 — Classify Keybind Status

For every Keybind found in Step 3, compare it against the Default Keybind set from Step 2 and classify it:

- **Default** — same key, same action as a Default Keybind (config merely restates the default, or the key isn't touched at all and you're listing it for completeness — only list config-defined ones plus any defaults worth showing for context).
- **Overridden** — the key exists in Default Keybind under a different action, or the same action exists in Default Keybind under a different key.
- **Custom** — no corresponding entry in Default Keybind at all (this is the only possible category when Default Keybind is empty).

Match by *action semantics*, not string equality — default docs and config files rarely use identical wording. Use judgment; if a match is ambiguous, prefer classifying as Custom over guessing wrong.

## Step 5 — Render the HTML cheat sheet

Produce one self-contained `.html` file (inline CSS/JS, no external requests) with:

- Sections grouped by the software's modes/contexts (e.g. tmux prefix table vs. copy-mode table; Neovim Normal/Insert/Visual; a leader-key table for wezterm). If the software has no natural modes, a single flat table is fine.
- A colored status badge per row for Default / Overridden / Custom.
- A plain-text filter input and a Status filter, implemented in vanilla JS (no CDN dependencies).
- A visible citation of the Default Keybind `source` from the cache file (command or doc URL) and, if applicable, a note that a software has no built-in defaults.

Write the file to `./cheatsheets/<software-id>.html` relative to the current working directory (the repo being processed, not this skill's own directory) — create the `cheatsheets/` directory if it doesn't exist. Report the path to the user when done.
