# Changelog Evoluído V2

## Adicionado

- `plank-rofi-manager`, gerenciador gráfico via Rofi.
- Menu para configurar tema, posição, tamanho, zoom, hide mode, gap, offset, delays e flags comportamentais.
- Perfis rápidos: Cyberpunk pesado, Matrix terminal, Glass minimal, Openbox leve e Plasma neon.
- Geração de perfil Picom em `~/.config/picom/plank-reloaded.conf`.
- Inicialização/restart/stop do Picom pelo gerenciador.
- Integração Openbox com bloco de autostart e snippet de menu.
- Desktop launcher `net.launchpad.plank.manager.desktop`.
- Novos parâmetros de tema para sweep holográfico, grid overlay, corner accents, hover ring, hover lift e active halo.
- Três novos temas: `MatrixCore`, `PlasmaCircuit`, `DarkMatter`.

## Melhorado

- `CyberNeon`, `Synthwave` e `QuantumGlass` agora usam as novas animações de background e item.
- Lista de temas instalada pelo Meson foi atualizada.
- Schema descreve os novos temas embutidos.
- Pacote Debian sugere `rofi`, `picom` e `openbox`.
