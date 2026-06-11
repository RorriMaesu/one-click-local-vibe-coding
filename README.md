# 🚀 One-Click Local Vibe Coding

[![GitHub license](https://img.shields.io/github/license/RorriMaesu/one-click-local-vibe-coding?color=blue)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/RorriMaesu/one-click-local-vibe-coding)](https://github.com/RorriMaesu/one-click-local-vibe-coding/stargazers)
[![Local Vibe Coding Speed](https://img.shields.io/badge/Speed-85%2B%20TPS-brightgreen)](#)
[![Model Support](https://img.shields.io/badge/Model-Gemma%204%2012B-orange)](#)

Boot your ultra-fast, local AI coding environment on Windows with a single click. Zero config. Zero headache. Maximum performance.

---

## ⚡ The Local Vibe Coding Advantage

Modern agentic coding tools like **Cline**, **Roo Code**, or **Aider** demand rapid response times to feel truly interactive. Traditional local setups are sluggish, bottlenecked by standard single-token generation.

This repository changes that. By leveraging **llama.cpp's native Multi-Token Prediction (MTP)** support combined with **Unsloth's optimized Gemma 4 12B IT GGUF**, you can unlock an immediate **1.5x to 2.2x speedup** on consumer hardware.

> [!NOTE]
> ### 📊 Hardware Performance Benchmark
> * **Target Model:** Gemma 4 12B IT (`Q4_K_M`)
> * **Hardware:** Common 16GB VRAM GPUs (e.g., NVIDIA RTX 4060 Ti / RTX 5060 Ti)
> * **Throughput:** **85+ Tokens Per Second (TPS)**
> * **Latency:** Near-instantaneous response times, enabling fluid and continuous "vibe coding" sessions.

---

## 🛡️ "Storage Shield" System Protection

Large LLM weights can exhaust primary C-drive partitions, causing Windows slowdowns and system instability. 

This installer includes an automatic **Storage Shield** protocol:
* **Secondary Drive Detection**: The script auto-detects if a secondary `D:` drive is present.
* **Force Sandboxing**: If a `D:` drive is detected, the entire setup—including binaries, models, and cache folder structures—is initialized at `D:\llama-cpp`.
* **Zero C-Drive Footprint**: Heavy Hugging Face cache repositories (`HF_HUB_CACHE` and `HF_HOME`) are directed to the sandbox partition via process-level environment variables, ensuring your system C: drive remains **100% clean and protected**.

---

## 🛠️ Dead-Simple 3-Step Setup

Get up and running in less than 3 minutes. No need to install git, build-tools, or compile binaries manually.

### Step 1: Open PowerShell as Administrator
Right-click your Windows Start button and select **Terminal (Admin)** or **PowerShell (Admin)**.

### Step 2: Run the Setup Wizard
Copy, paste, and run the following command to download and run the installer:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/RorriMaesu/one-click-local-vibe-coding/main/setup.ps1'))
```

### Step 3: Start Vibe Coding
* Double-click the **Run Llama Server** shortcut created on your Desktop.
* The server will automatically spin up on **`http://127.0.0.1:8080`**.
* *First-time launch note*: The server will download the Gemma 4 12B IT model weights directly from Hugging Face and load them straight into GPU memory.

---

## 💻 VS Code Automation Scaffold

For seamless developer experience, drop the following portable task configuration into your project folder. It will allow you to start the server directly inside VS Code.

Create a folder named `.vscode` in your workspace, and save this as `tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Local Llama Server",
      "type": "shell",
      "command": "powershell -ExecutionPolicy Bypass -Command \"if (Test-Path 'D:\\llama-cpp\\run-server.bat') { & 'D:\\llama-cpp\\run-server.bat' } else { & 'C:\\llama-cpp\\run-server.bat' }\"",
      "problemMatcher": [],
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": true,
        "panel": "dedicated",
        "showReuseMessage": false,
        "clear": true
      },
      "runOptions": {
        "runOn": "folderOpen"
      }
    }
  ]
}
```

---

## 🧠 Cline / Roo Code System Prompt Block

Many modern reasoning models output lengthy `<|think|>` blocks before writing code. While useful for complex logic, these reasoning strings dramatically slow down file operations and UI generation. 

To maximize generation speed, paste the following prompt block into your agent configuration (e.g., Cline's system prompt instructions) to strip away reasoning tokens and force rapid file generation:

```markdown
=== local-vibe-coding-mode ===
You are running on a high-throughput, local inference server powered by llama.cpp.
To ensure immediate file updates and rapid iterations:
1. DO NOT output any `<|think|>` or `<thought>` XML tags.
2. Skip conversational preambles or post-generation explanations.
3. Output code modifications directly and concisely.
4. Focus strictly on executing edits inside the workspace files.
==============================
```

---

## ❓ FAQ & Troubleshooting

#### 1. What if my NVIDIA CUDA Toolkit is missing?
The setup script detects if you have an NVIDIA GPU but are missing the system-wide CUDA Toolkit. It automatically downloads the official pre-compiled CUDA runtime libraries (`cudart`) directly alongside the llama.cpp binaries, meaning GPU acceleration works **out of the box** without any complex toolkits to install.

#### 2. How do I change the default model?
If you want to use a different model, simply edit the generated `run-server.bat` file in your install directory (`D:\llama-cpp` or `C:\llama-cpp`) and modify the `-hf` flag parameter to point to any Hugging Face GGUF repository. For example:
```batch
llama-server.exe -hf Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q4_K_M --port 8080
```

---

## 📄 License

This project is open-source and licensed under the MIT License. See [LICENSE](LICENSE) for details.
