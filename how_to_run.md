## How to Run
Want to run EsoHype? Intrigued by the language itself? Feel free to read this guide!

## Instructions
1. Download the GitHub repository as a .zip file, or [click here](https://github.com/solarcosmic/EsoHype/archive/refs/heads/main.zip) to automatically start downloading. (You can also clone the Git repository instead, both work)
2. Assuming you have the downloaded .zip archive, extract it to a folder.
    - If you have 7-Zip, right click on the downloaded .zip file in File Explorer, and go to 7-Zip > Extract to "esohype\\".
    - If you have WinRAR, the process is almost the same. Right click on the archive file (.zip) and click "Extract to esohype\\" or similar.
3. Open up the newly created folder by your archive manager (7-Zip, WinRAR) which should be named something like "esohype".
### Windows
If you're on Windows, you can open `esohype.exe`.

<img width="1076" height="615" alt="Screenshot 2025-07-17 103001" src="https://github.com/user-attachments/assets/4b4dbcfb-9b6a-4785-b0de-418a8f8d8e8d" />

> If you ever get this popup, just click "Run Anyway". This is Windows complaining because the executable doesn't have a signed certificate.

EsoHype will then ask for a script path. This is where your script is located. It must be located in the same folder or in a descendant folder for EsoHype to find it.

<img width="1417" height="330" alt="Screenshot 2025-07-17 104934" src="https://github.com/user-attachments/assets/0a1e93e8-caea-4435-a56b-99be0f317882" />

> Note: If your .hyp file is in a descendant folder (a descendant folder where `esohype.exe` is located), for example, the folder `/examples`, then for the script path you would just type `examples/<name>.hyp`, for example: `examples/fibonacci.hyp`.

### macOS/Linux
> As of writing this, I'm unfamiliar with how macOS does things, so if the guide isn't that clear, sorry! These steps will primarily go through the Linux route, but it should be similar on macOS. Feel free to contribute and make a pull request.

Unfortunately, EsoHype installation on macOS/Linux is not that straight forward. You're going to need to follow these steps:
1. Make sure you have Lua installed on your system (recommended 5.3+) and added to your PATH environment variables.
    - If you're using macOS, consider [Homebrew](https://brew.sh/) as an option. Then just type, in a terminal:
    ```
    brew update
    brew install lua
    ```
    - If you're using Linux, you can also use [Homebrew](https://brew.sh/) but you should also consider using your package manager. For example:
        - Ubuntu: `sudo apt update && sudo apt install -y lua5.4 liblua5.4-dev`
        - Fedora/RedHat: `sudo dnf update && sudo dnf install lua`
        - Arch Linux: `sudo pacman -Syu && sudo pacman -S lua`

2. Navigate to the folder where EsoHype is located and run this command in a terminal:
`lua esohype.lua` or if that doesn't work, `lua54 esohype.lua`.

3. EsoHype will then ask for a script path. This is where your script is located. It must be located in the same folder or in a descendant folder for EsoHype to find it. Here's an image from Windows that should apply to macOS/Linux:

<img width="1417" height="330" alt="Screenshot 2025-07-17 104934" src="https://github.com/user-attachments/assets/0a1e93e8-caea-4435-a56b-99be0f317882" />

> Note: If your .hyp file is in a descendant folder (a descendant folder where `esohype.exe` is located), for example, the folder `/examples`, then for the script path you would just type `examples/<name>.hyp`, for example: `examples/fibonacci.hyp`.

## Building a Windows Executable for EsoHype
Not comfortable with the executable provided in the repository? No problem!

I won't write a guide for this, but if you want to, you can use [rtc](https://github.com/samyeyo/rtc) as an option (which the EsoHype executable uses).
