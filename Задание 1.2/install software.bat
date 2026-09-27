@echo off
chcp 866 >nul
setlocal EnableDelayedExpansion
title Автоматическая установка ПО

REM --- Проверка прав администратора ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Требуются права администратора.
    echo     Запустите файл правой кнопкой - "Запуск от имени администратора".
    pause
    exit /b 1
)
echo [OK] Права администратора подтверждены.
echo.

REM --- Создание папок для логов и временных файлов ---
REM Логи пишутся в ту же папку, где лежит скрипт.
REM Временные файлы установщиков во временную папку пользователя.
set "LOG_DIR=%~dp0"
set "TMP_DIR=%TEMP%\SoftwareInstall"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
set "MAIN_LOG=%LOG_DIR%install_main.log"

echo ================================================================ >> "%MAIN_LOG%"
echo Начало установки: %date% %time% >> "%MAIN_LOG%"
echo ================================================================ >> "%MAIN_LOG%"

REM ================================================================
REM  ЭТАП 1. УСТАНОВКА CHOCOLATEY
REM ================================================================
echo [ЭТАП 1] Проверка и установка Chocolatey...
where choco >nul 2>&1
if %errorLevel% neq 0 (
    echo   - Chocolatey не найден. Устанавливаем...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if !errorLevel! neq 0 (
        echo   [!] Ошибка установки Chocolatey. Проверьте интернет.
        pause
        exit /b 1
    )
    echo   - Chocolatey установлен.
) else (
    echo   - Chocolatey уже установлен.
)
set "PATH=%PATH%;%ProgramData%\chocolatey\bin"
echo.

REM ================================================================
REM  ЭТАП 2. УСТАНОВКА ПО ЧЕРЕЗ CHOCOLATEY
REM  Исключены: knime, yandex-browser, anaconda3, googlechrome
REM ================================================================
echo [ЭТАП 2] Установка ПО через Chocolatey...

call :install vscode                "Visual Studio Code"
call :install docker-desktop        "Docker Desktop"
call :install pycharm-community     "PyCharm Community Edition"
call :install git                   "Git"
call :install github-desktop        "GitHub Desktop"
call :install maxima                "Maxima"
call :install gimp                  "GIMP"
call :install julia                 "Julia"
call :install python                "Python"
call :install rust                  "Rust"
call :install msys2                 "MSYS2 UCRT64"
call :install zettlr                "Zettlr"
call :install miktex                "MiKTeX"
call :install texstudio             "TeXStudio"
call :install far                   "Far Manager"
call :install sumatrapdf            "SumatraPDF"
call :install flameshot             "Flameshot"
call :install qalculate             "Qalculate!"
call :install 7zip                  "7-Zip"
call :install firefox               "Mozilla Firefox"
call :install microsoft-edge        "Microsoft Edge"

echo.
goto :after_choco

REM --- Подпрограмма установки одного пакета ---
:install
echo   - Установка %~2 (пакет: %~1)...
echo. >> "%MAIN_LOG%"
echo [%date% %time%] ==== %~2 (%~1) ==== >> "%MAIN_LOG%"
call choco install %~1 -y --no-progress --verbose --execution-timeout=3000 >> "%MAIN_LOG%" 2>&1
set "RC=!errorlevel!"
if "!RC!"=="0" (
    echo     [OK] %~2 установлен
) else if "!RC!"=="3010" (
    echo     [OK] %~2 установлен ^(требуется перезагрузка^)
) else if "!RC!"=="1641" (
    echo     [OK] %~2 установлен ^(инициирована перезагрузка^)
) else (
    echo     [ERR] Не удалось установить %~2 ^(код !RC!^)
)
exit /b

:after_choco

REM ================================================================
REM  ЭТАП 3. ПО ВНЕ CHOCOLATEY
REM ================================================================
echo [ЭТАП 3] Установка ПО вне Chocolatey...

REM --- KNIME ---
echo   - KNIME Analytics Platform...
winget install --id KNIMEAG.KNIMEAnalyticsPlatform --exact --silent --accept-package-agreements --accept-source-agreements >> "%MAIN_LOG%" 2>&1
if errorlevel 1 (
    echo     [!] Не удалось установить KNIME
) else (
    echo     [OK] KNIME установлен
)

REM --- Arc Browser ---
echo   - Arc Browser...
winget install --id TheBrowserCompany.Arc --exact --silent --accept-package-agreements --accept-source-agreements >> "%MAIN_LOG%" 2>&1
if errorlevel 1 (
    echo     [!] Не удалось установить Arc
) else (
    echo     [OK] Arc Browser установлен
)

REM --- Yandex Browser ---
echo   - Yandex Browser...
winget install --id Yandex.Browser --exact --silent --accept-package-agreements --accept-source-agreements >> "%MAIN_LOG%" 2>&1
if errorlevel 1 (
    echo     [!] Не удалось установить Yandex Browser
) else (
    echo     [OK] Yandex Browser установлен
)

REM --- Yandex.Telemost ---
echo   - Yandex.Telemost...
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'https://webdav.yandex.ru/share/dist/YTelemostSetup.msi' -OutFile '%TMP_DIR%\YTelemostSetup.msi' -UseBasicParsing } catch { exit 1 }"
if exist "%TMP_DIR%\YTelemostSetup.msi" (
    msiexec /i "%TMP_DIR%\YTelemostSetup.msi" /qn ALLUSERS="1" MSIINSTALLPERUSER="" SKIP_LAUNCH=1 NODESKTOPSHORTCUT=1 /norestart >> "%MAIN_LOG%" 2>&1
    set "RC=!errorlevel!"
    if "!RC!"=="0" (
        echo     [OK] Yandex.Telemost установлен
    ) else if "!RC!"=="3010" (
        echo     [OK] Yandex.Telemost установлен ^(требуется перезагрузка^)
    ) else (
        echo     [ERR] Не удалось установить Yandex.Telemost ^(код !RC!^)
    )
) else (
    echo     [!] Не удалось скачать MSI Yandex.Telemost
    echo     [!] Установить вручную с https://telemost.yandex.ru
)

