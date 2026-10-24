#!/usr/bin/env bash

# Encerrar o script se algum comando falhar
set -e

# Cores para o terminal
VERDE='\033[0;32m'
AZUL='\033[0;34m'
SEM_COR='\033[0m'

echo -e "${AZUL}====== Iniciando a instalação do Rice (vlestatgit) ======${SEM_COR}"

# 1. Atualizar o sistema
echo -e "\n${AZUL}[1/5] Atualizando repositórios e o CachyOS...${SEM_COR}"
sudo pacman -Syu --noconfirm

# 2. Instalar pacotes via repositório oficial (Pacman)
PACOTES_PACMAN=(
    "brightnessctl"
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "hyprshot"
    "kitty"
    "nautilus"
    "nwg-look"
    "power-profiles-daemon"
    "rofi"
    "sddm"
    "ttf-jetbrains-mono-nerd"
    "waybar"
    "git"
)

echo -e "\n${AZUL}[2/5] Instalando pacotes principais do sistema...${SEM_COR}"
sudo pacman -S --needed --noconfirm "${PACOTES_PACMAN[@]}"

# 3. Instalar pacotes específicos do AUR usando o Paru
PACOTES_AUR=(
    "catppuccin-gtk-theme-mocha"
    "snappy-switcher"
    "yaru-icon-theme"
)

echo -e "\n${AZUL}[3/5] Instalando temas e pacotes do AUR...${SEM_COR}"
paru -S --needed --noconfirm "${PACOTES_AUR[@]}"

# 4. Sincronizar o Repositório diretamente na ~/.config
CONFIG_DIR="$HOME/.config"

echo -e "\n${AZUL}[4/5] Configurando a pasta ~/.config com o GitHub...${SEM_COR}"

# Se a pasta .config já existir, faz um backup seguro antes para não perder nada
if [ -d "$CONFIG_DIR" ] && [ ! -d "$CONFIG_DIR/.git" ]; then
    echo "Fazendo backup da .config existente para .config.backup..."
    mv "$CONFIG_DIR" "${CONFIG_DIR}.backup"
fi

# Clona o repositório diretamente como a sua pasta .config
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Clonando vlestatgit/dotfiles direto em ~/.config..."
    git clone https://github.com "$CONFIG_DIR"
fi

# 5. Mover arquivos da raiz para os lugares corretos
echo -e "\n${AZUL}[5/5] Ajustando arquivos do sistema...${SEM_COR}"

# Ajusta o user-dirs se ele foi baixado para dentro da .config
if [ -f "$CONFIG_DIR/user-dirs.dirs" ] && [ ! -f "$HOME/.config/user-dirs.dirs" ]; then
    cp "$CONFIG_DIR/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
fi

# Ativar o daemon de energia padrão do seu setup
echo "Ativando serviços essenciais..."
sudo systemctl enable --now power-profiles-daemon.service

echo -e "\n${VERDE}====== Instalação concluída! Seu VS Code já está pronto para abrir a ~/.config ======${SEM_COR}"
