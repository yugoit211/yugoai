# YUGOAI Agent

**White-label AI Agent — Hermes-powered, YUGOAI-branded, DeepSeek-driven.**

YUGOAI Agent adalah AI agent yang berjalan di terminal.
100% kompatibel dengan Hermes Agent — DNA, knowledge, dan behaviour identik. Hanya beda nama.

---

## DNA Hermes Tetap Utuh

YUGOAI **tidak mengubah DNA Hermes sama sekali**:

- System prompt, tool instructions, skill loading → **100% asli Hermes**
- SOUL.md hanya ganti identitas: "I am YUGOAI Agent, created by Yugo-Labs-AI"
- Engine code hanya di-patch untuk label versi dan provider name
- Semua fitur Hermes tetap jalan: skills, memory, delegation, cron, gateway, MCP

---

## Instalasi

### macOS & Linux

```bash
curl -fsSL https://raw.githubusercontent.com/yugoit211/yugoai/main/install.sh | bash
```

Tutup & buka terminal baru, lalu:

```bash
yugoai
```

### Windows (WSL2)

Windows native tidak didukung — gunakan WSL2:

```powershell
# 1. Install WSL2 (sekali saja)
wsl --install

# 2. Masuk ke Ubuntu/Linux di WSL, lalu jalankan:
curl -fsSL https://raw.githubusercontent.com/yugoit211/yugoai/main/install.sh | bash

# 3. Buka terminal baru, lalu:
yugoai
```

### Docker

```bash
docker run -it --rm \
  -e DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY" \
  -v ~/.hermes:/root/.hermes \
  --entrypoint /bin/bash \
  nikolaik/python-nodejs:python3.11-nodejs20 \
  -c "curl -fsSL https://raw.githubusercontent.com/yugoit211/yugoai/main/install.sh | bash && yugoai"
```

### Manual (semua OS dengan Python 3.11+)

```bash
# 1. Install Hermes
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# 2. Download YUGOAI
git clone https://github.com/yugoit211/yugoai.git ~/YUGOAI
cd ~/YUGOAI

# 3. Jalankan installer
./install.sh
```

---

## Penggunaan

```bash
yugoai                        # Interactive chat
yugoai chat -q "query"        # Single query
yugoai doctor                 # Health check
yugoai config                 # Lihat konfigurasi
yugoai sessions list          # List sesi
yugoai skills list            # List skills
yugoai gateway start          # Messaging gateway
```

---

## Perbedaan dengan Hermes

| | Hermes | YUGOAI |
|---|---|---|
| CLI | `hermes` | `yugoai` |
| Profile | `default` | `yugoai` |
| DNA/Knowledge | Hermes | Hermes (identik) |
| System prompt | Asli | Asli (tidak diubah) |
| Model | Pilih bebas | DeepSeek (auto-locked) |
| Update | `hermes update` | `hermes update` |

---

## Uninstall

```bash
hermes profile delete yugoai
rm ~/.local/bin/yugoai
rm -rf ~/YUGOAI
```

---

## License

MIT — Engine: [Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research.
