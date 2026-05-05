# Atualizacao automatica no Fedora 44 (apos login com notificacao)

Este projeto atualiza o sistema logo apos voce entrar no desktop. Essa atualização é feita em background, sem interromper a sessão.

## Resumo rapido

Em conjunto:

- `atualiza-sistema.sh` executa `dnf upgrade --refresh -y` e `flatpak update -y`.
- `atualiza-sistema.service` roda o script como root quando disparado.
- `atualiza-no-login.sh` envia notificacao de inicio/fim e chama o service root.
- `atualiza-no-login.service` roda no login da sessao grafica.

## Arquivos deste diretorio

- `atualiza-sistema.sh`: script de atualizacao.
- `atualiza-sistema.service`: unit de sistema (root).
- `atualiza-no-login.sh`: script de usuario com notificacoes.
- `atualiza-no-login.service`: unit de usuario para rodar no login.

## Instalacao

### 1) Instalar script e service root

No diretorio do projeto, execute:

```bash
chmod +x atualiza-sistema.sh
sudo cp atualiza-sistema.sh /usr/local/bin/atualiza-sistema.sh
sudo chmod +x /usr/local/bin/atualiza-sistema.sh

sudo cp atualiza-sistema.service /etc/systemd/system/atualiza-sistema.service
sudo systemctl daemon-reload
```

### 2) Configurar sudoers minimo (sem senha para 1 comando)

Abra com:

```bash
sudo visudo -f /etc/sudoers.d/atualiza-login
```

Adicione exatamente esta linha:

```text
brayan ALL=(root) NOPASSWD: /usr/bin/systemctl start --wait atualiza-sistema.service
```

Troque `brayan` pelo seu usuario, se necessario.

### 3) Instalar script e service de usuario (login)

```bash
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user

cp atualiza-no-login.sh ~/.local/bin/atualiza-no-login.sh
chmod +x ~/.local/bin/atualiza-no-login.sh

cp atualiza-no-login.service ~/.config/systemd/user/atualiza-no-login.service

systemctl --user daemon-reload
systemctl --user enable atualiza-no-login.service
```

## Teste manual

### Testar somente o update root

```bash
sudo systemctl start --wait atualiza-sistema.service
```

### Testar fluxo completo de login (notificacao + update)

```bash
systemctl --user start atualiza-no-login.service
```

## Ver logs

Logs do update root:

```bash
journalctl -u atualiza-sistema.service -b --no-pager
```

Logs do service de login:

```bash
journalctl --user -u atualiza-no-login.service -b --no-pager
```

## Troubleshooting

- Notificacao nao aparece: confirme que o pacote `libnotify`/`notify-send` esta instalado.
- Pede senha ao logar: revisar a entrada do arquivo `/etc/sudoers.d/atualiza-login`.
- Falha de rede: verifique a conectividade e rode novamente pelo teste manual.

## Rollback

Remover fluxo de login com notificacao:

```bash
systemctl --user disable --now atualiza-no-login.service
rm -f ~/.config/systemd/user/atualiza-no-login.service
rm -f ~/.local/bin/atualiza-no-login.sh
systemctl --user daemon-reload
```

Remover fluxo root:

```bash
sudo systemctl disable --now atualiza-sistema.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/atualiza-sistema.service
sudo rm -f /usr/local/bin/atualiza-sistema.sh
sudo rm -f /etc/sudoers.d/atualiza-login
sudo systemctl daemon-reload
```

