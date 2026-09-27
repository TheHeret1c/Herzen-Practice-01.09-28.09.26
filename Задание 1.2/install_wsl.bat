@echo off
chcp 866 >nul
setlocal
title Установка WSL 2 и Ubuntu

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Требуются права администратора.
    pause
    exit /b 1
)

echo ================================================================
echo   Установка WSL 2 и Ubuntu
echo ================================================================
echo.

REM --- Установка ядра WSL 2 ---
echo   - Установка ядра WSL 2...
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%TEMP%\wsl_update_x64.msi' -UseBasicParsing } catch { exit 1 }"
if exist "%TEMP%\wsl_update_x64.msi" (
    start /wait "" msiexec /i "%TEMP%\wsl_update_x64.msi" /qn /norestart
    echo   [OK] Ядро WSL 2 установлено.
) else (
    echo   [!] Не удалось скачать ядро WSL 2.
    pause
    exit /b 1
)

REM --- Версия WSL по умолчанию ---
wsl --set-default-version 2
echo   [OK] Версия WSL по умолчанию: 2.

REM --- Установка Ubuntu ---
echo.
echo   - Установка Ubuntu через winget...
winget install --id Canonical.Ubuntu.2204 --exact --silent --accept-package-agreements --accept-source-agreements
winget install --id Canonical.Ubuntu.2404 --exact --silent --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
    echo   [!] Не удалось установить Ubuntu.
    pause
    exit /b 1
)
echo   [OK] Ubuntu установлена.

REM --- Уборка ---
del /q "%TEMP%\wsl_update_x64.msi" 2>nul

echo   - Удаление задачи автозапуска...
schtasks /delete /tn "ITiEO_InstallWSL" /f >nul 2>&1

echo.
echo ================================================================
echo   Готово!
echo ================================================================
echo.
echo   Для активации Ubuntu:
echo   1. Откройте Ubuntu в меню "Пуск"
echo   2. Создайте пользователя Linux и задайте пароль
echo   3. Проверьте: wsl -l -v
echo.

pause
endlocal