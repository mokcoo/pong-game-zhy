push = require 'push'
Class = require 'class'
require 'Ball'
require 'Paddle'

WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1280
VIRTUAL_HEIGHT = 243
VIRTUAL_WIDTH = 432

PADDLE_SPEED = 200



function love.load()
    --love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    --    fullscreen = false,
    --    resizable = false,
    --    vsync = true
    --})

    love.graphics.setDefaultFilter("nearest","nearest")
    math.randomseed(os.time())
    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)
    love.graphics.setFont(smallFont)
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    winningPlayer = 0
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    -- place a ball in the middle of the screen
    ball = Ball
    ball:init(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    gameState = "start"

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['score'] = love.audio.newSource('sounds/score.wav','static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static'),
    }
end



function love.update(dt)
    --changing ball's moving direction and check collides
    if gameState == "serve" then
        if servingPlayer == 1 then
            ball.dx = -math.random(140, 200)
        else 
            ball.dx = math.random(140,200)
        end
    --paddle collide
    elseif gameState == "play" then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 5
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        --wall collide
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = - ball.dy
            sounds['wall_hit']:play()
        end
        if ball.y > VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play() 
        end
    end
    --Counting players' score and check which one wins
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        if player2Score == 10 then
            winningPlayer = 2
            gameState = "done"
        else
            ball:reset()
            gameState = "serve"
        end
        sounds['score']:play()
    end
    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        if player1Score == 10 then
            winningPlayer = 1
            gameState = "done"
        else
            ball:reset()
            gameState = "serve"
        end
        sounds['score']:play()
    end
    --update paddle's location
    if love.keyboard.isDown("w") then
        player1.speed = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        player1.speed = PADDLE_SPEED
    else
        player1.speed = 0
    end
    if love.keyboard.isDown("up") then
        player2.speed = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.speed = PADDLE_SPEED
    else
        player2.speed = 0
    end
    if gameState == "play" then
        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end



function love.draw()
    push:apply("start")
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    love.graphics.setFont(smallFont)
    if gameState == "start" then
        love.graphics.printf(
            "please start",
            0,
            20,
            VIRTUAL_WIDTH,
            "center"
        )
    elseif gameState == "serve" then
        love.graphics.printf(
            "Player" .. tostring(servingPlayer) .. "'s serve !!!",
            0,
            20,
            VIRTUAL_WIDTH,
            "center"
        )
    elseif gameState == "play" then
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
            VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
            VIRTUAL_HEIGHT / 3)
    elseif gameState == "done" then
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')

    end
    player1:render()
    player2:render()
    ball:render()
    --love.graphics.setFont(scoreFont)
    --love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
    --    VIRTUAL_HEIGHT / 3)
    --love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
    --    VIRTUAL_HEIGHT / 3)

    push:apply("end")
end



function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if gameState == "start" then
            gameState = "serve"
        elseif gameState == "serve" then
            gameState = "play"
        elseif gameState == "done" then
            player1Score = 0
            player2Score = 0
            if winningPlayer == 1 then
                servingPlayer = 2
            else 
                servingPlayer = 1
            end
            gameState = 'start'
            ball:reset()
        end
    end
end
