PRIMEIRO PASSOS:

Execute os comandos para atualizar os pacotes do sistema. 

```
sudo apt update
```

```
sudo apt upgrade -y
```

PROXIMO COMANDO:

```bash
sudo apt install -y git && git clone https://github.com/plwdesign/instaladorwhatsapsaas-main-new && sudo chmod -R 777 instaladorwhatsapsaas-main-new && cd instaladorwhatsapsaas-main-new && sudo ./install_primaria
```

ACESSANDO DIRETORIO DO INSTALADOR & INICIANDO INSTALAÇÕES ADICIONAIS (USAR ESTE COMANDO PARA SEGUNDA OU MAIS INSTALAÇÃO:
```bash
cd ./instaladorwhatsapsaas-main-new && sudo ./install_instancia
```


