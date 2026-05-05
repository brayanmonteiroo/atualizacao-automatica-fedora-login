# Atualizacao automatica no Fedora 44 (somente boot)

Este projeto roda atualizacoes automaticamente no boot:

- Rodar `dnf upgrade --refresh -y`
- Rodar `flatpak update -y`
- No evento de boot

## Resumo rapido

Este projeto automatiza a manutencao do sistema no inicio de cada sessao do Fedora.
Em conjunto:

- `atualiza-sistema.sh` executa as atualizacoes de pacotes RPM (`dnf`) e de apps Flatpak.
- `atualiza-no-boot.service` chama esse script uma vez a cada inicializacao, apos a rede ficar disponivel.
- O resultado aparece no `journalctl`, facilitando auditoria e diagnostico.

## Arquivos deste diretorio

- `atualiza-sistema.sh`: script com os comandos de atualizacao.
- `atualiza-no-boot.service`: service do systemd para rodar no boot.

## Instalacao

No diretorio do projeto, execute:

```bash
chmod +x atualiza-sistema.sh
sudo cp atualiza-sistema.sh /usr/local/bin/atualiza-sistema.sh
sudo chmod +x /usr/local/bin/atualiza-sistema.sh

sudo cp atualiza-no-boot.service /etc/systemd/system/atualiza-no-boot.service

sudo systemctl daemon-reload
sudo systemctl enable atualiza-no-boot.service
```

## Teste manual

```bash
sudo systemctl start atualiza-no-boot.service
```

## Ver logs

Boot atual:

```bash
journalctl -u atualiza-no-boot.service -b
```

## Como funciona

- No boot: `atualiza-no-boot.service` e acionado quando o sistema entra em `multi-user.target` e a rede esta online.

## Observacoes importantes

- O boot pode ficar mais lento dependendo da quantidade de atualizacoes.
- O service roda como root, por isso o script usa os comandos sem `sudo`.

## Removendo o service antigo de shutdown/reboot (se ja estiver ativo)

Se voce ativou a versao anterior com shutdown/reboot, execute:

```bash
sudo systemctl disable --now atualiza-no-shutdown.service
sudo rm -f /etc/systemd/system/atualiza-no-shutdown.service
sudo systemctl daemon-reload
```
