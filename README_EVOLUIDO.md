# Plank Reloaded — edição evoluída futurista

## Análise do pacote original

O pacote anexado é um fork do Plank escrito em Vala/GTK 3 e compilado com Meson. A renderização do dock fica concentrada em `lib/DockRenderer.vala`, a leitura dos temas fica em `lib/Services/Preferences.vala`, os parâmetros visuais de dock ficam em `lib/Drawing/DockTheme.vala` e os temas instaláveis ficam em `data/themes/*/dock.theme`.

A arquitetura original já separava bem três camadas:

1. **Configuração do dock**: `DockPreferences` via GSettings.
2. **Motor de desenho**: `Theme`, `DockTheme` e `DockRenderer` usando Cairo.
3. **Temas**: arquivos `dock.theme`, instalados pelo `data/meson.build`.

## Correções implementadas

- Corrigida a validação de `ActiveItemColor` e `ActiveItemStyle` em `DockTheme.verify()`. O código original validava nomes antigos/inexistentes (`ActiveColor` e `ActiveStyle`), então a sanitização dessas opções podia não acontecer corretamente.
- Adicionada limpeza do handler `gtk-theme-name` no destrutor de `DockRenderer`, evitando callback preso quando o tema `Gtk+` fosse usado/recarregado.
- Atualizados os seis temas originais com os novos campos em modo neutro/desligado, evitando avisos de chave ausente ao carregar temas antigos.
- Atualizado `data/meson.build` para instalar também os três novos temas.

## Melhorias no motor visual

### Fundo futurista por tema

`lib/Drawing/Theme.vala` agora aceita novos parâmetros:

- `GlassHighlightColor`
- `AccentLineColor`
- `GlowStrokeColor`
- `ScanlineColor`
- `ScanlineSize`
- `ScanlineSpacing`
- `GlowStrength`

Com isso, temas podem desenhar vidro translúcido, brilho externo, linha neon e scanlines diretamente pelo motor Cairo, sem precisar de imagens externas.

### Animações novas

`lib/Drawing/DockTheme.vala` e `lib/DockRenderer.vala` agora aceitam:

- `HoverGlowEnabled`
- `HoverGlowColor`
- `HoverGlowSize`
- `HoverGlowStrength`
- `HoverGlowPulseTime`
- `ActivePulseEnabled`
- `ActivePulseTime`
- `ActivePulseStrength`

Isso adiciona halo pulsante no item sob o mouse e “respiração” visual no item ativo.

### Barra de progresso neon

A barra de progresso ganhou controle por tema:

- `ProgressColor`
- `ProgressBackgroundColor`
- `ProgressGlowEnabled`
- `ProgressGlowStrength`

Os temas futuristas usam isso para desenhar progresso com brilho neon.

## Novos temas completos

### CyberNeon

Tema cyberpunk pesado: vidro escuro, cyan/magenta, scanlines fortes, hover glow rápido, active pulse, indicador underline neon e badge magenta.

### Synthwave

Tema retro-futurista: roxo, magenta e laranja, brilho quente, badges sólidos e animações suaves.

### QuantumGlass

Tema sci-fi limpo: vidro translúcido, azul gelo, scanlines sutis, hover glow discreto e progress bar cyan.

## Como compilar e instalar

Em Ubuntu/Mint/Debian, instale as dependências de desenvolvimento:

```bash
sudo apt update
sudo apt install meson valac gettext libgtk-3-dev libgee-0.8-dev libbamf3-dev libwnck-3-dev libgnome-menu-3-dev libxml2-utils bamfdaemon
```

Compile e instale:

```bash
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

Depois reinicie o Plank Reloaded.

## Como ativar os temas

Pela interface:

```text
Preferences → Appearance → Theme
```

Ou via terminal, trocando o nome do tema:

```bash
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'CyberNeon'
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'Synthwave'
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'QuantumGlass'
```

## Observação de validação

O código foi preparado e empacotado como fonte completa. Neste ambiente não havia `meson`, `valac` nem as bibliotecas GTK/BAMF/WNCK de desenvolvimento disponíveis, então a compilação final precisa ser validada na sua máquina Linux com as dependências acima.

---

## Evolução V2 adicional

Esta árvore também inclui `README_EVOLUIDO_V2.md`, `CHANGELOG_EVOLUIDO_V2.md`, o gerenciador `plank-rofi-manager`, integração Picom/Openbox, novas animações de fundo/hover/ativo e os temas `MatrixCore`, `PlasmaCircuit` e `DarkMatter`.
