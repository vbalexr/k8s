# k8s repo setup

## Git hooks
1) Enable hooks for this repo:

```
git config core.hooksPath .githooks
```

2) Windows notes:
- Install Git for Windows (includes `sh.exe`). The hook runs via `.githooks/pre-commit.cmd`.
- If using WSL, run the command above inside your WSL shell.

3) Verify:
- Stage a Kubernetes Secret YAML without `sops` metadata; the commit should be blocked.
