# PudimBasicsGl - Pudim OpenGL Basics 

Uma biblioteca 2D mínima para Lua usando OpenGL. O PudimBasicsGl foca no essencial: **gestão de janelas**, **renderização 2D**, **texturas** e **tempo**. Tratamento de entrada e utilitários de matemática ficam a critério do desenvolvedor.

> [!WARNING]
> Este projeto está em estado *experimental*. APIs e funcionalidades podem mudar sem aviso — use com cautela.

## Recursos

- **Janela**: Criação e gerenciamento de janelas OpenGL com VSync, fullscreen e suporte a redimensionamento
- **Renderer**: Desenho de primitivas 2D (pontos, linhas, retângulos, círculos, triângulos)
- **Texturas**: Carregamento de imagens (PNG, JPG, BMP, etc.) e renderização com rotação, tint e suporte a sprites
- **Tempo**: Delta time, FPS e utilitários de tempo

## Compilação

```bash
make
```

Isso cria `PudimBasicsGl.so`, um módulo Lua que você pode carregar com `require("PudimBasicsGl")`.

## Suporte LSP

Adicione `library/` ao caminho da `lua-language-server` para autocompletar e checagem de tipos:

```json
// .vscode/settings.json
{
    "Lua.workspace.library": ["./library"]
}
```

Ou copie `library/PudimBasicsGl.lua` para a pasta de addons global do `lua-language-server`.


## Instalação via LuaRocks

```bash
luarocks make PudimBasicsGl-1.0.0-1.rockspec
```

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
| `color(r, g, b, a)` | Cria uma tabela de cor |
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

### pb.time

| Função | Descrição |
|--------|-----------|
| `update()` | Atualiza o sistema de tempo (chamar por frame) |
| `delta()` | Tempo desde o último frame |
| `get()` | Tempo total desde a inicialização |
| `fps()` | FPS atual |
| `sleep(seconds)` | Sleep (busy-wait) |

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

- `scripts/main.lua` - Demo básico de render
- `scripts/texture_demo.lua` - Carregamento e desenho de texturas
- `scripts/window_demo.lua` - Demonstração de VSync e funcionalidades de janela

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

## Por que sem Input/Math?

O PudimBasicsGl é propositalmente mínimo. Para input, você pode:
- Acessar o GLFW diretamente via `pb.window.get_handle(window)`
- Usar uma biblioteca dedicada de input
- Implementar a sua própria usando FFI

Para matemática, a `math` do Lua cobre a maioria das necessidades, e há excelentes bibliotecas como `cpml` ou `batteries` disponíveis.

## Licença

MIT
