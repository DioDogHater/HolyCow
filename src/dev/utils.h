#ifndef HCC_UTILS_H
#define HCC_UTILS_H

#define MIN(x, y) ((x) < (y) ? (x) : (y))
#define MIN3(x,y,z) (MIN(MIN(x,y),z))
#define MAX(x, y) ((x) > (y) ? (x) : (y))
#define MAX3(x,y,z) (MAX(MAX(x,y),z))
#define ABS(x) (((x) < 0) ? -(x) : (x))
#define CLAMP(x,a,b) (MIN(MAX(x,a),b))

#define KB 1024
#define MB 1048576

#endif
