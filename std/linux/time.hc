#include "syscall.hhc"

struct timespec {
    uint tv_sec  = 0;   /* Seconds*/
    uint tv_nsec = 0;   /* Nanoseconds */
}

int nanosleep(timespec* rqtp, timespec* rmtp = NULL){
    return syscall2(35, (uint) rqtp, (uint) rmtp);
}

// Sleep in seconds
void sleep(double seconds){
    timespec ts = timespec{seconds, seconds % 1.0 * 1000000000.0};
    nanosleep(&ts);
}

// Sleep in milliseconds
void msleep(uint msec){
    timespec ts = timespec{msec / 1000, msec % 1000 * 1000000};
    nanosleep(&ts);
}

// Sleep in microseconds
void usleep(uint usec){
    timespec ts = timespec{usec / 1000000, usec % 1000000 * 1000};
    nanosleep(&ts);
}

#define CLOCK_REALTIME 0
// Get time since the Epoch as a timespec
int clock_gettime(uint clock = CLOCK_REALTIME, timespec* tp){
    return syscall2(228, clock, (uint) tp);
}

// Get time since the Epoch, in seconds
double time(){
    timespec tp;
    clock_gettime(,&tp);
    return (double)tp.tv_sec + (double)tp.tv_nsec / 1000000000.0;
}
