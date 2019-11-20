  require 'gosu'

  class Boss_bullet
    SPEED = 7
    attr_reader :x, :y, :radius, :angle
    def initialize(window, x, y, angle)
      @x = x + 8
      @y = y + 18
      @angle = angle
      @image = Gosu::Image.new('images/boss_bullet.png')
      @radius = 5
      @window = window
    end

    def move
      @x += Gosu.offset_x(@angle, SPEED)
      @y += Gosu.offset_y(@angle, SPEED)
    end

    def draw
      @image.draw(@x, @y, 1)
    end

    def onscreen?
      right = @window.width + @radius
      left = -@radius
      top = -@radius
      bottom = @window.height + @radius
      @x > left and @x < right and @y > top and @y < bottom
    end
  end


  class Boss
    BOUNCE = -1
    attr_accessor :x, :y, :radius, :speed
    def initialize(window)
      @radius = 60
      @window = window
      @x = 460
      @y = 0
      @speed = 3
      @image = Gosu::Image.new('images/boss.png')
      @position = :initial
    end

    def move
      case @position
      when :fix
        @x += @speed
        if @x > @window.width - @radius
          @speed *= BOUNCE
          @x = @window.width - @radius
        end
        if @x < @radius
          @speed *= BOUNCE
          @x = @radius
        end
      when :initial
        @y += @speed
        if @y > 100
          @position = :fix
        end
      end
    end

    def draw
      @image.draw(@x - @radius, @y - @radius, 1)
    end
  end


  class Credit
    SPEED = 1
    attr_reader :y

    def initialize(window,text,x,y)
      @x = x
      @y = @initial_y = y
      @text = text
      @font = Gosu::Font.new(24)
    end

    def move
      @y -= SPEED
    end

    def draw
      @font.draw(@text, @x, @y, 1)
    end

    def reset
      @y = @initial_y
    end
  end

  class Explosion
    SPEED = 5
    attr_reader :x, :y, :finished, :radius
    def initialize(window, x, y)
      @x = x
      @y = y
      @radius = 30
      @images = Gosu::Image.load_tiles('images/explosions.png',60,60)
      @image_index = 0
      @finished = false
    end

    def draw
      if @image_index < @images.count
        @images[@image_index].draw(@x - @radius, @y - @radius, 2)
        @image_index += 1
      else
        @finished = true
      end
    end

    def move
      @y += SPEED
    end
  end

  class Bullet
    SPEED = 6
    attr_reader :x, :y, :radius
    def initialize(window, x, y, angle)
      @x = x
      @y = y
      @direction = angle
      @image = Gosu::Image.new('images/bullet.png')
      @radius = 3
      @window = window
    end

    def move
      @x += Gosu.offset_x(@direction, SPEED)
      @y += Gosu.offset_y(@direction, SPEED)
    end

    def draw
      @image.draw(@x - @radius, @y - @radius, 1)
    end

    def onscreen?
      right = @window.width + @radius
      left = -@radius
      top = -@radius
      bottom = @window.height + @radius
      @x > left and @x < right and @y > top and @y < bottom
    end
  end


  class Enemy
    attr_accessor :x, :y, :radius, :speed
    def initialize(window,speed)
      @radius = 20
      @x = rand(window.width - 2 * @radius) + @radius
      @y = 0
      @speed = speed
      @image = Gosu::Image.new('images/enemy.png')
    end

    def move
      @y += @speed
    end

    def draw
      @image.draw(@x - @radius, @y - @radius, 1)
    end
  end

  class Player
    ROTATION_SPEED = 3
    ACCELERATION = 2
    FRICTION = 0.8
    BOUNCE = -2
    attr_reader :x, :y, :angle, :radius
    def initialize(window)
      @x = 400
      @y = 600
      @angle = 0
      @image = Gosu::Image.new('images/ship.png')
      @velocity_x = 0
      @velocity_y = 0
      @radius = 20
      @window = window
    end

    def draw
      @image.draw_rot(@x, @y, 1, @angle)
    end

    def turn_right
      @angle += ROTATION_SPEED
    end

    def turn_left
      @angle -= ROTATION_SPEED
    end

    def accelerate
      @velocity_x += Gosu.offset_x(@angle, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle, ACCELERATION)
    end

    def move
      @x += @velocity_x
      @y += @velocity_y
      @velocity_x *= FRICTION
      @velocity_y *= FRICTION
      if @x > @window.width - @radius
        @velocity_x *= BOUNCE
        @x = @window.width - @radius
      end
      if @x < @radius
        @velocity_x *= BOUNCE
        @x = @radius
      end
      if @y > @window.height - @radius
        @velocity_y *= BOUNCE
        @y = @window.height - @radius
      end
    end
  end


  class SectorFive < Gosu::Window
    WIDTH = 800
    HEIGHT = 600
    def initialize
      super(WIDTH, HEIGHT)
      self.caption = "Sector Five"
      @background_image = Gosu::Image.new('images/start_screen.png')
      @scene = :start
      @start_music = Gosu::Song.new('sounds/Lost Frontier.ogg')
      @start_music.play(true)
    end

    def draw
      case @scene
      when :start
        draw_start
      when :game
        draw_game
      when :boss
        draw_boss
      when :end
        draw_end
      end
    end

    def draw_start
      @background_image.draw(0,0,0)
    end

    def draw_game
      @player.draw
      @bullets.each do |bullet|
        bullet.draw
      end
      @ingame_font = Gosu::Font.new(30)
      @ingame_font.draw(@score.to_s, 700,20,1,1,1,Gosu::Color::WHITE)
      @ingame_font.draw(@health.to_s, 30,20,1,1,1,Gosu::Color::WHITE)
      case @mode
      when :normal
        @enemies.each do |enemy|
          enemy.draw
        end
        @explosions.each do |explosion|
          explosion.draw
        end
        if @hit_bottom == -1
          draw_quad(0,0,Gosu::Color::RED,800,0,Gosu::Color::RED,800,600,Gosu::Color::RED,0,600,Gosu::Color::RED)
          @hit_bottom = 0
        end
      when :boss
        @boss.draw
        @boss_bullets.each do |boss_bullet|
          boss_bullet.draw
        end
        Gosu::Font.new(30).draw(@boss_health.to_s, 380,20,1,1,1,Gosu::Color::WHITE)
      end
    end

    def update
      case @scene
      when :game
        update_game
      when :end
        update_end
      end
    end

    def button_down(id)
      case @scene
      when :start
        button_down_start(id)
      when :game
        button_down_game(id)
      when :end
        button_down_end(id)
      end
    end

    def button_down_start(id)
      initialize_game
    end

    def initialize_game
      @player = Player.new(self)
      @enemies = []
      @bullets = []
      @explosions = []
      @scene = :game
      @score = 0
      @health = 100
      @max_enemy_per_wave = 10
      @enemy_speed = 3
      @enemy_frequency = 0.01
      @hit_bottom = 0
      @enemies_appeared = 0
      @enemies_destroyed = 0
      @game_music = Gosu::Song.new('sounds/Cephalopod.ogg')
      @game_music.play(true)
      @explosion_sound = Gosu::Sample.new('sounds/explosion.ogg')
      @shooting_sound = Gosu::Sample.new('sounds/shoot.ogg')
      @mode = :normal
      @boss = Boss.new(self)
      @boss_bullets = []
      @bullet_frequency = 0.04
      @boss_health = 500
    end

    def update_game
      @player.turn_left if button_down?(Gosu::KbLeft)
      @player.turn_right if button_down?(Gosu::KbRight)
      @player.accelerate if button_down?(Gosu::KbUp)
      @player.move
      @bullets.each do |bullet|
        bullet.move
      end
      @bullets.dup.each do |bullet|
        @bullets.delete bullet unless bullet.onscreen?
      end
      case @mode
      when :normal
        if rand < @enemy_frequency
          @enemies.push Enemy.new(self, @enemy_speed)
          @enemies_appeared += 1
        end
        @enemies.each do |enemy|
          enemy.move
        end
        @enemies.dup.each do |enemy|
          @bullets.dup.each do |bullet|
            distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
            if distance < enemy.radius + bullet.radius
              @enemies.delete enemy
              @bullets.delete bullet
              @explosions.push Explosion.new(self, enemy.x, enemy.y)
              @enemies_destroyed += 1
              @score += 2
              @explosion_sound.play
            end
          end
        end
        @explosions.dup.each do |explosion|
          @enemies.dup.each do |enemy|
            distance = Gosu.distance(enemy.x, enemy.y, explosion.x, explosion.y)
            if distance < enemy.radius + explosion.radius
              @enemies.delete(enemy)
              @explosions.push(Explosion.new(self, enemy.x, enemy.y))
              @enemies_destroyed +=1
              @score += 5
            end
          end
        end
        @explosions.dup.each do |explosion|
          @explosions.delete explosion if explosion.finished
        end
        @enemies.dup.each do |enemy|
          if enemy.y > HEIGHT + enemy.radius
            @enemies.delete enemy
            @score -= 1
            @hit_bottom = -1
            @health -= 5
          end
        end
        if @enemies_appeared > @max_enemy_per_wave
          @health += 50
          @enemy_speed += 0.25
          @max_enemy_per_wave *= 2
          if @enemy_frequency < 0.4
            @enemy_frequency *= 2
          else
            @enemy_frequency += 0.1
          end
        end
        if @enemies_appeared > 1000
          @enemies.dup.each do |enemy|
            @explosions.push(Explosion.new(self, enemy.x, enemy.y))
            @enemies.delete(enemy)
            @enemies_destroyed += 1
            @score += 2
          end
          @explosion_sound.play
          @mode = :boss
        end
      when :boss
        @boss.move
        if rand < @bullet_frequency
          @boss_bullets.push(Boss_bullet.new(self, @boss.x, @boss.y, 200))
          @boss_bullets.push(Boss_bullet.new(self, @boss.x, @boss.y, 160))
        end
        @boss_bullets.each do |boss_bullet|
          boss_bullet.move
        end
        @boss_bullets.each do |boss_bullet|
          distance = Gosu.distance(@player.x, @player.y, boss_bullet.x, boss_bullet.y)
          if distance < @player.radius + boss_bullet.radius
            @health -= 10
            @boss_bullets.delete boss_bullet
            @explosions.push(Explosion.new(self, @player.x, @player.y))
            @explosion_sound.play
          end
        end
        @bullets.each do |bullet|
          distance = Gosu.distance(@boss.x, @boss.y, bullet.x, bullet.y)
          if distance < @boss.radius + bullet.radius
            @boss_health -= 5
            @score += 10
            @bullets.delete bullet
            @explosion_sound.play
          end
        end
        player_boss = Gosu.distance(@player.x, @player.y, @boss.x, @boss.y)
        if player_boss < @boss.radius + @player.radius
          initialize_end(:hit_by_enemy)
        end
        @boss_bullets.dup.each do |boss_bullet|
          @bullets.delete boss_bullet unless boss_bullet.onscreen?
        end
        if @boss_health < 100
          @bullet_frequency = 0.1
        end
        if @boss_health < 1
          initialize_end(:success)
        end
      end
      initialize_end(:no_health) if @health < 1
      @enemies.each do |enemy|
        distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
        initialize_end(:hit_by_enemy) if distance < @player.radius + enemy.radius
      end
      initialize_end(:off_top) if @player.y < -@player.radius
    end

    def initialize_end(fate)
      case fate
      when :success
        @message = "You successfully defend."
        @message2 = "You took out all enemy ships."
      when :no_health
        @message = "Your base ran out of health."
        @message2 = "Before your ship was destroyed, "
        @message2 += "you took out #{@enemies_destroyed} enemy ships."
      when :hit_by_enemy
        @message = "You were struck by an enemy ship."
        @message2 = "Before your ship was destroyed, "
        @message2 += "you took out #{@enemies_destroyed} enemy ships."
      when :off_top
        @message = "You got too close to the enemy mother ship."
        @message2 = "Before your ship was destroyed, "
        @message2 += "you took out #{@enemies_destroyed} enemy ships."
      end
      @bottom_message = "Press P to play again, or Q to quit."
      @message_font = Gosu::Font.new(23)
      @credits = []
      y = 700
      File.open('credits.txt').each do |line|
        @credits.push(Credit.new(self,line.chomp,100,y))
        y+=30
      end
      @scene = :end
      @end_music = Gosu::Song.new('sounds/FromHere.ogg')
      @end_music.play(true)
      highscore_file = File.new("highscore.txt", "r")
      @highscore_score = highscore_file.gets.to_i
      highscore_file.close()
      if @score > @highscore_score
          @highscore_score = @score
          score_file = File.new("highscore.txt", "w")
          score_file.puts(@highscore_score.to_s)
      end
    end

    def draw_end
      clip_to(50,140,700,360) do
        @credits.each do |credit|
          credit.draw
        end
      end
      @message_font.draw("High score is #{@highscore_score}",40,10,1,1,1,Gosu::Color::FUCHSIA)
      @message_font.draw("Your total score is #{@score}",40,40,1,1,1,Gosu::Color::FUCHSIA)
      draw_line(0,140,Gosu::Color::RED,WIDTH,140,Gosu::Color::RED)
      @message_font.draw(@message,40,68,1,1,1,Gosu::Color::FUCHSIA)
      @message_font.draw(@message2,40,97,1,1,1,Gosu::Color::FUCHSIA)
      draw_line(0,500,Gosu::Color::RED,WIDTH,500,Gosu::Color::RED)
      @message_font.draw(@bottom_message,230,540,1,1,1,Gosu::Color::AQUA)
    end

    def update_end
      @credits.each do |credit|
        credit.move
      end
      if @credits.last.y < 150
        @credits.each do |credit|
          credit.reset
        end
      end
    end

    def button_down_game(id)
      if id == Gosu::KbSpace
        if @enemies_destroyed < 100
          @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle))
        elsif 100 <= @enemies_destroyed and @enemies_destroyed <= 300
          @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle + 10))
          @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle - 10))
        else
          @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle))
          @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle + 15))
          @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle - 15))
        end
        @shooting_sound.play(0.3)
      end
    end

    def button_down_end(id)
      if id == Gosu::KbP
        initialize_game
      elsif id == Gosu::KbQ
        close
      end
    end
  end

  window = SectorFive.new
  window.show
