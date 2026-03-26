
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

#define RMAPI @cfunc

// Clamp float value
RMAPI float Clamp(float value, float min, float max);

// Calculate linear interpolation between two floats
RMAPI float Lerp(float start, float end, float amount);

// Normalize input value within input range
RMAPI float Normalize(float value, float start, float end);

// Remap input value within input range to output range
RMAPI float Remap(float value, float inputStart, float inputEnd, float outputStart, float outputEnd);

// Wrap input value from min to max
RMAPI float Wrap(float value, float min, float max);

#define Vector2Zero Vector2{0.0, 0.0}
#define Vector2One Vector2{1.0, 1.0}

// Add two vectors (v1 + v2)
RMAPI Vector2 Vector2Add(Vector2 v1, Vector2 v2);

// Add vector and float value
RMAPI Vector2 Vector2AddValue(Vector2 v, float add);

// Subtract two vectors (v1 - v2)
RMAPI Vector2 Vector2Subtract(Vector2 v1, Vector2 v2);

// Subtract vector by float value
RMAPI Vector2 Vector2SubtractValue(Vector2 v, float sub);

// Calculate vector length
RMAPI float Vector2Length(Vector2 v);

// Calculate vector square length
RMAPI float Vector2LengthSqr(Vector2 v);

// Calculate two vectors dot product
RMAPI float Vector2DotProduct(Vector2 v1, Vector2 v2);

// Calculate distance between two vectors
RMAPI float Vector2Distance(Vector2 v1, Vector2 v2);

// Calculate square distance between two vectors
RMAPI float Vector2DistanceSqr(Vector2 v1, Vector2 v2);

// Calculate angle between two vectors
// NOTE: Angle is calculated from origin point (0, 0)
RMAPI float Vector2Angle(Vector2 v1, Vector2 v2);

// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle
RMAPI float Vector2LineAngle(Vector2 start, Vector2 end);

// Scale vector (multiply by value)
RMAPI Vector2 Vector2Scale(Vector2 v, float scale);

// Multiply vector by vector
RMAPI Vector2 Vector2Multiply(Vector2 v1, Vector2 v2);

// Negate vector
RMAPI Vector2 Vector2Negate(Vector2 v);

// Divide vector by vector
RMAPI Vector2 Vector2Divide(Vector2 v1, Vector2 v2);

// Normalize provided vector
RMAPI Vector2 Vector2Normalize(Vector2 v);

// Transforms a Vector2 by a given Matrix
RMAPI Vector2 Vector2Transform(Vector2 v, Matrix mat);

// Calculate linear interpolation between two vectors
RMAPI Vector2 Vector2Lerp(Vector2 v1, Vector2 v2, float amount);

// Calculate reflected vector to normal
RMAPI Vector2 Vector2Reflect(Vector2 v, Vector2 normal);

// Get min value for each pair of components
RMAPI Vector2 Vector2Min(Vector2 v1, Vector2 v2);

// Get max value for each pair of components
RMAPI Vector2 Vector2Max(Vector2 v1, Vector2 v2);

// Rotate vector by angle
RMAPI Vector2 Vector2Rotate(Vector2 v, float angle);

// Move Vector towards target
RMAPI Vector2 Vector2MoveTowards(Vector2 v, Vector2 target, float maxDistance);

// Invert the given vector
RMAPI Vector2 Vector2Invert(Vector2 v);

// Clamp the components of the vector between
// min and max values specified by the given vectors
RMAPI Vector2 Vector2Clamp(Vector2 v, Vector2 min, Vector2 max);

// Clamp the magnitude of the vector between two min and max values
RMAPI Vector2 Vector2ClampValue(Vector2 v, float min, float max);

// Check whether two given vectors are almost equal
RMAPI bool Vector2Equals(Vector2 v1, Vector2 v2);

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface
RMAPI Vector2 Vector2Refract(Vector2 v, Vector2 n, float r);
