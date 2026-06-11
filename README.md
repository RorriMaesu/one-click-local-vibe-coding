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
* **Zero C-Drive Footprint**: Heavy Hugging Face cache repositories (`HF_HUB_CACHE` and `HF_HOME`) are directed to the sandbox partition via process-level environment variables inside the server launcher, ensuring your system C: drive remains **100% clean and protected**.

---

## 🛠️ Step-by-Step Setup Guide

Get up and running in less than 3 minutes. No need to install git, build-tools, or compile binaries manually.

### Step 1: Open PowerShell as Administrator
1. Press the **Windows Key** on your keyboard.
2. Type `PowerShell`.
3. Right-click on **Windows PowerShell** (or **Terminal**) and select **Run as Administrator**.
4. Click **Yes** on the Windows User Account Control (UAC) prompt.

### Step 2: Run the Setup Wizard
Copy the command block below, paste it into your administrator PowerShell window, and press **Enter**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/RorriMaesu/one-click-local-vibe-coding/main/setup.ps1'))
```

#### What the installer does behind the scenes:
1. **Scans drives**: Checks if a `D:` drive is present. If yes, it creates `D:\llama-cpp`. Otherwise, it falls back to `C:\llama-cpp`.
2. **Scans GPU capabilities**: Checks for NVIDIA GPUs via `nvidia-smi` and checks if the CUDA Toolkit is installed.
   * *If CUDA is present:* It detects the version (v12.x or v13.x) and chooses the corresponding build.
   * *If CUDA is missing but an NVIDIA GPU is found:* It downloads the main CUDA binaries along with the CUDA runtime DLL package (`cudart`). This allows GPU acceleration to run smoothly without installing the full CUDA Toolkit.
   * *If no GPU is found:* It prompts you to download CPU-optimized binaries.
3. **Downloads llama.cpp**: Queries the GitHub API for the latest pre-built Windows releases from `ggml-org/llama.cpp` and extracts the binaries into `[SelectedDrive]:\llama-cpp\bin\`.
4. **Writes the Launcher**: Generates `run-server.bat` in the root of the sandbox.
5. **Registers Desktop Shortcut**: Creates a `Run Llama Server` shortcut directly on your Windows Desktop.

### Step 3: Boot the Server
1. Go to your desktop and double-click the new shortcut **Run Llama Server**.
2. A command prompt window will open. On the first launch, the server will detect that the model weights are missing and will automatically download the **Gemma 4 12B IT GGUF (Q4_K_M)** model directly from Hugging Face.
3. Once the download completes, it will load the model into GPU memory and run the server. You'll know it's ready when you see output indicating it is listening on:
   ```
   http://127.0.0.1:8080
   ```

---

## 🔌 Connecting to Cline (VS Code Extension)

To connect the popular **Cline** AI coding assistant to your local server, follow these exact settings:

1. **Open Cline Settings**:
   * Open VS Code.
   * Click on the **Cline** icon in the left-hand activity bar.
   * Click the **Gear icon (⚙️)** in the top right of the Cline panel to open settings.
2. **Configure API Provider**:
   * Change the **API Provider** dropdown to **`OpenAI Compatible`**.
3. **Configure Connection details**:
   * **Base URL**: Set this to **`http://127.0.0.1:8080/v1`** (make sure to include the `/v1` suffix).
   * **API Key**: Enter a dummy key (e.g., `nokey`). Llama.cpp doesn't require a key, but Cline needs a placeholder to enable saving.
   * **Model ID**: Enter **`unsloth/gemma-4-12B-it-GGUF:Q4_K_M`**.
4. **Set Context Limits**:
   * **Model Context Window (tokens)**: Set this to **`32768`** (matching the `-c 32768` server parameter).
5. Click **Done** or **Save** at the bottom of the Cline settings.

---

## 💻 VS Code Automation Scaffold

For a completely automated developer experience, you can add a boot task to your project workspace. This allows the local server to spin up automatically whenever you open your coding project.

Create a folder named `.vscode` in the root of your workspace, and save the following file as `tasks.json`:

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

### How to configure custom instructions in Cline:
1. Open Cline settings (⚙️).
2. Scroll down to **Custom Instructions**.
3. Paste the following block inside:

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

#### 3. How do I verify my C: drive is protected?
Once the server is running and downloading the model weights, open Windows File Explorer and check the properties of `D:\llama-cpp\hf_cache` (or `C:\llama-cpp\hf_cache` if you don't have a secondary drive). You will see the cache folder size grow to several gigabytes as the model downloads, confirming that your system folder `%USERPROFILE%\.cache` is completely untouched.

---

## 📄 License

This project is open-source and licensed under the MIT License. See [LICENSE](LICENSE) for details.
