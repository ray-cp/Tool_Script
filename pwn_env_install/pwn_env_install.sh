#!/bin/sh
# Date: 2019-04-10
# Author: raycp
# Description: pwn environment install script for ubuntu
# Fiel: pwn_env_install.sh

# update source list
## backup the sources.list
echo "updating apt source"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo chmod 666 /etc/apt/sources.list
## update
echo deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse > /etc/apt/sources.list
echo deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse >> /etc/apt/sources.list
echo deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse >> /etc/apt/sources.list
echo deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse >> /etc/apt/sources.list
## restore 
sudo chmod 660 /etc/apt/sources.list
## update
sudo apt-get update -y

# install curl  
echo "install curl"
sudo apt install curl -y

# install pip
echo "install python-pip"
sudo apt install python-pip -y

#install vim
echo "install vim"
sudo apt-get install vim -y
echo "custom configure vim"
cp vimrc ~/.vimrc

#install tmux
echo "install tmux"
sudo apt-get install tmux -y
echo "custom configure tmux"
cp tmux.conf ~/.tmux.conf

# install git
echo "install git"
sudo apt-get install git -y

# install ssh
echo "install ssh server"
sudo apt-get install openssh-server -y

# some lib
echo "install lib:"
echo "\tbiscon"
sudo apt-get install bison -y
echo "\tgawk"
sudo apt-get install gawk -y
echo "\tgcc-multilib"
sudo apt-get install gcc-multilib -y
echo "\tg++-multilib"
sudo apt-get install g++-multilib -y

# install patchelf
echo "install patchelf"
sudo apt-get install patchelf -y

# install pwntools
echo "install pwntools"
pip install pwntools

# make dir ~/work/soft to install soft
mkdir -p ~/work/soft

# install pwndbg
echo "install pwndbg"
if [ ! -d "$HOME/work/soft/pwndbg" ]; then
  git clone https://github.com/pwndbg/pwndbg.git ~/work/soft/pwndbg
  (cd ~/work/soft/pwndbg && ./setup.sh) 
else
  echo "[*] ~/work/soft/pwndbg exists..."
fi

# install peda
echo "install peda"
if [ ! -d "$HOME/work/soft/peda" ]; then
  git clone https://github.com/longld/peda.git ~/work/soft/peda
  echo "#source ~/work/soft/peda/peda.py" >> ~/.gdbinit
else
  echo "[*] ~/work/soft/peda exists..."
fi

# install pwn_debug
echo "install pwn_debug"
if [ ! -d "$HOME/work/soft/pwn_debug" ]; then
  git clone https://github.com/ray-cp/pwn_debug.git ~/work/soft/pwn_debug
  (cd ~/work/soft/pwn_debug && sudo python setup.py install)
else
  echo "[*] ~/work/soft/pwn_debug exists..."
fi

# install zsh
echo "install zsh"
sudo apt-get install zsh -y
## need to exit manually
echo "[!] ENTER exit manually!"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
bash_aliases=$(cat ~/.zshrc | grep "~/.bash_aliases")
if [ -z "$bash_aliases" ];then
  echo "[*] add ~/.bash_aliases in ~/.zshrc"
cat <<EOF  >>~/.zshrc
## add ~/.bash_aliases 
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
else
  echo "[*] ~/.bash_aliases exists in ~/.zshrc"
fi
## use dircolors
echo "[*] add ~/.dircolors in ~/.zshrc"
dircolors -p > ~/.dircolors
cat <<EOF  >>~/.zshrc
## enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
EOF
## install zsh-autosuggestions
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
  git clone git://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc 
else
  echo "[*] ~/.zsh/zsh-autosuggestions exists..."
fi
## install zsh-syntax-highlighting
if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
  echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
else
  echo "[*] ~/.zsh/zsh-syntax-highlighting exists...."
fi

sudo apt-get install autojump -y
if [ `grep -c ". /usr/share/autojump/autojump.sh" ~/.zshrc` -eq '0' ]; then

    echo "autojump has been installed"
else
    echo . /usr/share/autojump/autojump.sh >> ~/.zshrc
fi



sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"ys\"/g" ~/.zshrc
# change zsh to default shell
sudo chsh -s /bin/zsh
echo "[*] ENJOY!"
echo "if you wanna install glibc with debug symbols go to ~/work/soft/pwn_debug and execute '/build.sh'"
/bin/zsh
