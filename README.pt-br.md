# PudimBasicsGl - Pudim Basics OpenGL 

Uma biblioteca 2D mínima para Lua usando OpenGL. O PudimBasicsGl foca no essencial: **gestão de janelas**, **renderização 2D**, **texturas**, **input**, **áudio**, **texto**, **tempo** e **câmera**.

> [!WARNING]
> Este projeto está em estado *experimental*. APIs e funcionalidades podem mudar sem aviso — use com cautela.

## Recursos

- **Janela**: Criação e gerenciamento de janelas OpenGL com VSync, fullscreen e suporte a redimensionamento
- **Renderer**: Desenho de primitivas 2D (pontos, linhas, retângulos, círculos, triângulos)
- **Texturas**: Carregamento de imagens (PNG, JPG, BMP, etc.) e renderização com rotação, tint e suporte a sprites
- **Input**: Entrada de teclado e mouse (estado de teclas, posição do mouse, controle de cursor)
- **Áudio**: Carregamento e reprodução de áudio (WAV, MP3, FLAC) com volume, pitch e looping via [miniaudio](https://github.com/mackron/miniaudio)
- **Texto**: Carregamento de fontes TrueType (.ttf) e renderização de texto com tamanho, cor e medição personalizáveis via [stb_truetype](https://github.com/nothings/stb)
- **Tempo**: Delta time, FPS e utilitários de tempo
- **Câmera**: Controles de câmera 2D (posição, zoom, rotação, look_at e conversão tela/mundo)

## Compilação

A forma recomendada de instalar é via LuaRocks (veja abaixo). Para desenvolvimento local:

```bash
make
```

Isso cria `PudimBasicsGl.so`, um módulo Lua que você pode carregar com `require("PudimBasicsGl")`.

> Nota: em versões antigas era necessário iniciar o intérprete com `LD_PRELOAD=/usr/lib/libglfw.so.3 ./lua init.lua`. A biblioteca agora tenta carregar o `libglfw` automaticamente em tempo de execução quando disponível, então isso não deve ser mais necessário. Se houver problemas em ambientes específicos, consulte a seção de troubleshooting abaixo.

## Suporte LSP

As definições LSP (arquivo `PudimBasicsGl.lua`) agora são instaladas automaticamente com o pacote e o módulo tenta carregá-las quando disponíveis — isso permite que editores com `lua-language-server` mostrem autocompletar e tipos sem configuração adicional. Se preferir usar localmente no workspace, adicione `library/` ao caminho da `lua-language-server`:

```json
// .vscode/settings.json
{
    "Lua.workspace.library": ["./library"]
}
```

Ou copie `library/PudimBasicsGl.lua` para a pasta de addons global do `lua-language-server`.

## Instalação via LuaRocks

```bash
luarocks install pudimbasicsgl
```

Ou compile a partir do rockspec local:

```bash
luarocks make pudimbasicsgl-1.0.0-15.rockspec
```

O rockspec usa o build type `builtin` — o LuaRocks compila todos os `.c` diretamente em `.so` (Linux) ou `.dll` (Windows), sem precisar do makefile. O comando `make` só é necessário para desenvolvimento local.

## Uso

```lua
local pb = require("PudimBasicsGl")

-- Cria uma janela
local window = pb.window.create(800, 600, "My App")
pb.renderer.init()

-- Carrega uma textura (opcional)
local texture = pb.texture.load("sprite.png")

-- Loop principal (você controla!)
while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()
    
    -- Sua lógica de jogo aqui
    
    -- Pega o tamanho atual da janela (lida com resize)
    local w, h = pb.window.get_size(window)
    
    -- Render
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(w, h)
    
    -- Desenha primitivas
    pb.renderer.rect_filled(100, 100, 50, 50, pb.renderer.colors.RED)
    pb.renderer.circle_filled(400, 300, 30, {r=0, g=1, b=0.5, a=1})
    pb.renderer.flush()  -- Flush de primitivas antes de texturas
    
    -- Desenha texturas
    if texture then
        texture:draw(200, 200)  -- Desenho simples
        texture:draw_rotated(400, 400, 64, 64, 45)  -- Rotacionado 45 graus
    end
    pb.texture.flush()
    
    pb.renderer.finish()
    
    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

if texture then texture:destroy() end
pb.window.destroy(window)
```

### Exemplo de Input

```lua
-- Teclado
if pb.input.is_key_pressed(pb.input.KEY_W) then
    player.y = player.y - speed * dt
end
if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
    break
end

-- Mouse
local mx, my = pb.input.get_mouse_position()
if pb.input.is_mouse_button_pressed(pb.input.MOUSE_LEFT) then
    -- trata clique
end
```

### Exemplo de Áudio

```lua
local music = pb.audio.load("music.mp3")
music:set_looping(true)
music:set_volume(0.8)
music:play()

-- Depois...
music:pause()
music:resume()
music:stop()
music:destroy()

pb.audio.set_master_volume(0.5)
pb.audio.shutdown()
```

### Exemplo de Texto

```lua
-- Carrega uma fonte TrueType a 32px
local font = pb.text.load("minha_fonte.ttf", 32)

-- Desenha texto (flush primitivas antes, shader diferente)
pb.renderer.flush()
font:draw("Olá, Mundo!", 100, 100, 1, 1, 1) -- texto branco
font:draw("Colorido!", 100, 150, {r=1, g=0.5, b=0, a=1}) -- texto laranja

-- Mede dimensões do texto
local w, h = font:measure("Olá, Mundo!")

-- Altera tamanho da fonte dinamicamente
font:set_size(48)

-- Flush texto antes de desenhar primitivas novamente
pb.text.flush()

-- Limpeza
font:destroy()
```

## Referência de API

### pb.window

| Função | Descrição |
|--------|-----------|
| `create(width, height, title)` | Cria uma janela, retorna handle da janela |
| `destroy(window)` | Destroi a janela e libera recursos |
| `should_close(window)` | Verifica se a janela deve fechar |
| `close(window)` | Sinaliza que a janela deve fechar |
| `swap_buffers(window)` | Apresenta o frame renderizado |
| `poll_events()` | Processa os eventos da janela |
| `get_size(window)` | Retorna as dimensões da janela |
| `set_size(window, w, h)` | Define as dimensões da janela |
| `set_title(window, title)` | Altera o título da janela |
| `get_handle(window)` | Retorna o handle nativo do GLFW |
| `set_vsync(window, enabled)` | Habilita/desabilita VSync |
| `get_vsync(window)` | Verifica se VSync está habilitado |
| `set_fullscreen(window, bool)` | Define fullscreen |
| `is_fullscreen(window)` | Verifica se está em fullscreen |
| `toggle_fullscreen(window)` | Alterna modo fullscreen |
| `get_position(window)` | Retorna posição da janela |
| `set_position(window, x, y)` | Define posição da janela |
| `focus(window)` | Dá foco na janela |
| `is_focused(window)` | Verifica se a janela tem foco |
| `set_resizable(window, bool)` | Habilita/desabilita redimensionamento |

### pb.renderer

| Função | Descrição |
|--------|-----------|
| `init()` | Inicializa o renderer |
| `clear(r, g, b, a)` | Limpa a tela com a cor |
| `begin(width, height)` | Inicia um batch de render 2D |
| `finish()` | Finaliza o batch de render |
| `flush()` | Faz flush sem terminar o batch |
| `pixel(x, y, color)` | Desenha um ponto |
| `line(x1, y1, x2, y2, color)` | Desenha uma linha |
| `rect(x, y, w, h, color)` | Desenha contorno de retângulo |
| `rect_filled(x, y, w, h, color)` | Desenha retângulo preenchido |
| `circle(x, y, radius, color)` | Desenha contorno de círculo |
| `circle_filled(x, y, radius, color)` | Desenha círculo preenchido |
| `triangle(...)` | Desenha contorno de triângulo |
| `triangle_filled(...)` | Desenha triângulo preenchido |
| `set_point_size(size)` | Define tamanho de pontos |
| `set_line_width(width)` | Define largura de linhas |
| `color(r, g, b, a)` | Cria uma tabela de cor (floats 0.0-1.0 ou hex) |
| `color255(r, g, b, a)` | Cria uma tabela de cor a partir de inteiros 0-255 |
| `color_unpack(color)` | Desempacota Color → r, g, b, a (0.0-1.0) |
| `set_clear_color(r, g, b, a?)` | Define o estado da cor de limpeza do OpenGL |
| `enable_depth_test(enabled)` | Habilita/desabilita depth test do OpenGL |
| `enable_blend(enabled)` | Habilita/desabilita blend alpha |
| `set_viewport(x, y, width, height)` | Define o viewport do OpenGL |
| `get_info()` | Retorna tabela com info OpenGL (`version`, `renderer`, `vendor`, `glsl_version`) |
| `colors.WHITE`, `colors.RED`, etc. | Cores pré-definidas |

### pb.texture

| Função | Descrição |
|--------|-----------|
| `load(filepath)` | Carrega textura de arquivo (PNG, JPG, BMP, TGA) |
| `create(w, h, data?)` | Cria textura com dados RGBA opcionais |
| `flush()` | Faz flush de desenhos de textura pendentes |

#### Métodos da Texture

| Método | Descrição |
|--------|-----------|
| `texture:draw(x, y, w?, h?)` | Desenha na posição |
| `texture:draw_tinted(x, y, w, h, r, g, b, a?)` | Desenha com tint |
| `texture:draw_rotated(x, y, w, h, angle)` | Desenha rotacionado (graus) |
| `texture:draw_ex(x, y, w, h, angle, ox, oy, r, g, b, a?)` | Desenho com controle total |
| `texture:draw_region(x, y, w, h, sx, sy, sw, sh)` | Desenha região de sprite sheet |
| `texture:draw_region_ex(...)` | Região com rotação/tint |
| `texture:get_size()` | Retorna largura e altura |
| `texture:get_width()` | Retorna largura |
| `texture:get_height()` | Retorna altura |
| `texture:destroy()` | Libera recursos da textura |
### pb.input

| Função | Descrição |
|--------|----------|
| `is_key_pressed(key)` | Verifica se uma tecla está pressionada |
| `is_key_released(key)` | Verifica se uma tecla não está pressionada |
| `is_mouse_button_pressed(button)` | Verifica se um botão do mouse está pressionado |
| `get_mouse_position()` | Retorna posição do cursor (x, y) |
| `set_mouse_position(x, y)` | Define posição do cursor |
| `set_cursor_visible(visible)` | Mostra/esconde o cursor |
| `set_cursor_locked(locked)` | Trava/destrava cursor (estilo FPS) |

#### Constantes de Tecla

`KEY_A` a `KEY_Z`, `KEY_0` a `KEY_9`, `KEY_SPACE`, `KEY_ESCAPE`, `KEY_ENTER`, `KEY_TAB`, `KEY_BACKSPACE`, `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`, `KEY_F1` a `KEY_F3`, `KEY_F11`, `KEY_F12`, `KEY_LEFT_SHIFT`, `KEY_RIGHT_SHIFT`, `KEY_LEFT_CTRL`, `KEY_RIGHT_CTRL`, `KEY_LEFT_ALT`, `KEY_RIGHT_ALT`

#### Constantes do Mouse

`MOUSE_LEFT`, `MOUSE_RIGHT`, `MOUSE_MIDDLE`

### pb.audio

| Função | Descrição |
|--------|----------|
| `load(filepath)` | Carrega arquivo de áudio (WAV, MP3, FLAC), retorna Sound |
| `set_master_volume(volume)` | Define volume master (0.0–2.0) |
| `get_master_volume()` | Retorna volume master atual |
| `shutdown()` | Encerra o engine de áudio |

#### Métodos do Sound

| Método | Descrição |
|--------|----------|
| `sound:play()` | Toca do início |
| `sound:stop()` | Para e rebobina |
| `sound:pause()` | Pausa na posição atual |
| `sound:resume()` | Retoma de onde pausou |
| `sound:is_playing()` | Verifica se está tocando |
| `sound:set_looping(bool)` | Habilita/desabilita loop |
| `sound:is_looping()` | Verifica se está em loop |
| `sound:set_volume(vol)` | Define volume (0.0 = mudo, 1.0 = normal) |
| `sound:get_volume()` | Retorna volume atual |
| `sound:set_pitch(pitch)` | Define pitch (1.0 = normal, 0.5 = lento, 2.0 = rápido) |
| `sound:get_pitch()` | Retorna pitch atual |
| `sound:destroy()` | Libera recursos do som |

### pb.text

| Função | Descrição |
|--------|-----------|
| `load(filepath, size?)` | Carrega fonte TrueType (.ttf) no tamanho em pixels (padrão 24), retorna Font |
| `flush()` | Faz flush de desenhos de texto pendentes |

#### Métodos da Font

| Método | Descrição |
|--------|-----------|
| `font:draw(text, x, y, color)` | Desenha texto na posição com cor |
| `font:measure(text)` | Retorna largura e altura do texto sem desenhar |
| `font:set_size(size)` | Altera tamanho da fonte (re-rasteriza atlas) |
| `font:get_size()` | Retorna tamanho atual da fonte em pixels |
| `font:get_line_height()` | Retorna altura da linha em pixels |
| `font:destroy()` | Libera recursos da fonte |

> **Nota:** Chame `pb.renderer.flush()` antes de desenhar texto, e `pb.text.flush()` antes de desenhar primitivas — eles usam shaders diferentes.

### pb.time

| Função | Descrição |
|--------|-----------|
| `update()` | Atualiza o sistema de tempo (chamar por frame) |
| `delta()` | Tempo desde o último frame |
| `get()` | Tempo total desde a inicialização |
| `fps()` | FPS atual |
| `sleep(seconds)` | Sleep (busy-wait) |

### pb.camera

| Função | Descrição |
|--------|-----------|
| `set_position(x, y)` | Define offset da câmera (0,0 = sem offset) |
| `get_position()` | Retorna posição da câmera → x, y |
| `move(dx, dy)` | Move a câmera por um delta |
| `set_zoom(zoom)` | Define nível de zoom (1.0 = normal, >1 = zoom in) |
| `get_zoom()` | Retorna nível de zoom atual |
| `set_rotation(angle)` | Define rotação em graus |
| `get_rotation()` | Retorna rotação em graus |
| `look_at(x, y, sw, sh)` | Centraliza câmera em ponto do mundo |
| `reset()` | Reseta para padrões (pos=0,0  zoom=1  rot=0) |
| `screen_to_world(sx, sy)` | Converte coordenadas tela → mundo |
| `world_to_screen(wx, wy)` | Converte coordenadas mundo → tela |

### Formato de Cores

Cores podem ser passadas como:
- Tabela: `{r=1.0, g=0.5, b=0.0, a=1.0}`
- Valores individuais: `r, g, b, a` (alpha opcional, padrão 1.0)

## Dependências

- GLFW3
- OpenGL 3.3+
- Lua 5.4 ou 5.5

## Compilando

### Linux

```bash
make
```

O `makefile` detecta automaticamente sua versão do Lua. Para compilar para uma versão específica:

```bash
make LUA_VERSION=5.4   # Força Lua 5.4
make LUA_VERSION=5.5   # Força Lua 5.5
```

### Windows (MSYS2/MinGW)

1. Instale o MSYS2 e abra o terminal MinGW64
2. Instale as dependências:
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-glfw mingw-w64-x86_64-lua
```
3. Compile:
```bash
make
```

Isso cria `PudimBasicsGl.dll`. Use com:
```lua
-- Windows
package.cpath = ".\\?.dll;" .. package.cpath
local pb = require("PudimBasicsGl")
```

## Scripts de Exemplo

- `examples/main.lua` - Demo básico de render
- `examples/minimal.lua` - Exemplo mínimo
- `examples/texture_demo.lua` - Carregamento e desenho de texturas
- `examples/window_demo.lua` - Demonstração de VSync e funcionalidades de janela
- `examples/input_demo.lua` - Demo de input de teclado e mouse
- `examples/audio_demo.lua` - Demo de carregamento e reprodução de áudio
- `examples/oop_demo.lua` - Demo com estilo orientado a objetos
- `examples/text_demo.lua` - Demo de renderização de texto e carregamento de fontes
- `examples/camera_demo.lua` - Demo de câmera 2D: pan, zoom, rotação e conversão de coordenadas
- `examples/api_reference.lua` - Exemplo completo de referência da API

## Ferramenta de linha de comando (pbgl)

Uma pequena CLI chamada `pbgl` é instalada com o rock. Ela fornece dois comandos:

- `pbgl show-examples` — Copia os scripts de exemplo empacotados para `./demos/` no diretório atual
- `pbgl help` — Mostra informações de uso

Após rodar `pbgl show-examples` você terá uma pasta `./demos/`; execute um exemplo com:

```bash
lua demos/main.lua
```

Certifique-se de que `~/.luarocks/bin` está no seu PATH para poder chamar `pbgl` diretamente:

```bash
export PATH="$HOME/.luarocks/bin:$PATH"
```

## Troubleshooting ⚠️

- Teste rápido: rode `make test`. O alvo executa `scripts/test_preload.sh`, que tenta criar uma janela 1x1 sem precisar de `LD_PRELOAD`. Em ambientes sem display ele tentará usar `Xvfb` automaticamente.
- Se o teste falhar, execute manualmente para coletar informações:
  - `ldd ./PudimBasicsGl.so` — mostra dependências dinâmicas
  - `ldd /usr/lib/libglfw.so.3` — verifica se o GLFW está instalado e resolvível
  - Tente executar com `LD_PRELOAD=/usr/lib/libglfw.so.3 lua scripts/main.lua` como fallback (modo de diagnóstico somente).
- CI: há um workflow de GitHub Actions (`.github/workflows/ci.yml`) que instala dependências em Ubuntu e roda `make test` sob Xvfb; use-o como referência para configurar runners ou debug remoto.

Se você ainda tiver problemas em uma distribuição específica, cole a saída de `make test` e eu ajudo a diagnosticar.
## Créditos

- Arquivo de áudio de exemplo (`examples/example.mp3`) do [file-examples.com](https://file-examples.com/index.php/sample-audio-files/sample-mp3-download/) — usado apenas para testes/demonstração.
- [miniaudio](https://github.com/mackron/miniaudio) — biblioteca de áudio single-header por David Reid (domínio público / MIT-0).
- [stb_image](https://github.com/nothings/stb) — carregador de imagens single-header por Sean Barrett (domínio público / MIT).
- [stb_truetype](https://github.com/nothings/stb) — rasterizador de fontes TrueType single-header por Sean Barrett (domínio público / MIT).
- [GLAD](https://glad.dav1d.de/) — gerador de loader OpenGL.

## Licença

MIT
