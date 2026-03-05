-- PudimBasicsGl Studio Demo
-- Demonstra a UI integrada, file browser (pb.studio), mistura de
-- primitivas + texto + UI sem flush manual (auto-flush por batch switching).

package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local WIDTH, HEIGHT = 1280, 720
local window = pb.window.create(WIDTH, HEIGHT, "Pudim Studio Environment")
pb.renderer.init()

-- ─── Fontes ─────────────────────────────────────────────────────────────────
local font = pb.text.load("/usr/share/fonts/noto/NotoSans-Regular.ttf", 16)
           or pb.text.load("/usr/share/fonts/TTF/DejaVuSans.ttf", 16)
           or pb.text.load("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)

local font_small = nil
if font then
    pb.ui.set_font(font)
    -- Cria uma cópia menor para o viewport
    font_small = pb.text.load("/usr/share/fonts/noto/NotoSans-Regular.ttf", 13)
              or pb.text.load("/usr/share/fonts/TTF/DejaVuSans.ttf", 13)
              or pb.text.load("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
end

-- ─── Estado do ambiente ─────────────────────────────────────────────────────
local env = {
    -- Viewport
    cor_fundo_r = 0.15,
    cor_fundo_g = 0.15,
    cor_fundo_b = 0.20,

    -- Abas: 1 = Viewport, 2 = Arquivos, 3 = Exportar
    aba_ativa = 1,

    -- Objetos na cena (viewport preview)
    obj_x      = 0.5,
    obj_y      = 0.5,
    obj_size   = 0.3,
    obj_rot    = 0.0,
    obj_tipo   = 1,  -- 1=retangulo, 2=circulo, 3=triangulo

    -- File browser
    dir_atual  = "./",
    arquivos   = nil,  -- carregado sob demanda
    scroll_y   = 0,

    -- Log de mensagens
    log = {},
}

local tipo_nomes = { "Retangulo", "Circulo", "Triangulo" }

local function log_msg(msg)
    table.insert(env.log, 1, string.format("[%.1f] %s", pb.time.get(), msg))
    if #env.log > 8 then table.remove(env.log) end
    print(msg)
end

-- Carrega arquivo do diretório atual
local function carregar_arquivos()
    local lista, err = pb.studio.list_dir(env.dir_atual)
    if lista then
        table.sort(lista)
        env.arquivos = lista
    else
        env.arquivos = {}
        log_msg("Erro ao listar: " .. tostring(err))
    end
end
carregar_arquivos()

-- ─── Cores da UI ────────────────────────────────────────────────────────────
local COR_FUNDO    = { 0.12, 0.12, 0.14 }
local COR_PAINEL   = { 0.16, 0.16, 0.19 }
local COR_BORDA    = { 0.30, 0.30, 0.35 }
local COR_ABA_SEL  = { 0.25, 0.45, 0.70 }
local COR_ABA_OFF  = { 0.20, 0.20, 0.25 }
local COR_TEXTO    = { 0.85, 0.85, 0.90 }
local COR_TEXTO_DIM = { 0.50, 0.50, 0.55 }

-- ─── Loop principal ─────────────────────────────────────────────────────────

while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()
    local W, H = pb.window.get_size(window)

    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
        pb.window.close(window)
    end

    -- Anima a rotação do objeto
    env.obj_rot = env.obj_rot + dt * 30

    pb.renderer.clear(COR_FUNDO[1], COR_FUNDO[2], COR_FUNDO[3], 1.0)
    pb.renderer.begin_ui(W, H)
    pb.ui.begin_frame()

    -- Layout responsivo
    local SIDEBAR_W = 220
    local TOOLBAR_H = 36
    local LOG_H     = 120
    local MAIN_X    = SIDEBAR_W + 8
    local MAIN_W    = W - MAIN_X - 8
    local MAIN_Y    = TOOLBAR_H + 8
    local MAIN_H    = H - MAIN_Y - LOG_H - 16

    -----------------------------------------------------------
    -- TOOLBAR (topo)
    -----------------------------------------------------------
    pb.renderer.rect_filled(0, 0, W, TOOLBAR_H, 0.10, 0.10, 0.12, 1.0)
    pb.renderer.line(0, TOOLBAR_H, W, TOOLBAR_H, 0.3, 0.3, 0.35, 1.0)

    -- Abas
    local abas = { "Viewport", "Arquivos", "Exportar" }
    for i, nome in ipairs(abas) do
        local ax = 8 + (i - 1) * 130
        local cor = (env.aba_ativa == i) and COR_ABA_SEL or COR_ABA_OFF
        if pb.ui.button("tab_" .. i, nome, ax, 4, 120, 28, cor[1], cor[2], cor[3]) then
            env.aba_ativa = i
            if i == 2 then carregar_arquivos() end
        end
    end

    -- FPS no canto direito da toolbar
    local fps_txt = string.format("FPS: %.0f", pb.time.fps())
    if font then
        font:draw(fps_txt, W - 100, 10, 0.5, 0.9, 0.5, 1.0)
    end

    -----------------------------------------------------------
    -- SIDEBAR ESQUERDA (Propriedades do objeto)
    -----------------------------------------------------------
    pb.ui.panel("PROPRIEDADES", 4, MAIN_Y, SIDEBAR_W - 4, MAIN_H + LOG_H + 8)

    local sy = MAIN_Y + 36

    pb.ui.label("Tipo do Objeto:", 14, sy, COR_TEXTO[1], COR_TEXTO[2], COR_TEXTO[3], 1.0)
    sy = sy + 24
    for i, nome in ipairs(tipo_nomes) do
        local cor = (env.obj_tipo == i) and COR_ABA_SEL or COR_ABA_OFF
        if pb.ui.button("obj_tipo_" .. i, nome, 14, sy, SIDEBAR_W - 28, 26, cor[1], cor[2], cor[3]) then
            env.obj_tipo = i
            log_msg("Tipo: " .. nome)
        end
        sy = sy + 32
    end

    sy = sy + 8
    pb.ui.label("Posicao e Tamanho:", 14, sy, COR_TEXTO[1], COR_TEXTO[2], COR_TEXTO[3], 1.0)
    sy = sy + 24
    env.obj_x    = pb.ui.slider("obj_x",    "Pos X",    14, sy, SIDEBAR_W - 28, 20, env.obj_x,    0, 1.0)
    sy = sy + 30
    env.obj_y    = pb.ui.slider("obj_y",    "Pos Y",    14, sy, SIDEBAR_W - 28, 20, env.obj_y,    0, 1.0)
    sy = sy + 30
    env.obj_size = pb.ui.slider("obj_size", "Tamanho",  14, sy, SIDEBAR_W - 28, 20, env.obj_size, 0.05, 1.0)
    sy = sy + 40

    pb.ui.label("Cor de Fundo:", 14, sy, COR_TEXTO[1], COR_TEXTO[2], COR_TEXTO[3], 1.0)
    sy = sy + 24
    env.cor_fundo_r = pb.ui.slider("bg_r", "R", 14, sy, SIDEBAR_W - 28, 18, env.cor_fundo_r, 0, 1.0)
    sy = sy + 26
    env.cor_fundo_g = pb.ui.slider("bg_g", "G", 14, sy, SIDEBAR_W - 28, 18, env.cor_fundo_g, 0, 1.0)
    sy = sy + 26
    env.cor_fundo_b = pb.ui.slider("bg_b", "B", 14, sy, SIDEBAR_W - 28, 18, env.cor_fundo_b, 0, 1.0)
    sy = sy + 32

    -- Preview da cor
    pb.renderer.rect_filled(14, sy, SIDEBAR_W - 28, 30,
        env.cor_fundo_r, env.cor_fundo_g, env.cor_fundo_b, 1.0)
    pb.renderer.rect(14, sy, SIDEBAR_W - 28, 30, COR_BORDA[1], COR_BORDA[2], COR_BORDA[3], 1.0)

    -----------------------------------------------------------
    -- PAINEL PRINCIPAL
    -----------------------------------------------------------
    pb.ui.panel("MAIN", MAIN_X, MAIN_Y, MAIN_W, MAIN_H)

    if env.aba_ativa == 1 then
        -------------------------------------------------------
        -- ABA 1: VIEWPORT PREVIEW
        -------------------------------------------------------
        -- Fundo escuro da viewport
        local vx, vy, vw, vh = MAIN_X + 4, MAIN_Y + 32, MAIN_W - 8, MAIN_H - 36
        pb.renderer.rect_filled(vx, vy, vw, vh,
            env.cor_fundo_r, env.cor_fundo_g, env.cor_fundo_b, 1.0)

        -- Grade de fundo (linhas sutis)
        local grid_step = 40
        for gx = vx, vx + vw, grid_step do
            pb.renderer.line(gx, vy, gx, vy + vh, 1.0, 1.0, 1.0, 0.05)
        end
        for gy = vy, vy + vh, grid_step do
            pb.renderer.line(vx, gy, vx + vw, gy, 1.0, 1.0, 1.0, 0.05)
        end

        -- Desenha o objeto na viewport
        local ox = vx + env.obj_x * vw
        local oy = vy + env.obj_y * vh
        local os_px = env.obj_size * math.min(vw, vh) * 0.4

        if env.obj_tipo == 1 then
            -- Retangulo com borda
            pb.renderer.rect_filled(
                math.floor(ox - os_px), math.floor(oy - os_px),
                math.floor(os_px * 2), math.floor(os_px * 2),
                0.2, 0.6, 0.9, 0.85)
            pb.renderer.rect(
                math.floor(ox - os_px), math.floor(oy - os_px),
                math.floor(os_px * 2), math.floor(os_px * 2),
                0.4, 0.8, 1.0, 1.0)

        elseif env.obj_tipo == 2 then
            -- Circulo
            pb.renderer.circle_filled(
                math.floor(ox), math.floor(oy), math.floor(os_px),
                0.9, 0.4, 0.2, 0.85)
            pb.renderer.circle(
                math.floor(ox), math.floor(oy), math.floor(os_px),
                1.0, 0.6, 0.3, 1.0)

        elseif env.obj_tipo == 3 then
            -- Triangulo
            local r = os_px
            local angle = math.rad(env.obj_rot)
            local x1 = math.floor(ox + r * math.cos(angle - math.pi/2))
            local y1 = math.floor(oy + r * math.sin(angle - math.pi/2))
            local x2 = math.floor(ox + r * math.cos(angle + 2.1))
            local y2 = math.floor(oy + r * math.sin(angle + 2.1))
            local x3 = math.floor(ox + r * math.cos(angle + 4.2))
            local y3 = math.floor(oy + r * math.sin(angle + 4.2))
            pb.renderer.triangle_filled(x1, y1, x2, y2, x3, y3, 0.2, 0.9, 0.4, 0.85)
            pb.renderer.triangle(x1, y1, x2, y2, x3, y3, 0.4, 1.0, 0.6, 1.0)
        end

        -- Label do objeto (texto misto com primitivas — sem flush manual!)
        if font_small then
            local info = string.format("%s  (%.0f, %.0f)  rot=%.0f",
                tipo_nomes[env.obj_tipo], ox, oy, env.obj_rot % 360)
            font_small:draw(info, vx + 6, vy + vh - 20, 0.7, 0.7, 0.75, 1.0)
        end

        -- Borda da viewport
        pb.renderer.rect(vx, vy, vw, vh, COR_BORDA[1], COR_BORDA[2], COR_BORDA[3], 1.0)

    elseif env.aba_ativa == 2 then
        -------------------------------------------------------
        -- ABA 2: FILE BROWSER (pb.studio.list_dir)
        -------------------------------------------------------
        pb.ui.label("Diretorio: " .. env.dir_atual, MAIN_X + 14, MAIN_Y + 40,
            COR_TEXTO[1], COR_TEXTO[2], COR_TEXTO[3], 1.0)

        -- Botao para voltar ao diretorio pai
        if pb.ui.button("btn_dir_up", ".. (voltar)", MAIN_X + 14, MAIN_Y + 64, 160, 26, 0.25, 0.25, 0.30) then
            if env.dir_atual ~= "/" then
                env.dir_atual = env.dir_atual:match("(.+)/") or "/"
                carregar_arquivos()
                env.scroll_y = 0
                log_msg("Dir: " .. env.dir_atual)
            end
        end

        -- Botao para recarregar
        if pb.ui.button("btn_dir_refresh", "Recarregar", MAIN_X + 184, MAIN_Y + 64, 120, 26, 0.25, 0.35, 0.25) then
            carregar_arquivos()
            log_msg("Recarregado: " .. env.dir_atual)
        end

        -- Lista de arquivos
        local ly = MAIN_Y + 100
        local max_visible = math.floor((MAIN_H - 110) / 24)
        if env.arquivos then
            local total = #env.arquivos
            pb.ui.label(string.format("%d itens", total), MAIN_X + 314, MAIN_Y + 68,
                COR_TEXTO_DIM[1], COR_TEXTO_DIM[2], COR_TEXTO_DIM[3], 1.0)

            local start_i = env.scroll_y + 1
            local end_i = math.min(start_i + max_visible - 1, total)

            for i = start_i, end_i do
                local nome = env.arquivos[i]
                local is_dir = nome:sub(-1) == "/"
                local cor = is_dir and { 0.4, 0.6, 0.9 } or COR_TEXTO_DIM

                -- Fundo alternado
                if (i % 2) == 0 then
                    pb.renderer.rect_filled(MAIN_X + 10, ly - 2, MAIN_W - 20, 22,
                        1.0, 1.0, 1.0, 0.03)
                end

                if is_dir then
                    if pb.ui.button("file_" .. i, nome, MAIN_X + 14, ly, MAIN_W - 28, 20,
                            0.18, 0.22, 0.30) then
                        env.dir_atual = env.dir_atual .. "/" .. nome:sub(1, -2)
                        carregar_arquivos()
                        env.scroll_y = 0
                        log_msg("Dir: " .. env.dir_atual)
                    end
                else
                    pb.ui.label(nome, MAIN_X + 20, ly + 2, cor[1], cor[2], cor[3], 1.0)
                    -- Mostra horário de modificação
                    local mtime = pb.studio.get_file_modified_time(env.dir_atual .. "/" .. nome)
                    if mtime and font_small then
                        font_small:draw(
                            string.format("%.0f", mtime),
                            MAIN_X + MAIN_W - 140, ly + 3,
                            0.35, 0.35, 0.40, 1.0)
                    end
                end
                ly = ly + 24
            end

            -- Scroll com setas
            if total > max_visible then
                if pb.input.is_key_pressed(pb.input.KEY_DOWN) then
                    env.scroll_y = math.min(env.scroll_y + 1, total - max_visible)
                end
                if pb.input.is_key_pressed(pb.input.KEY_UP) then
                    env.scroll_y = math.max(env.scroll_y - 1, 0)
                end
                pb.ui.label(
                    string.format("Scroll: %d/%d (setas UP/DOWN)",
                        env.scroll_y + 1, total - max_visible + 1),
                    MAIN_X + 14, MAIN_Y + MAIN_H - 20,
                    COR_TEXTO_DIM[1], COR_TEXTO_DIM[2], COR_TEXTO_DIM[3], 1.0)
            end
        end

    elseif env.aba_ativa == 3 then
        -------------------------------------------------------
        -- ABA 3: EXPORTAR PROJETO
        -------------------------------------------------------
        pb.ui.label("Configuracoes de Build", MAIN_X + 14, MAIN_Y + 44,
            COR_TEXTO[1], COR_TEXTO[2], COR_TEXTO[3], 1.0)

        -- Desenha ícones de plataforma com primitivas
        local bx = MAIN_X + 40
        local by = MAIN_Y + 90

        -- "Linux" box
        pb.renderer.rect_filled(bx, by, 180, 120, 0.15, 0.20, 0.30, 1.0)
        pb.renderer.rect(bx, by, 180, 120, 0.3, 0.5, 0.8, 1.0)
        -- Pinguim simplificado (circulo + triangulo)
        pb.renderer.circle_filled(bx + 90, by + 45, 20, 0.9, 0.9, 0.2, 1.0)
        pb.renderer.triangle_filled(bx + 70, by + 60, bx + 110, by + 60, bx + 90, by + 100, 0.2, 0.2, 0.2, 1.0)
        if font then
            font:draw("Linux", bx + 60, by + 104, 0.7, 0.8, 1.0, 1.0)
        end

        -- "Windows" box
        bx = bx + 220
        pb.renderer.rect_filled(bx, by, 180, 120, 0.20, 0.15, 0.25, 1.0)
        pb.renderer.rect(bx, by, 180, 120, 0.5, 0.3, 0.7, 1.0)
        -- Janela simplificada (4 quadrados)
        local ww = 16
        pb.renderer.rect_filled(bx + 75, by + 30, ww, ww, 0.3, 0.6, 1.0, 1.0)
        pb.renderer.rect_filled(bx + 95, by + 30, ww, ww, 0.3, 0.6, 1.0, 1.0)
        pb.renderer.rect_filled(bx + 75, by + 50, ww, ww, 0.3, 0.6, 1.0, 1.0)
        pb.renderer.rect_filled(bx + 95, by + 50, ww, ww, 0.3, 0.6, 1.0, 1.0)
        if font then
            font:draw("Windows", bx + 50, by + 104, 0.8, 0.7, 1.0, 1.0)
        end

        -- Botão de exportação
        local ex_y = by + 160
        if pb.ui.button("btn_export_linux", "Gerar Build Linux", MAIN_X + 40, ex_y, 180, 44, 0.2, 0.5, 0.3) then
            log_msg("Build Linux iniciada!")
        end
        if pb.ui.button("btn_export_win", "Gerar Build Windows", MAIN_X + 260, ex_y, 180, 44, 0.5, 0.2, 0.5) then
            log_msg("Build Windows iniciada!")
        end
    end

    -----------------------------------------------------------
    -- LOG (rodapé)
    -----------------------------------------------------------
    local log_y = H - LOG_H - 4
    pb.renderer.rect_filled(MAIN_X, log_y, MAIN_W, LOG_H, 0.08, 0.08, 0.10, 1.0)
    pb.renderer.rect(MAIN_X, log_y, MAIN_W, LOG_H, COR_BORDA[1], COR_BORDA[2], COR_BORDA[3], 1.0)

    if font_small then
        font_small:draw("Console", MAIN_X + 6, log_y + 4, 0.5, 0.5, 0.55, 1.0)
    end
    local log_line_y = log_y + 22
    for i, msg in ipairs(env.log) do
        if log_line_y > log_y + LOG_H - 16 then break end
        pb.ui.label(msg, MAIN_X + 10, log_line_y,
            COR_TEXTO_DIM[1], COR_TEXTO_DIM[2], COR_TEXTO_DIM[3], 1.0)
        log_line_y = log_line_y + 16
    end

    -----------------------------------------------------------

    pb.ui.end_frame()
    pb.renderer.end_ui()
    pb.renderer.finish()

    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

-- ─── Cleanup ────────────────────────────────────────────────────────────────
if font_small then font_small:destroy() end
if font then font:destroy() end
pb.window.destroy(window)
print("Studio demo finalizado.")
