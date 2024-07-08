@echo off
REM 运行 Node.js 脚本
node xor.js

REM 查找所有的 video 目录
for /d %%i in (video*) do (
    REM 检查是否存在 decode 文件夹和 filelist.txt 文件
    if exist "%%i\decode\filelist.txt" (
        REM 执行 ffmpeg 命令
        ffmpeg -f concat -i "%%i\decode\filelist.txt" -c copy "%%i.mp4"
    ) else (
        echo "Warning: %%i\decode\filelist.txt not found"
    )
)

pause