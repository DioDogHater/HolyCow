#include "../../libc/stdio.hhc"
#include "../../libc/math.hhc"
#include "raylib.hhc"
#include "raymath.hc"

double FP_PRECISION = EPSILON;

int main(uint argc, char** argv){
    InitWindow(500, 500, "Hello world!");

    SetTargetFPS(60);

    Camera cam = Camera{
        Vector3{0.0, 2.5, -5.0}, // position
        Vector3{0.0, 0.0, 0.0}, // target
        Vector3{0.0, 1.0, 0.0}, // up
        60.0,                   // fovy
        0                       // perspective
    };

    loop{
        if(WindowShouldClose())
            break;

        UpdateCamera(&cam, 2);

        BeginDrawing();
            ClearBackground(BLACK);
            BeginMode3D(cam);
                DrawCube(Vector3{0.0, 0.0, 0.0}, 1.0, 1.0, 1.0, WHITE);
                DrawSphere(Vector3{0.5, 0.5, 0.5}, 0.25, RED);
                DrawCylinder(Vector3{2.0, -0.5, 0.0}, 0.25, 0.5, 1.0, 16, GRAY);
                DrawLine3D(Vector3{0.5, 0.5, 0.5}, Vector3{2.0, 1.0, 0.0}, GREEN);
                DrawSphereWires(Vector3{2.0, 1.0, 0.0}, 0.25, 8, 8, DARKGREEN);
            EndMode3D();
            DrawText("Hello world!", 0, 20, 20, BLUE);
            DrawFPS(0, 0);
        EndDrawing();
    }

    CloseWindow();
}
