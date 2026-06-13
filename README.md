# Olympix local setup

## 1. Install

Right-click `setup-olympix.ps1` → **Run with PowerShell**, or in a PowerShell window:

```powershell
cd $HOME\OneDrive\Documents\olympix
.\setup-olympix.ps1
```

The script auto-detects your architecture (x64 / ARM64), downloads `olympix.exe` v0.11.83, verifies the SHA-256 against the published manifest, optionally adds this folder to your user PATH, and runs `olympix login -e ashutoshkumarsingh0x@gmail.com`.

If PowerShell blocks the script, run once:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

You'll get a one-time code by email — paste it into the prompt. Your API token lands in `~/.opix/config.json`.

## 2. VSCode extension

Install from the Marketplace: search **Olympix** (publisher `Olympixai`) inside VSCode, or open <https://marketplace.visualstudio.com/items?itemName=Olympixai.olympix>.

## 3. First commands

From a Solidity project root:

```powershell
olympix analyze                       # static analysis, tree output
olympix analyze -f sarif -o .         # SARIF for GitHub code scanning
olympix generate-unit-tests           # AI unit tests
olympix generate-mutation-tests -p src/MyContract.sol
olympix bug-pocer                     # AI vuln scan + PoC
olympix show-vulnerabilities          # list detectors
```

Common flags: `-w` workspace root, `-p` path (repeatable), `-f tree|json|sarif|email`, `--no-<vuln-id>` to skip a detector.

## 4. GitHub Action

Add `OLYMPIX_API_TOKEN` as a repo secret (use `olympix generate-api-token` to mint one), then:

```yaml
- uses: olympix/integrated-security@main
  env:
    OLYMPIX_API_TOKEN: ${{ secrets.OLYMPIX_API_TOKEN }}
- uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: olympix.sarif
```

## Links

- Docs: <https://olympix.github.io/>
- CLI reference: <https://olympix.github.io/cli/>
- Integrated Security action: <https://github.com/marketplace/actions/olympix-integrated-security>
- Support: contact@olympix.ai
