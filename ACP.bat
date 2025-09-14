@echo off
chcp 65001 >nul

REM Переход в рабочую директорию
cd "C:\Users\VLemeshev\Documents\Стажировка, записи\Стажировка"

REM Получение текущей даты в формате DD.MM.YYYY
for /f "tokens=1-3 delims=/" %%a in ('date /t') do (
    set DAY=%%a
    set MONTH=%%b
    set YEAR=%%c
)
set CURRENT_DATE=%DAY%.%MONTH%.%YEAR%

REM Проверка наличия изменений
git diff --quiet
if %errorlevel% equ 0 (
    git diff --staged --quiet
    if %errorlevel% equ 0 (
        echo [%CURRENT_DATE%]: сегодня изменений не было((
        echo программа завершена;
        exit /b 0
    )
)

REM Сначала добавляем все файлы, кроме самого bat-файла
git add .

REM Исключаем текущий bat-файл из индекса (если он есть)
git reset -- ACP.bat >nul 2>&1

REM Получение статуса файлов и подсчет
set NEW_FILES=0
set MODIFIED_FILES=0

for /f "delims=" %%i in ('git status --porcelain') do (
    set "line=%%i"
    set "status=!line:~0,2!"
    
    if "!status!"=="??" (
        set /a NEW_FILES+=1
    ) else if "!status!"==" M" (
        set /a MODIFIED_FILES+=1
    ) else if "!status!"=="M " (
        set /a MODIFIED_FILES+=1
    ) else if "!status!"=="MM" (
        set /a MODIFIED_FILES+=1
    ) else if "!status!"=="A " (
        set /a NEW_FILES+=1
    ) else if "!status!"=="AM" (
        set /a NEW_FILES+=1
    )
)

REM Теперь добавляем текущий bat-файл отдельно (если он новый)
if exist ACP.bat (
    git add ACP.bat
    set /a NEW_FILES+=1
)

REM Коммит новых файлов (если есть)
if %NEW_FILES% gtr 0 (
    git commit -m "[%CURRENT_DATE%]: добавлено [%NEW_FILES%] новых файлов"
    echo Отправка коммита с новыми файлами...
    git push -u origin master
    if %errorlevel% equ 0 (
        powershell -Command "Write-Host '✓ Коммит успешно отправлен!' -ForegroundColor Green"
    ) else (
        powershell -Command "Write-Host '✗ Ошибка при отправке коммита' -ForegroundColor Red"
    )
)

REM Коммит измененных файлов (если есть)
if %MODIFIED_FILES% gtr 0 (
    git add -u
    if %NEW_FILES% gtr 0 (
        git commit -m "[%CURRENT_DATE%]: добавлено [%NEW_FILES%] файлов, изменено [%MODIFIED_FILES%] файлов"
    ) else (
        git commit -m "[%CURRENT_DATE%]: изменено [%MODIFIED_FILES%] файлов"
    )
    echo Отправка коммита с изменениями...
    git push -u origin master
    if %errorlevel% equ 0 (
        powershell -Command "Write-Host '✓ Коммит успешно отправлен!' -ForegroundColor Green"
    ) else (
        powershell -Command "Write-Host '✗ Ошибка при отправке коммита' -ForegroundColor Red"
    )
)

echo программа завершена;