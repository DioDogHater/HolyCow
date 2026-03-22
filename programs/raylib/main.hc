#include "../../libc/stdio.hhc"
#include "../../libc/math.hhc"
#include "raylib.hhc"
#include "raymath.hc"

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

    loop{
        if(WindowShouldClose())
            break;

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
                DrawLine3D(Vector3{0.5, 0.5, 0.5}, Vector3{2.0, 1.0, 0.0}, GREEN);
                DrawSphereWires(Vector3{2.0, 1.0, 0.0}, 0.25, 8, 8, DARKGREEN);

                // 3D Grid
                DrawGrid(32, 2.0);
            EndMode3D();

            // FPS counter in top-left corner
            DrawFPS(0, 0);

            // Test text
            DrawText("Hello world!", 0, 20, 20, BLUE);
        EndDrawing();
    }

    CloseWindow();
}
