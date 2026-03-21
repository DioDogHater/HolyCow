
#include "../../libc/math.hhc"

extern double FP_PRECISION;

#define PI 3.14159265358979323846
#define EPSILON 0.000001
#define DEG2RAD (PI/180.0)
#define RAD2DEG (180.0/PI)

struct float3 {
    float v[3];
}

struct float16 {
    float v[16];
}

#define RMAPI

// Clamp float value
RMAPI float Clamp(float value, float min, float max){
    @return = value;
    if(value < min)
        @return = min;
    if(value > max)
        @return = max;
}

// Calculate linear interpolation between two floats
RMAPI float Lerp(float start, float end, float amount){
    @return = start + amount * (end - start);
}

// Normalize input value within input range
RMAPI float Normalize(float value, float start, float end){
    @return = (value - start) / (end - start);
}

// Remap input value within input range to output range
RMAPI float Remap(float value, float inputStart, float inputEnd, float outputStart, float outputEnd){
    @return = (value - inputStart)/(inputEnd - inputStart)*(outputEnd - outputStart) + outputStart;
}

// Wrap input value from min to max
RMAPI float Wrap(float value, float min, float max){
    @return = value - (max - min)*floorf((value - min)/(max - min));
}

#define Vector2Zero Vector2{0.0, 0.0}
#define Vector2One Vector2{1.0, 1.0}

// Add two vectors (v1 + v2)
RMAPI Vector2 Vector2Add(Vector2 v1, Vector2 v2){
    @return.x = v1.x + v2.x;
    @return.y = v1.y + v2.y;
}

// Add vector and float value
RMAPI Vector2 Vector2AddValue(Vector2 v, float add){
    @return.x = v.x + add;
    @return.y = v.y + add;
}

// Subtract two vectors (v1 - v2)
RMAPI Vector2 Vector2Subtract(Vector2 v1, Vector2 v2){
    @return.x = v1.x - v2.x;
    @return.y = v1.y - v2.y;
}

// Subtract vector by float value
RMAPI Vector2 Vector2SubtractValue(Vector2 v, float sub){
    @return.x = v.x - sub;
    @return.y = v.y - sub;
}

// Calculate vector length
RMAPI float Vector2Length(Vector2 v){
    @return = hypot(v.x, v.y);
}

// Calculate vector square length
RMAPI float Vector2LengthSqr(Vector2 v){
    @return = v.x*v.x + v.y*v.y;
}

// Calculate two vectors dot product
RMAPI float Vector2DotProduct(Vector2 v1, Vector2 v2){
    @return = v1.x*v2.x + v1.y*v2.y;
}

// Calculate distance between two vectors
RMAPI float Vector2Distance(Vector2 v1, Vector2 v2){
    @return = hypot(v1.x - v2.x, v1.y - v2.y);
}

// Calculate square distance between two vectors
RMAPI float Vector2DistanceSqr(Vector2 v1, Vector2 v2){
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    @return = dx*dx + dy*dy;
}

// Calculate angle between two vectors
// NOTE: Angle is calculated from origin point (0, 0)
RMAPI float Vector2Angle(Vector2 v1, Vector2 v2){
    float dot = v1.x*v2.x + v1.y*v2.y;
    float det = v1.x*v2.y - v1.y*v2.x;
    @return = atan2f(det, dot);
}

// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle
RMAPI float Vector2LineAngle(Vector2 start, Vector2 end){
    // TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior
    @return = -atan2f(end.y - start.y, end.x - start.x);
}

// Scale vector (multiply by value)
RMAPI Vector2 Vector2Scale(Vector2 v, float scale){
    @return.x = v.x*scale;
    @return.y = v.y*scale;
}

// Multiply vector by vector
RMAPI Vector2 Vector2Multiply(Vector2 v1, Vector2 v2){
    @return.x = v1.x*v2.x;
    @return.y = v1.y*v2.y;
}

// Negate vector
RMAPI Vector2 Vector2Negate(Vector2 v){
    @return.x = -v.x;
    @return.y = -v.y;
}

// Divide vector by vector
RMAPI Vector2 Vector2Divide(Vector2 v1, Vector2 v2){
    @return.x = v1.x / v2.x;
    @return.y = v1.y / v2.y;
}

