#include "../../libc/stdio.hhc"
#include "../../libc/stdlib.hhc"
#include "../../libc/math.hhc"
#include "raylib.hhc"
#include "raymath.hhc"

double FP_PRECISION = EPSILON;

int main(uint argc, char** argv){
    InitWindow(500, 500, "Hello world!");

    SetTargetFPS(60);

    Camera cam = Camera{
        Vector3{0.0, 2.5, -5.0},      // position
        Vector3{0.0, 0.0, 0.0},       // target
        Vector3{0.0, 1.0, 0.0},       // up
        60.0,                         // fovy
        CameraProjection.PERSPECTIVE  // perspective
    };

    float angle = 0.5;

    loop{
        if(WindowShouldClose())
            break;

        float delta = GetFrameTime();

        UpdateCamera(&cam, CameraMode.ORBITAL);

        BeginDrawing();
            ClearBackground(BLACK);
            BeginMode3D(cam);
                // Cube and sphere
                DrawCube(Vector3{0.0, 0.0, 0.0}, 1.0, 1.0, 1.0, WHITE);
                DrawSphere(Vector3{0.5, 0.5, 0.5}, 0.25, RED);

                // Podium looking thing
                DrawCylinder(Vector3{2.0, -0.5, 0.0}, 0.25, 0.5, 1.0, 16, GRAY);

                // Orb and line connect orb to red sphere
                Vector3 orb = Vector3{2.0, sinf(2.0 * GetTime()) * 0.1 + 1.0, 0.0};

                DrawLine3D(Vector3{0.5, 0.5, 0.5}, orb, GREEN);
                DrawSphereWires(orb, 0.25, 8, 8, DARKGREEN);
                DrawSphere(orb, 0.05, GREEN);

                // 3D Grid
                DrawGrid(32, 2.0);

                // Spinning sphere
                Vector3 v = Vector3Add(Vector3{0.5, 0.0, 0.0}, Vector3RotateByAxisAngle(Vector3{0.0, 0.0, 2.5}, Vector3{0.0, 1.0, 0.0}, angle));
                angle += 5.0 * delta;
                DrawSphere(v, 0.25, BLUE);
            EndMode3D();

            // FPS counter in top-left corner
            DrawFPS(0, 0);

            // Test text
            DrawText("Hello world!", 0, 20, 20, BLUE);
        EndDrawing();
    }

    CloseWindow();
}
