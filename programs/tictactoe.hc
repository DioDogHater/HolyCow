#include "std/stdlib.hhc"

char board[9];
char player = ' ';

#define STATE_TURN  0
#define STATE_GAME  1
#define STATE_END   2
uint state = STATE_TURN;

void init(){
    memset(board, ' ', 9);
    player = ' ';
}

void print_board(){
    char* ptr = board;
    uint i = 0;
    println("  A   B   C");
    repeat(3){
        if(i){ println("  %*c", 10, '-'); }
        println("%u %c | %c | %c", ++i, *ptr, *(++ptr), *(++ptr));
        ++ptr;
    }
}

bool check_win(char pl){
    uint i = 0;
    repeat(3){
        if(board[i] == pl && board[i+1] == pl && board[i+2] == pl){
            return true;
        }
        i += 3;
    }
    i = 0;
    repeat(3){
        if(board[i] == pl && board[3+i] == pl && board[6+i] == pl){
            return true;
        }
        ++i;
    }
    if(board[0] == pl && board[4] == pl && board[8] == pl){
        return true;
    }
    if(board[2] == pl && board[4] == pl && board[6] == pl){
        return true;
    }
    return false;
}

bool check_tie(){
    char* ptr = board;
    repeat(9){
        if(*ptr == ' '){ return false; }
        ++ptr;
    }
    return true;
}

int main(uint argc, char** argv){
    char buffer[16];

    // Initialize the game
    init();

    println("Controls:\nEnter 'q' to leave.\nEnter the row number + column letter to choose a square to fill.\n");

    // Game loop
    loop{
        if(state == STATE_TURN){
            // Switch player
            if(player == 'X'){ player = 'O'; }
            else{ player = 'X'; }

            // Display new board and turn
            print_board();
            println("TURN: %c", player);
            state = STATE_GAME;
        }else if(state == STATE_GAME){
            // Get input
            int n = input(buffer, 16);
            if(*buffer == 'q'){ break; }
            if(n != 2 || !is_num(*buffer) || !is_alpha(*(buffer+1))){
                println("Invalid input! Enter the row number + column letter.\nEX: 2C");
                continue;
            }

            // Check if the row and column are ok
            int row = *buffer - '1';
            int col = to_lower(*(buffer+1)) - 'a';
            if(row < 0 || row > 2 || col < 0 || col > 2){
                println("(%i, %i) is not a valid coordinate!", row, col);
                continue;
            }

            // Check if the coordinate is empty
            if(board[row*3+col] != ' '){
                println("(%i, %i) is full!", row, col);
                continue;
            }

            // Set the coordinate to the player's symbol
            board[row*3+col] = player;
            if(check_win(player)){ state = STATE_END; }
            else if(check_tie()){ state = STATE_END; }
            else{ state = STATE_TURN; }
        }else{
            print_board();
            println("\n<< GAME OVER! >>\n- Play again? (y/n) -");
            if(to_lower(input_char()) == 'y'){
                init();
                state = STATE_TURN;
            }else{
                break;
            }
        }
    }

    println("Thank you for playing! :)");

    return 0;
}
