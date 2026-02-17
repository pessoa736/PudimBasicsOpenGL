@echo off
setlocal

cd /d "%~dp0"

where make >nul 2>nul
if %errorlevel%==0 (
    make test
    exit /b %errorlevel%
)

where mingw32-make >nul 2>nul
if %errorlevel%==0 (
    mingw32-make test
    exit /b %errorlevel%
)

echo ERRO: Nao encontrei ^"make^" nem ^"mingw32-make^" no PATH.
echo Dica: no MSYS2/MinGW, instale o GCC/Make e rode pelo terminal MinGW64.
exit /b 1
