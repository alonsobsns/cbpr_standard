#!/bin/bash

VERSION='1.21'
FILEDATE='18-01-2021 09:48'

#mensagem intro
echo "Script de Configuração Geral $VERSION Instador criado em $FILEDATE"

#pause
function pause(){
   read -p "$*"
}

#nome usuario
echo -n 'Informe o Nome do usuario criado na instalação: '
read -r nome_user
if [ -z $nome_user ]
    then
        echo "Você não digitou o Nome do usuário"
        exit 1
fi

#mudança de nomes nos computadores
echo "Digite o nome do computador de acordo com a padronização estabelecida."
echo "Ex: 00CWB03D04 - Mais informações em https://wiki.gga.celepar.parana/wiki/Categoria:CCB"

#pergunta nome do pc
echo -n 'Informe o Nome do PC: '
read -r nome_pc
if [ -z $nome_pc ]
    then
        echo "Você não digitou o Nome do PC!"
    exit 1
fi

#Definir permissoes arquivos
echo "Difinindo Permissoes arquivos"
if 
        chmod +rwx /home/"$nome_user"/Downloads/Padrao_mint_19/geral/skel.tar.gz;
        chmod +rwx /home/"$nome_user"/Downloads/Padrao_mint_19/geral/adobe-flashplugin.deb
    then
        echo “Permissoes definidas com sucesso.”
    else
        echo "Não foi possivel definir as permissoes."
        exit 1
fi

#Repositorio
echo "Baixando repositórios da Celepar.."
if ! wget http://ubuntu.celepar.parana/ubuntu-repositorios.deb
    then
        echo Não foi possível baixar os repositórios da Celepar.
        exit 1
fi
    echo "Adição efetuada com sucesso."

    echo "Instalando repositórios da Celepar.."
if ! dpkg -i ubuntu-repositorios.deb
    then
        echo "Não foi possível extrair os repositórios da Celepar."
        exit 1
fi
    echo "Instalação efetuada com sucesso."

#Update e Upgrade
    echo "Atualizando repositórios.."
if ! apt-get update
    then
        echo "Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/sources.list"
        exit 1
fi
    echo "Atualização feita com sucesso"

    echo "Atualizando pacotes já instalados"
if ! apt-get dist-upgrade -y
    then
        echo Não foi possível atualizar pacotes.
        exit 1
fi
    echo "Atualização de pacotes efetuada com sucesso"

#editar arquivos de nomes dos pcs
echo "Editando os arquivos, hosts e hostname..."
if 
        sed -i "2d" /etc/hosts; sed -i "2s/^/127.0.1.1 $nome_pc\n/" /etc/hosts; sed -i "1d" /etc/hostname; echo "$nome_pc">/etc/hostname
    then
        echo “Edição efetuada com sucesso.”
    else
        echo "Não foi possivel efetuar a edição."
        exit 1
fi

#OCS
echo Instalando Ocs Inventory..
echo Selecione local e pressione enter, em "perdido" escreva o texto "CCB"
pause 'Pressione [Enter] para continuar'
if 
    apt-get install ocs-parana -y
    then
        echo OCS instalado com sucesso.
    else
        echo Erro ao instalar o OCS.
        exit 1   
fi
echo Instalação efetuada com sucesso.

#papel de parede, etc
echo "Configurando Papel de Parede, Mozilla, Configurações e Temas."
if 
    tar -vzxf /home/"$nome_user"/Downloads/Padrao_mint_19/geral/skel.tar.gz -C /etc/skel
    cp /home/"$nome_user"/Downloads/Padrao_mint_19/imagens/bookwood_linuxmint.jpg /usr/share/backgrounds/linuxmint;
    cp /home/"$nome_user"/Downloads/Padrao_mint_19/imagens/sele_linuxmint_center.jpg /usr/share/backgrounds/linuxmint;
    cp /home/"$nome_user"/Downloads/Padrao_mint_19/imagens/brasao_redondo.png /usr/share/icons;
    chmod +rwx /usr/share/icons/brasao_redondo.png
    then
        echo "Configurações efetuadas com sucesso"
    else
        echo "Não foi possivel efetuar a configuração."
        exit 1
fi

