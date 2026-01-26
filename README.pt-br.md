# PudimBasicsGl - Pudim OpenGL Basics 

Uma biblioteca 2D mínima para Lua usando OpenGL. O PudimBasicsGl foca no essencial: **gerenciamento de janelas**, **renderização 2D**, **texturas** e **tempo**. Entrada e utilitários de matemática ficam a cargo do desenvolvedor.

## Funcionalidades

- **Janela**: Criação/gerenciamento de janelas OpenGL com VSync, fullscreen e resize
- **Renderer**: Desenho de primitivos 2D (pixels, linhas, retângulos, círculos, triângulos)
- **Texturas**: Carrega imagens (PNG, JPG, BMP, etc.) e desenha com rotação, tint e suporte a sprite sheets
- **Tempo**: Delta time, FPS e utilitários de tempo

## Compilando

### Linux

```bash
make
```

O makefile detecta a versão do Lua automaticamente. Para forçar uma versão:

```bash
make LUA_VERSION=5.4   # Forçar Lua 5.4
make LUA_VERSION=5.5   # Forçar Lua 5.5
```

### Windows (MSYS2/MinGW)

1. Instale MSYS2 e abra o terminal MinGW64
2. Instale dependências:
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-glfw mingw-w64-x86_64-lua
```
3. Compile:
```bash
make
```

Isso gera `PudimBasicsGl.dll`. Use assim:

```lua
-- Windows
package.cpath = ".\\?.dll;" .. package.cpath
local pb = require("PudimBasicsGl")
```

## Uso (exemplo)

```lua
local pb = require("PudimBasicsGl")

local window = pb.window.create(800, 600, "Meu App")
pb.renderer.init()

local texture = pb.texture.load("sprite.png")

while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()

    local w, h = pb.window.get_size(window)
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(w, h)

    -- Desenhe primitivos e texturas aqui

    pb.texture.flush()
    pb.renderer.finish()

    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

if texture then texture:destroy() end
pb.window.destroy(window)
```

## Ferramenta de linha de comando (pbgl)

O pacote instala uma pequena CLI chamada `pbgl` com dois comandos:

- `pbgl show-examples` — Copia os scripts de exemplo para `./demos/` no diretório atual
- `pbgl help` — Mostra informações de uso (também disponível em português)

Depois de rodar `pbgl show-examples` você terá a pasta `./demos/`; execute um exemplo com:

```bash
lua demos/main.lua
```

Garanta que `~/.luarocks/bin` esteja no seu PATH para poder executar `pbgl` diretamente:

```bash
export PATH="$HOME/.luarocks/bin:$PATH"
```

## Dependências

- GLFW3
- OpenGL 3.3+
- Lua 5.4 ou 5.5

---

Se quiser, posso traduzir mais partes do README ou adicionar versões localizadas de outros arquivos de documentação.