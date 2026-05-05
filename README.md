# Atualizacao automatica no Fedora 44 (timer 15s apos sessao)

Este projeto atualiza o sistema automaticamente 15 segundos apos o inicio da sessao do usuario, sem acoplamento direto com unit de autostart de login.

## Resumo rapido

Em conjunto:

- `atualiza-sistema.sh` executa `dnf upgrade --refresh -y` e `flatpak update -y`.
- `atualiza-sistema.service` roda o script como root com prioridade reduzida de CPU/IO.
- `atualiza-no-login.timer` agenda a execucao para 15 segundos apos iniciar a sessao.
- `atualiza-no-login.service` e acionado pelo timer e executa o script de usuario.
- `atualiza-no-login.sh` envia notificacao no inicio e no fim (sucesso/erro) e dispara o service root.

## Arquivos deste diretorio

- `atualiza-sistema.sh`: script de atualizacao.
- `atualiza-sistema.service`: unit de sistema (root).
- `atualiza-no-login.timer`: timer de usuario com `OnStartupSec=15s`.
- `atualiza-no-login.service`: unit de usuario acionada pelo timer.
- `atualiza-no-login.sh`: script de usuario com notificacoes.

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

### 3) Instalar script, service e timer de usuario

```bash
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user

cp atualiza-no-login.sh ~/.local/bin/atualiza-no-login.sh
chmod +x ~/.local/bin/atualiza-no-login.sh

cp atualiza-no-login.service ~/.config/systemd/user/atualiza-no-login.service
cp atualiza-no-login.timer ~/.config/systemd/user/atualiza-no-login.timer

systemctl --user daemon-reload
systemctl --user disable --now atualiza-no-login.service 2>/dev/null || true
systemctl --user enable --now atualiza-no-login.timer
```

## Teste manual

### Testar somente o update root

```bash
sudo systemctl start --wait atualiza-sistema.service
```

### Testar fluxo completo por timer (15s apos sessao)

```bash
systemctl --user start atualiza-no-login.timer
```

O timer agenda a execucao 15 segundos apos iniciar a sessao.

## Ver logs

Logs do update root:

```bash
journalctl -u atualiza-sistema.service -b --no-pager
```

Logs do service de login:

```bash
journalctl --user -u atualiza-no-login.service -b --no-pager
```

Logs do timer:

```bash
journalctl --user -u atualiza-no-login.timer -b --no-pager
systemctl --user list-timers | rg atualiza-no-login
```

## Troubleshooting

- Notificacao nao aparece: confirme que o pacote `libnotify`/`notify-send` esta instalado.
- Pede senha ao logar: revisar a entrada do arquivo `/etc/sudoers.d/atualiza-login`.
- Falha de rede: verifique a conectividade e rode novamente pelo teste manual.
- Timer nao dispara: rode `systemctl --user daemon-reload` e confirme `atualiza-no-login.timer` habilitado.

## Rollback

Remover fluxo de login com notificacao:

```bash
systemctl --user disable --now atualiza-no-login.timer
systemctl --user disable --now atualiza-no-login.service 2>/dev/null || true
rm -f ~/.config/systemd/user/atualiza-no-login.timer
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

