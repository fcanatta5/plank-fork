# Plank Reloaded Evoluído V2

Esta versão parte do bundle evoluído anterior e adiciona uma segunda camada de evolução voltada para uso real em ambientes X11, especialmente Openbox com Picom.

## Principais melhorias

### 1. Gerenciador gráfico com Rofi

Novo comando instalado:

```bash
plank-rofi-manager
```

Ele permite configurar visualmente, via Rofi:

- tema do dock;
- tamanho dos ícones;
- zoom e percentual de zoom;
- posição: bottom, top, left, right;
- alinhamento do dock e dos itens;
- modo de ocultação;
- gap, offset, hide-delay e unhide-delay;
- opções de comportamento como pinned-only, lock-items, tooltips, pressure-reveal e active-display;
- perfis rápidos futuristas;
- integração Picom;
- integração Openbox;
- restart do Plank;
- status atual do dock.

Atalhos úteis:

```bash
plank-rofi-manager --write-picom
plank-rofi-manager --start-picom
plank-rofi-manager --openbox-autostart
plank-rofi-manager --restart-plank
```

### 2. Suporte a Picom

O gerenciador cria um perfil dedicado em:

```bash
~/.config/picom/plank-reloaded.conf
```

Esse perfil inclui:

- backend GLX;
- vsync;
- fading;
- blur de fundo;
- regras de opacidade para janelas Plank;
- exclusões de sombra para tipo `dock`;
- regras compatíveis com setups Openbox/X11.

Para iniciar:

```bash
plank-rofi-manager --start-picom
```

### 3. Suporte a Openbox

O gerenciador pode criar/atualizar:

```bash
~/.config/openbox/autostart
~/.config/openbox/plank-reloaded-menu.xml
```

O bloco de autostart criado inicia Picom com o perfil do Plank e inicia o Plank se ele ainda não estiver rodando.

### 4. Novo motor visual/animado

Além das melhorias anteriores, o motor de tema agora entende novos parâmetros:

#### Fundo do dock

- `BackgroundPulseEnabled`
- `BackgroundPulseColor`
- `BackgroundPulseTime`
- `BackgroundPulseStrength`
- `GridOverlayColor`
- `GridOverlaySize`
- `GridOverlaySpacing`
- `CornerAccentColor`
- `CornerAccentSize`

Esses parâmetros adicionam sweep holográfico animado, grid/circuit overlay e acentos angulares nos cantos.

#### Itens do dock

- `HoverRingEnabled`
- `HoverRingColor`
- `HoverRingWidth`
- `HoverRingPulseTime`
- `HoverLiftEnabled`
- `HoverLiftAmount`
- `ActiveHaloEnabled`
- `ActiveHaloColor`
- `ActiveHaloWidth`

Esses parâmetros adicionam anel neon animado em hover, lift do ícone ao passar o mouse e halo em apps ativos.

### 5. Três novos temas futuristas completos

Foram adicionados:

- `MatrixCore` — terminal verde hacker com grid e scanlines.
- `PlasmaCircuit` — plasma violeta/azul com circuit-grid e hover agressivo.
- `DarkMatter` — vidro escuro minimalista para Openbox/Picom.

Os temas anteriores também foram atualizados para usar as novas animações.

## Compilação

```bash
sudo apt update
sudo apt install meson valac gettext libgtk-3-dev libgee-0.8-dev libbamf3-dev libwnck-3-dev libgnome-menu-3-dev libxml2-utils bamfdaemon rofi picom openbox

meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

## Ativar tema manualmente

```bash
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'MatrixCore'
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'PlasmaCircuit'
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'DarkMatter'
```

## Abrir o gerenciador

```bash
plank-rofi-manager
```
