
# WSL2 Setup

## Mapping Windows network paths to network drives
- Open `Map network drive` by doing a Windows search for the same. This option should be visible under `This PC`.
- Select the `Drive:` that the network path should be mapped to.
- Specify the network path in the `Folder:` field.
- Ensure `Reconnect at sign-in` checkbox is checked.
- Click on `Finish`.
- Open Windows Explorer and confirm the specified network drive appears along with the local drive `C:` under `This PC`.

## Enabling internet connectivity in WSL2
WSL2 may not have internet connectivity by default when a private IP address is assigned (when using VPN, for example).

Steps to get internet connectivity:
- In Windows Command Prompt, run `nslookup google.com`, and note down the DNS server IP address of the form "10.x.x.x".
- In WSL2, add/update the following line in `/etc/resolve.conf` file:
`nameserver 10.x.x.x`
- In WSL2, add the following lines in `etc/wsl.conf` to stop automatic generation of `/etc/resolv.conf` file:
```
[network]
generateResolvConf = false
```
- Confirm internet connectivity in WSL2 by running `ping google.com`.

Internet connectivity should now persist across Windows restarts, but if it does stop working, then follow these steps again.

## [TODO] Sharing Windows environment variables with WSL2
- For Windows executable `7z.exe` for example, invoking it Windows is just `7z`, however, invoking it in WSL2 is `7z.exe`.
- When calling such executables in bash script, it becomes necessary to identify whether the bash script is invoked from Windows or WSL2. To do this, `$WSL_DISTRO_NAME` can be used since it will have a valid value in WSL2, however, it will be empty in Windows.
For example,
```
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "This is WSL"
    EXE_SUFFIX=".exe"
else
    echo "This is not WSL"
    EXE_SUFFIX=""
fi
```

## Projects placement when working with WSL2
Although WSL2 can access Windows directories, the access times are much slower.
[Issue clarification.](https://github.com/microsoft/WSL/issues/4197#issuecomment-604592340)

Commands like `cd`, `ls`, `vim` on Windows directories/files work just fine without any noticeable lag, however, this creates immense lag for commands like `git status` when ran on projects existing in Windows filesystem (since `git status` scans the entire project directory).

To resolve this file access lag, it is better to keep the projects you are working on in WSL2 local directory, `~/Projects/` for example.

## Backing up WSL2 directories to OneDrive
OneDrive cannot directly backup WSL2 directories so we need to create a symlink.

Symlink in Windows is created with `mklink` command in the Command Prompt (as admin).
Syntax: `mklink /d target_directory source_directory`
where `target_directory` is the directory you want to link to, and `source_directory` is the directory you want to link from.

Create symlink in Windows OneDrive folder which links to `~/Projects/` in WSL2.
Replace `~` in `~/Projects` with the output of `wslpath -w ~` (ran in WSL2).

## Mounting Windows network drives in WSL2
Easiest and recommended way to mount a mapped drive is by running `wslact auto-mount`, which is a part of WSL Utilities.

Another way:
- To persistently mount a Windows network drive, `Z:` for example to `/mnt/z/`, append the following line in `/etc/fstab` at the end in WSL2:
```
Z: /mnt/z drvfs defaults 0 0
```
- Then run `sudo mount -a`.
- Run `sudo umount /mnt/z/` to unmount if required.

Note: Access speeds of Windows network drives in WSL2 is slow but is good enough for occasional file transfers.

## What to do if WSL2 hangs
Whenever WSL2 hangs, check the process `Vmmem` in Windows Task Manager to find out how much CPU/memory it is consuming.
- Make sure at least 8 GB of memory is allocated for WSL2 in `.wslconfig` (found at C:\Users\username\). Note: For my usage, I've found 4 GB of memory is usually not sufficient and WSL2 often hangs when it runs out of the memory. 8 GB will be more than sufficient, so if WSL2 hangs, at least it won't be because of the lack of memory.
- WSL2 sometimes hangs (consuming lot of CPU) after waking up from Windows Hibernate. The only way to resolve it is to force restart the WSL2.
- Run the following commands (in order) one by one until the WSL2 `Vmmem` process is killed.
  - `wsl --shutdown`
  - `taskkill /f /im wslservice.exe`
  - `tasklist /svc /fi "imagename eq svchost.exe" | findstr LxssManager
taskkill /f /pid <PID>`
  - 
```
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux
Reboot
```

## What to do if tmux restore session doesn't work
- Outside tmux, go to `~/.local/share/tmux/resurrect`
- Check for the latest non-empty restore txt file and copy its file name.
- Run `ln -sf $LATEST_NON_EMPTY_FILE last` to update `last` to the latest non-empty file.
- Launch tmux and restore the session normally.

[Reference](https://github.com/tmux-plugins/tmux-resurrect/issues/122)

## WSL Utilities
[What it is](https://wslutiliti.es/wslu/)

Install with `sudo apt install wslu -y` or refer [installation steps on wiki page](https://wslutiliti.es/wslu/install.html) to install the latest version.

Also do `ln -s /usr/bin/wslview $HOME/.local/bin/wv` to allow running `wslview` as `wv` in other programs (like Neovim).

- Register web browser to open links from WSL with `wslview -r $(wslpath -au 'C:\Program Files\Mozilla Firefox\firefox.exe')`.
- Open directories in Windows File Explorer with `wslview <abosolute or relative dir path>`.
- Open files in default Windows programs with `wslview <file>`.
- Print all folder environment variables with `wslvar --getshell`.
- Print specific folder environment variable with `wslvar --shell`.
- Print all system environment variables with `wslvar --getsys`.
- Print specific system environment variable with `wslvar --sys`.
- Get essential WSL specs with `wslsys`.
- For auto mounting use `wslact auto-mount`.
- Not a part of WSL Utilities, but `wslpath` can convert WSL path to Windows path and vice versa.
- There are other command options and sub-utilities which seems less useful so they aren't covered here.

[Related python library](https://github.com/wslutilities/wslpy)

## GitHub Copilot Setup in Neovim
1. First, we'll need to install the relevant Windows certificate in WSL.
     - Step 1:
       Windows Menu -> Manage User Certificates -> Trusted Root Certification Authorities -> Certificates -> Relevant Certificate (double click) -> Details tab -> Copy to File -> Base-64 encoded X.509 (.CER) format -> select path in WSL and save.

     - Step 2:
       Open WSL -> go to the path where certificate is saved -> 
       - `openssl x509 -inform PEM -in <sorcefile.cer> -out <sorcefile.crt>`
       - `sudo cp <sourcefile.crt> /usr/local/share/ca-certificates/`
       - `cd /usr/local/share/ca-certificates/`
       - `sudo chmod 755 <sourcefile.crt>`
       - `sudo update-ca-certificates`

     - References:
       - https://phumipatc.medium.com/how-to-convert-certificate-file-from-windows-to-linux-and-how-to-import-certificate-file-on-linux-4ae78a9740e2
       - https://github.com/bayaro/windows-certs-2-wsl

2. Enable Copilot plugin in Neovim.
   In `lua/user/copilot.lua` -> set `enabled = true`.

3. Export the CA certificate to .bashrc or .zshrc. (This is already added in dotfiles/zsh/.config/zsh/zsh-exports.)
`export NODE_EXTRA_CA_CERTS="/usr/local/share/ca-certificates/<sourcefile.crt>"`
   References:
   - https://sidd.io/2023/01/github-copilot-self-signed-cert-issue/

1. In Neovim, perform `:Copilot setup`.
	
2. Verify Copilot is running with `:Copilot status`.