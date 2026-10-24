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
    "fastfetch"
    "btop"
)

echo -e "\n${AZUL}[2/5] Instalando pacotes principais do sistema...${SEM_COR}"
sudo pacman -S --needed --noconfirm "${PACOTES_PACMAN[@]}"

# 3. Instalar pacotes específicos do AUR usando o Yay
PACOTES_AUR=(
    "catppuccin-gtk-theme-mocha"
    "snappy-switcher"
    "yaru-icon-theme"
)

echo -e "\n${AZUL}[3/5] Instalando temas e pacotes do AUR com o Yay...${SEM_COR}"
yay -S --needed --noconfirm "${PACOTES_AUR[@]}"

# 4. Clonar e sincronizar os Dotfiles de forma isolada e segura
REPOS_DIR="$HOME/dotfiles-repo"
CONFIG_DIR="$HOME/.config"

echo -e "\n${AZUL}[4/5] Baixando dotfiles do GitHub...${SEM_COR}"

# Remove o diretório temporário se ele já existir para garantir um clone limpo
rm -rf "$REPOS_DIR"
git clone https://github.com "$REPOS_DIR"

# Garante que a pasta ~/.config exista antes de copiar as subpastas
mkdir -p "$CONFIG_DIR"

echo "Aplicando as configurações em ~/.config..."
# Lista exata das pastas de ferramentas mapeadas do seu repositório para a .config
PASTAS_CONFIG=("btop" "fastfetch" "hypr" "hyprpaper" "kitty" "nwg-look" "rofi" "snappy-switcher" "waybar" "xsettingsd")

for pasta in "${PASTAS_CONFIG[@]}"; do
    if [ -d "$REPOS_DIR/$pasta" ]; then
        # Se já existir a pasta na .config, faz um backup local seguro (.bak)
        if [ -d "$CONFIG_DIR/$pasta" ]; then
            echo "Fazendo backup de $CONFIG_DIR/$pasta para $CONFIG_DIR/${pasta}.bak"
            rm -rf "${CONFIG_DIR}/${pasta}.bak"
            mv "$CONFIG_DIR/$pasta" "$CONFIG_DIR/${pasta}.bak"
        fi
        cp -r "$REPOS_DIR/$pasta" "$CONFIG_DIR/"
    fi
done

# 5. Ajustar arquivos extras de ambiente e serviços
echo -e "\n${AZUL}[5/5] Ajustando arquivos do sistema...${SEM_COR}"

# Sincroniza o user-dirs.dirs para a raiz da .config se ele estiver no repositório
if [ -f "$REPOS_DIR/user-dirs.dirs" ]; then
    cp "$REPOS_DIR/user-dirs.dirs" "$CONFIG_DIR/user-dirs.dirs"
fi

# Ativar o daemon de gerenciamento de energia do sistema
echo "Ativando serviços essenciais..."
sudo systemctl enable --now power-profiles-daemon.service

# Limpeza completa da pasta temporária clonada
rm -rf "$REPOS_DIR"

echo -e "\n${VERDE}====== Instalação concluída com sucesso! Setup aplicado. ======${SEM_COR}"
