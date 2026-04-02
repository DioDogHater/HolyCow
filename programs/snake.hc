#include "../std/stdlib.hhc"
#include "../std/linux/termios.hc"
#include "../std/linux/syscall.hhc"
#include "../std/linux/errno.hc"
#include "../std/linux/time.hc"

// SNAKE GAME
// Will only work on a linux TTY as of now

// File descriptor IO (needed for non-blocking input)
#define F_GETFL         3       /* Get file status flags.  */
#define F_SETFL         4       /* Set file status flags.  */
#define O_NONBLOCK      0o4000
int fcntl(int fd, int cmd, int data = 0){
    return syscall3(72, fd, cmd, data);
}

void nonblock_stdin(){
    fcntl(STDIN, F_SETFL, fcntl(STDIN, F_GETFL) | O_NONBLOCK);
}

void block_stdin(){
    fcntl(STDIN, F_SETFL, fcntl(STDIN, F_GETFL) & (~O_NONBLOCK));
}

// Game dimensions
// Enums are kinda like structs but compile-time (constant)
enum Game{
    width = 32,
    height = 16
}

// 2D integer vector
struct vec2 {
    int32 x;
    int32 y;
}

vec2 snake[Game.width * Game.height];
vec2 last_direction;
uint snake_length;

vec2 food;

// Get the player's direction using input
bool get_direction(){
    char input[16];
    int sz = read(STDIN, input, 16);

    @return = false;
    if(sz <= 0)
        return;

    char c = input[sz-1];

    if(c == 'w' && !last_direction.y)
        last_direction = vec2{0, -1};
    else if(c == 's' && !last_direction.y)
        last_direction = vec2{0, 1};
    else if(c == 'a' && !last_direction.x)
        last_direction = vec2{-1, 0};
    else if(c == 'd' && !last_direction.x)
        last_direction = vec2{1, 0};
    else if(c == 'q')
        @return = true;
}

// Give food a random position
void generate_food(){
    food = vec2{randint(0, Game.width), randint(0, Game.height)};
    vec2* body = snake;
    for(uint i = 0; i < snake_length; ++i){
        // If food is on a snake's body part, try again
        // Repeat until food is no longer colliding with snake
        if(food.x == body.x && food.y == body.y){
            food = vec2{randint(0, Game.width), randint(0, Game.height)};
            body = snake;
            i = 0;
        }
        body += sizeof(vec2);
    }
}

void init_game(){
    memset(snake, 0, Game.width * Game.height * sizeof(vec2));
    snake[0] = vec2{Game.width / 2, Game.height / 2};
    snake_length = 1;
    last_direction = vec2{0, 0};
    generate_food();
}

void draw_game(){
    char screen[Game.width * Game.height];
    memset(screen, ' ', Game.width * Game.height);

    vec2* body = snake;

    // Draw the head of the snake, pointing
    // to where it is heading
    if(last_direction.x > 0)
        screen[body.x + body.y * Game.width] = '>';
    else if(last_direction.x < 0)
        screen[body.x + body.y * Game.width] = '<';
    else if(last_direction.y < 0)
        screen[body.x + body.y * Game.width] = '^';
    else
        screen[body.x + body.y * Game.width] = 'v';
    body += sizeof(vec2);

    // Put a '@' where every body part of the snake is
    vec2* last_body = snake;
    repeat(snake_length - 1){
        if(body.x - last_body.x)
            screen[body.x + body.y * Game.width] = '-';
        else
            screen[body.x + body.y * Game.width] = '|';
        body += sizeof(vec2);
        last_body += sizeof(vec2);
    }

    // Put a 'o' where the food is
    screen[food.x + food.y * Game.width] = 'o';

    // Draw the screen, line by line
    char* ptr = screen;
    print("\x1b[2J\x1b[H");     // Clear the screen
    println("+%*c+", Game.width, '=');
    repeat(Game.height){
        println("|%*s|", Game.width, ptr);
        ptr += Game.width;
    }
    println("+%*c+", Game.width, '=');
}

int main(uint argc, char** argv){
    termios old_term;
    termios new_term;

    // Save the old TTY
    tcgetattr(STDIN, &old_term);

    // Setup the new TTY
    // This will make the terminal give input instantly
    new_term = old_term;
    new_term.c_lflag = new_term.c_lflag & ~(ICANON | ECHO);
    tcsetattr(STDIN, TCSANOW, &new_term);

    // Set stdin to non-blocking
    nonblock_stdin();

    // Initialize the game state
    init_game();

    float now = time();
    float last_frame = now - 0.1;

    // Game loop
    bool gameover = false;
    loop{
        draw_game();

        now = time();
        println("SCORE: %04%APress q to quit.", snake_length, Game.width - 16);
        last_frame = now;

        // Update the head's direction
        gameover = get_direction();

        // Move every body part of the snake
        // to the position of the one in front of it
        // We can optimize this by using memmove()
        if(snake_length > 1)
            memmove((uint8*)snake + sizeof(vec2), (uint8*)snake, (snake_length - 1) * sizeof(vec2));

        // Move the head
        snake.x += last_direction.x;
        snake.y += last_direction.y;

        // Collision check with borders
        if(snake.x < 0 || snake.x >= Game.width || snake.y < 0 || snake.y >= Game.height)
            gameover = true;

        // Collision check with the snake's body
        vec2* body = snake + sizeof(vec2);
        repeat(snake_length - 1){
            if(snake.x == body.x && snake.y == body.y){
                gameover = true;
                break;
            }
            body += sizeof(vec2);
        }

        // Check if we eat the food
        if(snake.x == food.x && snake.y == food.y){
            snake[snake_length++] = snake[snake_length-2];
            generate_food();
        }

        // Wait for 0.075 seconds
        // Gives us ~13 FPS
        sleep(0.075);

        // Game over screen
        if(gameover){
            print("> GAME OVER <\nPlay again? (y/n) ");
            flush_stdout();

            // Read every character of input left in STDIN
            read(STDIN, NULL, 64);

            // Restore old STDIN setup for prompt
            block_stdin();
            tcsetattr(STDIN, TCSANOW, &old_term);

            sleep(0.25); // Wait to let their loss simmer in the bottom of their soul

            if(to_lower(input_char()) != 'y')
                return;

            // To continue playing, we reinitialize the game
            // and we restore the new STDIN setup
            init_game();
            gameover = false;
            nonblock_stdin();
            tcsetattr(STDIN, TCSANOW, &new_term);
        }
    }
}
