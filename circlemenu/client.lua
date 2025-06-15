
local isMenuVisible = false
-- Позиция центра меню
local screenW, screenH = guiGetScreenSize()
local centerX, centerY = screenW / 2, screenH / 2

local numCircles = 5
local distance = 200 -- насколько далеко от центра
local circleRadius = screenH * 0.09 -- радиус самих маленьких кругов
local dashedCircleMinRadius = circleRadius-circleRadius*0.025
local dashedCircleMaxRadius = circleRadius + circleRadius*0.075
local animationProgress = {}

local images ={
    "pencil.png",
    "pencil.png",
    "tools.png",
    "pencil.png",
    "pencil.png"
}
local labels = {
  "Pen", "Hammer", "Tools", "Brush", "Eraser"
}
local imgSize= circleRadius * 0.9
local maxImageY= imgSize*0.2
for i = 1, numCircles do
    animationProgress[i] = 0
end


-- Открыть/закрыть меню по клавише "F4"
bindKey("F4", "down", function()
    isMenuVisible = not isMenuVisible
    if isMenuVisible then
         showCursor(true) -- показываем курсор
        toggleAllControls(false) -- блокируем управление игроком
    else
        showCursor(false) -- скрываем курсор
        toggleAllControls(true) -- восстанавливаем управление игроком    
    end
end)

addEventHandler("onClientRender", root, function()
    -- Центр (можно не рисовать)
    -- dxDrawCircle(centerX, centerY, 5, 0, 360, tocolor(255, 255, 255, 200))
    if not isMenuVisible then return end
    local mx, my = getCursorPosition()
    if mx and my then
    mouseX = mx * screenW
    mouseY = my * screenH
    else
    mouseX = -1
    mouseY = -1
    end
    for i = 1, numCircles do
        local angle = (i - 1) * (360 / numCircles)
        local angleRad = math.rad(angle)

        local x = centerX + math.cos(angleRad) * distance
        local y = centerY + math.sin(angleRad) * distance
      
        -- Рисуем маленький круг (как заполненный прямоугольник с alpha → круг нужно эмулировать)
        dxDrawCircle(x, y, circleRadius, 0, 360, tocolor(255, 255, 255, 255))

        

        -- Проверяем, находится ли курсор в круге
        local isHovered = isPointInSector(mouseX, mouseY, x, y, circleRadius)
        -- Логика анимации прерывистой линии
        if isHovered then
            animationProgress[i] = animationProgress[i] + 0.1
            if animationProgress[i] >= 1 then
                animationProgress[i] = 1
            end
         
        else
            if animationProgress[i]>0 then
            animationProgress[i] = animationProgress[i] - 0.1
            end
            if animationProgress[i] < 0 then
                animationProgress[i] = 0
            end
          
        end
          local radius = dashedCircleMinRadius + (dashedCircleMaxRadius - dashedCircleMinRadius) * animationProgress[i]
            drawDashedCircle(x, y, radius, 0, 360, tocolor(255, 255, 255, 255*animationProgress[i]), 50, 2)

            local baseY = y - imgSize/2
            local imageY = baseY - (maxImageY * animationProgress[i])
            dxDrawImage(x - imgSize/2, imageY, imgSize, imgSize, images[i])
           -- Вычисляем позицию и масштаб
            local textAlpha = 255 * animationProgress[i]
            local textScale = imgSize/80 + (imgSize/160   * animationProgress[i])  -- от 0.6 до 1.0
            local textYOffset = (imgSize * 0.3) * animationProgress[i]  -- надпись уходит вниз от центра

            -- Центр надписи = x, y + смещение вниз
            local textY = y + textYOffset

            -- Отрисовка текста
            dxDrawText(
                labels[i],
                x - 150, textY, x + 150, textY + 30,
                tocolor(0, 0, 0, textAlpha),
                textScale, "default-bold", "center", "top"
            )
       
    end
    
end)
-- Рисуем прерывистую окружность
function drawDashedCircle(cx, cy, radius, startAngle, endAngle, color, segmentCount, gapSize)
    local totalAngle = endAngle - startAngle
    local anglePerSegment = totalAngle / segmentCount

    for i = 0, segmentCount - 1 do
        local segStartAngle = startAngle + i * anglePerSegment
        local segEndAngle = segStartAngle + anglePerSegment - gapSize

        local startRad = math.rad(segStartAngle)
        local endRad = math.rad(segEndAngle)

        local startX = cx + math.cos(startRad) * radius
        local startY = cy + math.sin(startRad) * radius
        local endX = cx + math.cos(endRad) * radius
        local endY = cy + math.sin(endRad) * radius

        dxDrawLine(startX, startY, endX, endY, color, 2)
    end
end



-- Утилита — проверка попадания точки в сектор
function isPointInSector(px, py, cx, cy, radius)
    local dx = px - cx
    local dy = py - cy
    local distance = math.sqrt(dx*dx + dy*dy)

    return distance <= radius
end