// Normalize provided vector
RMAPI Vector2 Vector2Normalize(Vector2 v){
    *@return = Vector2Zero;
    float length = hypot(v.x, v.y);

    if(length > 0.0){
        float ilength = 1.0 / length;
        @return.x = v.x * ilength;
        @return.y = v.y * ilength;
    }
}

// Transforms a Vector2 by a given Matrix
RMAPI Vector2 Vector2Transform(Vector2 v, Matrix mat){
    float x = v.x;
    float y = v.y;

    @return.x = mat.m[0]*x + mat.m[1]*y + mat.m[3];
    @return.y = mat.m[4]*x + mat.m[5]*y + mat.m[7];
}

// Calculate linear interpolation between two vectors
RMAPI Vector2 Vector2Lerp(Vector2 v1, Vector2 v2, float amount){
    @return.x = v1.x + amount * (v2.x - v1.x);
    @return.y = v1.y + amount * (v2.y - v1.y);
}

// Calculate reflected vector to normal
RMAPI Vector2 Vector2Reflect(Vector2 v, Vector2 normal){
    float dotProduct = (v.x*normal.x + v.y*normal.y); // Dot product
    @return.x = v.x - (2.0 * normal.x) * dotProduct;
    @return.y = v.y - (2.0 * normal.y) * dotProduct;
}

// Get min value for each pair of components
RMAPI Vector2 Vector2Min(Vector2 v1, Vector2 v2){
    @return.x = fminf(v1.x, v2.x);
    @return.y = fminf(v1.y, v2.y);
}

// Get max value for each pair of components
RMAPI Vector2 Vector2Max(Vector2 v1, Vector2 v2){
    @return.x = fmaxf(v1.x, v2.x);
    @return.y = fmaxf(v1.y, v2.y);
}

// Rotate vector by angle
RMAPI Vector2 Vector2Rotate(Vector2 v, float angle){
    float cosres = cosf(angle);
    float sinres = sinf(angle);

    @return.x = v.x * cosres - v.y * sinres;
    @return.y = v.x * sinres + v.y * cosres;
}

// Move Vector towards target
RMAPI Vector2 Vector2MoveTowards(Vector2 v, Vector2 target, float maxDistance){
    float dx = target.x - v.x;
    float dy = target.y - v.y;
    float dist = hypot(dx, dy);

    if((dist == 0.0) || ((maxDistance >= 0.0) && (dist <= maxDistance)))
        return target;

    @return.x = v.x + dx / dist * maxDistance;
    @return.y = v.y + dy / dist * maxDistance;
}

// Invert the given vector
RMAPI Vector2 Vector2Invert(Vector2 v){
    @return = 1.0 / v.x;
    @return = 1.0 / v.y;
}

// Clamp the components of the vector between
// min and max values specified by the given vectors
RMAPI Vector2 Vector2Clamp(Vector2 v, Vector2 min, Vector2 max){
    @return.x = fminf(max.x, fmaxf(min.x, v.x));
    @return.y = fminf(max.y, fmaxf(min.y, v.y));
}

// Clamp the magnitude of the vector between two min and max values
RMAPI Vector2 Vector2ClampValue(Vector2 v, float min, float max){
    float length = hypot(v.x, v.y);
    if (length > 0.0){
        float scale = 1.0;    // By default, 1 as the neutral element.
        if (length < min)
            scale = min / length;
        else if (length > max)
            scale = max / length;

        @return.x = v.x*scale;
        @return.y = v.y*scale;
    }
}

// Check whether two given vectors are almost equal
RMAPI bool Vector2Equals(Vector2 v1, Vector2 v2){
    @return = (v1.x ~= v2.x) && (v1.y ~= v2.y);
}

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface
RMAPI Vector2 Vector2Refract(Vector2 v, Vector2 n, float r){
    *@return = Vector2Zero;
    float dot = v.x*n.x + v.y*n.y;
    float d = 1.0 - r*r * (1.0 - dot*dot);

    if (d >= 0.0){
        d = sqrtf(d);
        @return.x = r*v.x - (r*dot + d)*n.x;
        @return.y = r*v.y - (r*dot + d)*n.y;
    }
}