#java, flash, Ubuntu-restricted-extras, fonts.
echo "Instalando Programas diversos."
if
    dpkg -i /home/"$nome_user"/Downloads/Padrao_mint_19/geral/adobe-flashplugin.deb;
    apt-get install libavcodec-extra -y;
    apt-get install mint-meta-codecs -y;
    apt-get install oracle-java8-jre -y;
    apt-get install ubuntu-restricted-extras -y;
    apt-get install ttf-mscorefonts-installer -y;
    apt-get install language-pack-pt -y;    
    apt-get install language-pack-gnome-pt -y;
    apt-get install firefox-locale-pt -y;
    apt-get install thunderbird-locale-pt -y;
    apt-get install gimp-help-pt -y
    apt-get install google-chrome-stable -y;
    apt-get install gedit -y;
    apt-get install vlc -y;
    apt-get install okular -y;
    apt-get install conky-all -y;
    apt-get install openssh-server -y;
    apt-get install ntpdate -y;
    apt-get install x11vnc -y;
    apt-get install gnote -y
    then
        echo "Instalação dos efetuadas com sucesso."
    else
        echo "Não foi possivel efetuar a instalação dos programas."
        exit 1
fi    

#configurando NTPDATE
if
    sed -i "10d" /etc/default/ntpdate; sed -i "10s/^/NTPSERVERS="ntp.pr.gov.br"\n/" /etc/default/ntpdate
    then
        echo "Edição do NTPDATE efetuada com sucesso"
    else
        echo "Não foi possivel efetuar a configuração do NTPDATE."
        exit 1
fi

#lista redes ativas

nome_inter=$(ip -br link|awk '$2 ~ /UP/ {print $1}' | grep e)
#nome_wifi=$(ip -br link|awk '$2 ~ /UP/ {print $1}' | grep w)

echo "Copiando conky.conf"
if
        cp /home/"$nome_user"/Downloads/Padrao_mint_19/geral/conky/conky.conf /etc/conky/;
        cp /home/"$nome_user"/Downloads/Padrao_mint_19/geral/conky/conky.conf ~/.conkyrc;
        cp /home/"$nome_user"/Downloads/Padrao_mint_19/geral/conky/conky.desktop /home/"$nome_user"/.config/autostart/;
        chown $nome_user /home/$nome_user/.config/autostart/conky.desktop
    then
        echo “Copia efetuada com sucesso.”
    else
        echo "Não foi possivel copiar conky.conf."
        exit 1
fi

echo "Editando o arquivo conky.conf..."
if 
sed -i "s/rede_local/"$nome_inter"/g" /etc/conky/conky.conf
#sed -i "s/rede_local/"$nome_wifi"/g" /etc/conky/conky.conf
    then
        echo “Edição efetuada com sucesso.”
    else
        echo "Não foi possivel efetuar a edição."
        exit 1
fi

#configurando X11 (acesso remoto)
echo "Instalando e Configurando X11VNC (Acesso Remoto)."
if
        mkdir /etc/x11vnc;
        x11vnc --storepasswd /etc/x11vnc/vncpwd;
        cp /home/"$nome_user"/Downloads/Padrao_mint_19/geral/x11vnc.service /lib/systemd/system/;
        cp /lib/systemd/system/x11vnc.service /etc/systemd/system/;
        sed -i "14d" /lib/systemd/system/graphical.target;
        sed -i "14s/^/Wants=display-manager.service x11vnc.service\n/" /lib/systemd/system/graphical.target;
        cp /lib/systemd/system/graphical.target /etc/systemd/system/
        systemctl daemon-reload;
        systemctl enable x11vnc.service;
        systemctl start x11vnc.service
    then
        echo "Instalação e configuração do X11VNC efetuada com exito."
    else
        echo "Falha na instalação e configuração do X11VNC."
        exit 1
fi

#Update e Upgrade
    echo "Atualizando repositórios.."
if ! apt-get update
    then
        echo "Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/sources.list"
        exit 1
fi
    echo "Atualização feita com sucesso"

    echo "Atualizando pacotes já instalados"
if ! apt-get upgrade -y
    then
        echo Não foi possível atualizar pacotes.
        exit 1
fi
    echo "Atualização de pacotes feita com sucesso"

#reboot
echo "Para completar as configurações o Computador precisa ser reiniciado"
pause 'Pressione [Enter] para reiniciar'
/sbin/reboot
