@echo off
chcp 65001 >nul
set OUT=%~dp0diag.txt
echo diag > "%OUT%"
echo --- where >> "%OUT%"
where flutter >> "%OUT%" 2>&1
where dart >> "%OUT%" 2>&1
where node >> "%OUT%" 2>&1
where python >> "%OUT%" 2>&1
where chrome >> "%OUT%" 2>&1
where git >> "%OUT%" 2>&1
echo --- versions >> "%OUT%"
call flutter --version >> "%OUT%" 2>&1
node -v >> "%OUT%" 2>&1
python --version >> "%OUT%" 2>&1
echo --- chrome paths >> "%OUT%"
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" echo C:\Program Files\Google\Chrome\Application\chrome.exe >> "%OUT%"
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" echo C:\Program Files (x86)\Google\Chrome\Application\chrome.exe >> "%OUT%"
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" echo %LOCALAPPDATA%\Google\Chrome\Application\chrome.exe >> "%OUT%"
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" echo C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe >> "%OUT%"
echo --- python playwright/selenium >> "%OUT%"
python -c "import importlib.util as u;print([m for m in ('playwright','selenium','websockets','websocket') if u.find_spec(m)])" >> "%OUT%" 2>&1
echo --- screen >> "%OUT%"
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::PrimaryScreen.Bounds" >> "%OUT%" 2>&1
echo done >> "%OUT%"
