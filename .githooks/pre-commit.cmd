@echo off
setlocal
set "HOOKDIR=%~dp0"

for %%G in (sh.exe bash.exe) do (
  where %%G >nul 2>nul && (
    "%%G" "%HOOKDIR%pre-commit" %*
    exit /b %ERRORLEVEL%
  )
)

echo ERROR: sh.exe not found. Install Git for Windows or use WSL to run hooks.
exit /b 1
