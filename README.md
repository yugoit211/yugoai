# YUGOAI Agent

**White-label AI Agent — Hermes-powered, YUGOAI-branded.**

YUGOAI Agent adalah AI agent yang berjalan di terminal, messaging platforms, dan IDE.
100% kompatibel dengan Hermes Agent — hanya beda nama dan identitas.

---

## Quick Install (untuk user)

```bash
curl -fsSL https://raw.githubusercontent.com/yugoit211/yugoai/main/install.sh | bash
```

Tutup dan buka ulang terminal, lalu:

```bash
yugoai setup       # Setup API key + model (sekali saja)
yugoai              # Mulai chat!
```

---

## Fitur

- Terminal-native AI agent dengan tool calling (shell, file, web, browser)
- Support DeepSeek, OpenAI, Anthropic, OpenRouter, dan 15+ provider
- Persistent memory antar sesi
- Self-improving skills
- Messaging gateway (Telegram, Discord, Slack, WhatsApp, Signal, dll)
- Cron scheduler, multi-agent delegation, MCP servers

---

## Penggunaan

```bash
yugoai                        # Interactive chat
yugoai chat -q "query"        # Single query
yugoai model                  # Ganti model/provider
yugoai setup                  # Setup wizard
yugoai doctor                 # Health check
yugoai config                 # Lihat konfigurasi
yugoai sessions list          # List sesi
yugoai skills list            # List skills
yugoai gateway start          # Jalankan messaging gateway
```

---

## Perbedaan dengan Hermes

YUGOAI Agent **bukan fork** — ini white-label di atas Hermes:

| | Hermes | YUGOAI |
|---|---|---|
| CLI | `hermes` | `yugoai` |
| Profile | `default` | `yugoai` |
| DNA | Hermes | Hermes (identik) |
| Update | `hermes update` | `hermes update` |

YUGOAI selalu up-to-date mengikuti update Hermes. Tidak ada maintenance fork.

---

## Struktur Project

```
YUGOAI/
├── install.sh             # Standalone installer (curl-pipe friendly)
├── bin/yugoai             # CLI wrapper script
├── README.md              # Dokumentasi
├── config/                # Template konfigurasi
├── personalities/         # Custom personality files
├── skills/                # Custom skills
└── scripts/               # Utility scripts
```

Profile YUGOAI: `~/.hermes/profiles/yugoai/`

---

## Uninstall

```bash
hermes profile delete yugoai    # Hapus profile
rm ~/.local/bin/yugoai           # Hapus wrapper
rm -rf ~/YUGOAI                  # Hapus project (jika di-clone)
```

---

## Cara Distribusi

### Share install command

User tinggal:

```bash
curl -fsSL https://raw.githubusercontent.com/yugoit211/yugoai/main/install.sh | bash
```

### (Optional) Homebrew

Buat formula Homebrew untuk `brew install yugoai`.

---

## License

MIT — Engine: [Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research.