REM --- Sber Jazz ---
echo   - Sber Jazz...
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'https://dl.salutejazz.ru/desktop/latest/jazz.exe' -OutFile '%TMP_DIR%\jazz.exe' -UseBasicParsing } catch { exit 1 }"
if exist "%TMP_DIR%\jazz.exe" (
    start /wait "" "%TMP_DIR%\jazz.exe" /S >> "%MAIN_LOG%" 2>&1
    echo     [OK] Sber Jazz установлен
) else (
    echo     [!] Не удалось скачать установщик Sber Jazz
)

REM --- Google Chrome (через winget) ---
echo   - Google Chrome...
winget install --id Google.Chrome --exact --silent --accept-package-agreements --accept-source-agreements >> "%MAIN_LOG%" 2>&1
if errorlevel 1 (
    echo     [!] Не удалось установить Google Chrome
) else (
    echo     [OK] Google Chrome установлен
)

REM --- Anaconda3 ---
echo   - Anaconda3...
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'https://repo.anaconda.com/archive/Anaconda3-2026.07-1-Windows-x86_64.exe' -OutFile '%TMP_DIR%\Anaconda3.exe' -UseBasicParsing } catch { exit 1 }"
if exist "%TMP_DIR%\Anaconda3.exe" (
    start /wait "" "%TMP_DIR%\Anaconda3.exe" /InstallationType=AllUsers /RegisterPython=0 /S /D=C:\Anaconda3 >> "%MAIN_LOG%" 2>&1
    if errorlevel 1 (
        echo     [!] Не удалось установить Anaconda3
    ) else (
        echo     [OK] Anaconda3 установлен в C:\Anaconda3
    )
) else (
    echo     [!] Не удалось скачать установщик Anaconda3
)

echo.

REM ================================================================
REM  ЭТАП 4. РАСШИРЕНИЯ VISUAL STUDIO CODE
REM ================================================================
echo [ЭТАП 4] Установка расширений Visual Studio Code...

set "VSCODE_CLI=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
if not exist "%VSCODE_CLI%" (
    echo   [!] code.cmd не найден. Пропускаем установку расширений.
    goto :after_vscode_ext
)

call :install_ext ms-python.python                  "Python"
call :install_ext ms-vscode.cpptools                "C/C++"
call :install_ext ms-azuretools.vscode-docker       "Docker"
call :install_ext dbaeumer.vscode-eslint            "ESLint (JS)"
call :install_ext esbenp.prettier-vscode            "Prettier (HTML/CSS/JS)"
call :install_ext eamodio.gitlens                   "GitLens"
call :install_ext julialang.language-julia          "Julia"
call :install_ext rust-lang.rust-analyzer           "Rust Analyzer"
call :install_ext ms-vscode-remote.remote-wsl       "WSL"
echo.
goto :after_vscode_ext

:install_ext
echo   - Расширение %~2...
call "%VSCODE_CLI%" --install-extension %~1 --force >> "%MAIN_LOG%" 2>&1
if errorlevel 1 (
    echo     [!] Не удалось установить %~2
) else (
    echo     [OK] %~2 установлено
)
exit /b

:after_vscode_ext

REM ================================================================
REM  ЭТАП 5. ПОДГОТОВКА WSL 2 (включение компонентов Windows)
REM ================================================================
echo [ЭТАП 5] Подготовка WSL 2...

echo   - Включение компонента WSL...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >> "%MAIN_LOG%" 2>&1

echo   - Включение компонента VirtualMachinePlatform...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >> "%MAIN_LOG%" 2>&1

echo   [OK] Компоненты WSL включены.
echo.

REM ================================================================
REM  ЭТАП 6. РЕГИСТРАЦИЯ АВТОЗАПУСКА ВТОРОГО СКРИПТА
REM  После перезагрузки задача ITiEO_InstallWSL запустит
REM  install_wsl.bat от имени администратора при входе в систему.
REM ================================================================
echo [ЭТАП 6] Регистрация задачи для установки WSL после перезагрузки...

schtasks /create /tn "ITiEO_InstallWSL" /tr "\"%~dp0install_wsl.bat\"" /sc onlogon /rl highest /f >> "%MAIN_LOG%" 2>&1
if errorlevel 1 (
    echo   [!] Не удалось создать задачу автозапуска.
    echo       Запустите install_wsl.bat вручную после перезагрузки.
) else (
    echo   [OK] Задача создана. После перезагрузки WSL установится автоматически.
)
echo.

rmdir /s /q "%TMP_DIR%" >nul 2>&1

REM ================================================================
REM  ЗАВЕРШЕНИЕ
REM ================================================================
echo ================================================================
echo   Установка завершена!
echo   Лог: %MAIN_LOG%
echo ================================================================
echo Завершение: %date% %time% >> "%MAIN_LOG%"

echo.
choice /C YN /T 60 /D Y /M "Перезагрузить для продолжения установки WSL? (Y - да, N - нет)"
if errorlevel 2 goto :no_reboot
if errorlevel 1 goto :do_reboot

:do_reboot
echo.
echo Перезагрузка через 60 секунд. Сохраните данные!
shutdown /r /t 60 /c "Установка ПО: перезагрузка для активации WSL 2"
goto :end

:no_reboot
echo.
echo Перезагрузка отложена. Запустите install_wsl.bat вручную.

:end
pause
endlocal