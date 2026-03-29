section .text
BITS 64
CPU X64
default ABS
global _start
_start:
	fninit
	mov rax, [rsp+0]
	lea rbx, [rsp+8]
	sub rsp, 32
	mov QWORD [rsp], 0
	mov [rsp+8], rax
	mov [rsp+16], rbx
	call main
	mov rax, 60
	mov rdi, [rsp]
	syscall

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rdx, STR0
	mov rsi, 0x1f4
	mov rdi, 0x1f4
	call InitWindow
	mov rdi, 0x3c
	call SetTargetFPS
	lea rbx, [rsp+4]
	lea r8, [rbx+0]
	fld QWORD [FP0]
	fstp DWORD [r8+0]
	fld QWORD [FP1]
	fstp DWORD [r8+4]
	mov DWORD [__FP_TMP], 0xc0a00000
	fld DWORD [__FP_TMP]
	fstp DWORD [r8+8]
	lea r8, [rbx+12]
	fld QWORD [FP0]
	fstp DWORD [r8+0]
	fld QWORD [FP0]
	fstp DWORD [r8+4]
	fld QWORD [FP0]
	fstp DWORD [r8+8]
	lea r8, [rbx+24]
	fld QWORD [FP0]
	fstp DWORD [r8+0]
	fld QWORD [FP2]
	fstp DWORD [r8+4]
	fld QWORD [FP0]
	fstp DWORD [r8+8]
	fld QWORD [FP3]
	fstp DWORD [rbx+36]
	xor ecx, ecx
	mov [rbx+40], ecx
	fld QWORD [FP4]
	fstp DWORD [rsp+0]
	sub rsp, 32
	.L1:
	sub rsp, 16
	call WindowShouldClose
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L3
	jmp .L2
	jmp .L4
	.L3:
	.L4:
	sub rsp, 16
	call GetFrameTime
	movss DWORD [rsp+0], xmm0
	fld DWORD [rsp+0]
	add rsp, 16
	fstp DWORD [rsp+28]
	mov rsi, 0x2
	lea rdi, [rsp+36]
	call UpdateCamera
	call BeginDrawing
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	xor cl, cl
	mov [rbx+1], cl
	xor cl, cl
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	call ClearBackground
	sub rsp, 48
	lea rbx, [rsp+0]
	cld
	mov rdi, rbx
	lea rsi, [rsp+84]
	mov rcx, 11
	rep movsd
	call BeginMode3D
	add rsp, 48
	lea rbx, [__GP_TMP]
	mov cl, 0xff
	mov [rbx+0], cl
	mov cl, 0xff
	mov [rbx+1], cl
	mov cl, 0xff
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	fld QWORD [FP2]
	fstp DWORD [__FP_TMP]
	movss xmm4, DWORD [__FP_TMP+0]
	fld QWORD [FP2]
	fstp DWORD [__FP_TMP]
	movss xmm3, DWORD [__FP_TMP+0]
	fld QWORD [FP2]
	fstp DWORD [__FP_TMP]
	movss xmm2, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP0]
	fstp DWORD [rbx+0]
	fld QWORD [FP0]
	fstp DWORD [rbx+4]
	fld QWORD [FP0]
	fstp DWORD [rbx+8]
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawCube
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	fld QWORD [FP5]
	fstp DWORD [__FP_TMP]
	movss xmm2, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP4]
	fstp DWORD [rbx+0]
	fld QWORD [FP4]
	fstp DWORD [rbx+4]
	fld QWORD [FP4]
	fstp DWORD [rbx+8]
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawSphere
	lea rbx, [__GP_TMP]
	mov cl, 0x82
	mov [rbx+0], cl
	mov cl, 0x82
	mov [rbx+1], cl
	mov cl, 0x82
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rsi, QWORD [__GP_TMP+0]
	mov rdi, 0x10
	fld QWORD [FP2]
	fstp DWORD [__FP_TMP]
	movss xmm4, DWORD [__FP_TMP+0]
	fld QWORD [FP4]
	fstp DWORD [__FP_TMP]
	movss xmm3, DWORD [__FP_TMP+0]
	fld QWORD [FP5]
	fstp DWORD [__FP_TMP]
	movss xmm2, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP6]
	fstp DWORD [rbx+0]
	mov DWORD [__FP_TMP], 0xbf000000
	fld DWORD [__FP_TMP]
	fstp DWORD [rbx+4]
	fld QWORD [FP0]
	fstp DWORD [rbx+8]
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawCylinder
	lea rbx, [rsp+16]
	fld QWORD [FP6]
	fstp DWORD [rbx+0]
	sub rsp, 16
	mov [rsp+8], rbx
	fld QWORD [FP6]
	sub rsp, 16
	mov [rsp+8], rax
	call GetTime
	movsd QWORD [rsp+0], xmm0
	mov rax, [rsp+8]
	fld QWORD [rsp+0]
	add rsp, 16
	fmulp
	fstp DWORD [__FP_TMP]
	movss xmm0, DWORD [__FP_TMP+0]
	call sinf
	movss DWORD [rsp+0], xmm0
	mov rbx, [rsp+8]
	fld DWORD [rsp+0]
	add rsp, 16
	fld QWORD [FP7]
	fmulp
	fld QWORD [FP2]
	faddp
	fstp DWORD [rbx+4]
	fld QWORD [FP0]
	fstp DWORD [rbx+8]
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	mov cl, 0xe4
	mov [rbx+1], cl
	mov cl, 0x30
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	lea rbx, [__GP_TMP]
	mov r8, rdi
	cld
	mov rdi, rbx
	lea rsi, [rsp+16]
	mov rcx, 3
	rep movsd
	mov rdi, r8
	movss xmm3, DWORD [__GP_TMP+8]
	movsd xmm2, QWORD [__GP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP4]
	fstp DWORD [rbx+0]
	fld QWORD [FP4]
	fstp DWORD [rbx+4]
	fld QWORD [FP4]
	fstp DWORD [rbx+8]
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawLine3D
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	mov cl, 0x75
	mov [rbx+1], cl
	mov cl, 0x2c
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdx, QWORD [__GP_TMP+0]
	mov rsi, 0x8
	mov rdi, 0x8
	fld QWORD [FP5]
	fstp DWORD [__FP_TMP]
	movss xmm2, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	mov r8, rsi
	mov r9, rdi
	cld
	mov rdi, rbx
	lea rsi, [rsp+16]
	mov rcx, 3
	rep movsd
	mov rsi, r8
	mov rdi, r9
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawSphereWires
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	mov cl, 0xe4
	mov [rbx+1], cl
	mov cl, 0x30
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	fld QWORD [FP8]
	fstp DWORD [__FP_TMP]
	movss xmm2, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	mov r8, rdi
	cld
	mov rdi, rbx
	lea rsi, [rsp+16]
	mov rcx, 3
	rep movsd
	mov rdi, r8
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawSphere
	fld QWORD [FP6]
	fstp DWORD [__FP_TMP]
	movss xmm0, DWORD [__FP_TMP+0]
	mov rdi, 0x20
	call DrawGrid
	lea rbx, [rsp+4]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	sub rsp, 16
	mov [rsp+8], rbx
	mov [rsp+0], rax
	fld DWORD [rsp+64]
	fstp DWORD [__FP_TMP]
	movss xmm4, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP0]
	fstp DWORD [rbx+0]
	fld QWORD [FP2]
	fstp DWORD [rbx+4]
	fld QWORD [FP0]
	fstp DWORD [rbx+8]
	movss xmm3, DWORD [__GP_TMP+8]
	movsd xmm2, QWORD [__GP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP0]
	fstp DWORD [rbx+0]
	fld QWORD [FP0]
	fstp DWORD [rbx+4]
	fld QWORD [FP1]
	fstp DWORD [rbx+8]
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call Vector3RotateByAxisAngle
	mov rbx, [rsp+8]
	movsd QWORD [rbx+0], xmm0
	movss DWORD [rbx+8], xmm1
	mov rax, [rsp+0]
	add rsp, 16
	movss xmm3, DWORD [__GP_TMP+8]
	movsd xmm2, QWORD [__GP_TMP+0]
	lea rbx, [__GP_TMP]
	fld QWORD [FP4]
	fstp DWORD [rbx+0]
	fld QWORD [FP0]
	fstp DWORD [rbx+4]
	fld QWORD [FP0]
	fstp DWORD [rbx+8]
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call Vector3Add
	mov rbx, [rsp+8]
	movsd QWORD [rbx+0], xmm0
	movss DWORD [rbx+8], xmm1
	add rsp, 16
	fld DWORD [rsp+32]
	fld QWORD [FP9]
	fld DWORD [rsp+28]
	fmulp
	faddp
	fstp DWORD [rsp+32]
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	mov cl, 0x79
	mov [rbx+1], cl
	mov cl, 0xf1
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	fld QWORD [FP5]
	fstp DWORD [__FP_TMP]
	movss xmm2, DWORD [__FP_TMP+0]
	lea rbx, [__GP_TMP]
	mov r8, rdi
	cld
	mov rdi, rbx
	lea rsi, [rsp+4]
	mov rcx, 3
	rep movsd
	mov rdi, r8
	movss xmm1, DWORD [__GP_TMP+8]
	movsd xmm0, QWORD [__GP_TMP+0]
	call DrawSphere
	call EndMode3D
	xor rsi, rsi
	xor rdi, rdi
	call DrawFPS
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	mov cl, 0x79
	mov [rbx+1], cl
	mov cl, 0xf1
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x14
	mov rdx, 0x14
	xor rsi, rsi
	mov rdi, STR0
	call DrawText
	call EndDrawing
	jmp .L1
	.L2:
	add rsp, 32
	call CloseWindow
	.L0:
	leave
	ret


extern IsMaterialValid:function
extern putc:function
extern Vector4Divide:function
extern SetWindowOpacity:function
extern Vector2Invert:function
extern DrawRing:function
extern ImageCopy:function
extern QuaternionInvert:function
extern IsWindowHidden:function
extern GetScreenWidth:function
extern FileExists:function
extern ImageDrawRectangleRec:function
extern BeginMode3D:function
extern EndBlendMode:function
extern ImageDrawRectangleLines:function
extern UnloadAudioStream:function
extern Vector3MoveTowards:function
extern fputc:function
extern log:function
extern GetFileLength:function
extern ImageDrawTriangleLines:function
extern QuaternionTransform:function
extern ImageDither:function
extern GenMeshKnot:function
extern GetRayCollisionQuad:function
extern WaitTime:function
extern DrawTriangle:function
extern CheckCollisionCircleLine:function
extern LoadModelAnimations:function
extern SetWindowState:function
extern LoadDirectoryFilesEx:function
extern sprintf:function
extern IsMouseButtonReleased:function
extern DrawPixelV:function
extern CheckCollisionPointCircle:function
extern UnloadImage:function
extern GenMeshCube:function
extern GetSplinePointBasis:function
extern ImageDrawTriangle:function
extern Vector2Length:function
extern QuaternionLength:function
extern SetAudioStreamPan:function
extern sin:function
extern cbrt:function
extern GetCurrentMonitor:function
extern ExportDataAsCode:function
extern Vector2AddValue:function
extern QuaternionSubtractValue:function
extern puts:function
extern copysign:function
extern IsGamepadButtonReleased:function
extern IsGamepadButtonUp:function
extern GenMeshCone:function
extern Vector3AddValue:function
extern setstate:function
extern Vector2DotProduct:function
extern Vector3Refract:function
extern Vector4AddValue:function
extern GetRayCollisionTriangle:function
extern QuaternionScale:function
extern CheckCollisionCircles:function
extern IsImageValid:function
extern GetMusicTimePlayed:function
extern Vector2ClampValue:function
extern QuaternionFromMatrix:function
extern fminf:function
extern LoadVrStereoConfig:function
extern DrawPixel:function
extern GetSplinePointLinear:function
extern LoadImageFromMemory:function
extern ImageFromChannel:function
extern ImageAlphaPremultiply:function
extern GetModelBoundingBox:function
extern LoadSoundFromWave:function
extern UnloadMusicStream:function
extern fwrite:function
extern DrawCircleLinesV:function
extern Vector3CrossProduct:function
extern fputs:function
extern DrawSphereEx:function
extern UnloadMaterial:function
extern expf:function
extern coshf:function
extern MakeDirectory:function
extern DrawText:function
extern DrawBillboardRec:function
extern IsAudioDeviceReady:function
extern LoadWave:function
extern Lerp:function
extern log2:function
extern SaveFileText:function
extern ToggleFullscreen:function
extern TextJoin:function
extern ExportWave:function
extern pow:function
extern DrawCircleV:function
extern CheckCollisionCircleRec:function
extern ImageDrawLineEx:function
extern MeasureText:function
extern DrawCubeWires:function
extern rename:function
extern DrawSplineBezierQuadratic:function
extern Vector4Normalize:function
extern DrawRectangleGradientH:function
extern DrawTriangleFan:function
extern Vector2Negate:function
extern hypotf:function
extern IsWindowMinimized:function
extern TextInsert:function
extern TextToSnake:function
extern DrawRay:function
extern GetTouchX:function
extern DrawTriangle3D:function
extern fclose:function
extern RestoreWindow:function
extern SetTargetFPS:function
extern GetTouchY:function
extern CheckCollisionPointLine:function
extern GenImageGradientSquare:function
extern DrawModelEx:function
extern DrawModelPoints:function
extern strtoul:function
extern GetFileExtension:function
extern IsModelValid:function
extern GetMonitorPhysicalHeight:function
extern GetRandomValue:function
extern ImageColorReplace:function
extern TextToFloat:function
extern setvbuf:function
extern LoadAutomationEventList:function
extern GetKeyPressed:function
extern DrawTriangleLines:function
extern ClearWindowState:function
extern DrawCircle:function
extern Vector3Unproject:function
extern random:function
extern ImageColorTint:function
extern TextReplace:function
extern labs:function
extern SetAudioStreamBufferSizeDefault:function
extern ExportImage:function
extern GenImagePerlinNoise:function
extern QuaternionCubicHermiteSpline:function
extern acos:function
extern SetWindowTitle:function
extern GetFileNameWithoutExt:function
extern DrawModelWiresEx:function
extern Vector2DistanceSqr:function
extern DrawRectangleGradientV:function
extern PauseSound:function
extern fflush:function
extern ImageFlipVertical:function
extern GetMonitorName:function
extern SetGesturesEnabled:function
extern GenImageFontAtlas:function
extern atanf:function
extern MemAlloc:function
extern IsFileDropped:function
extern ColorAlphaBlend:function
extern Vector2SubtractValue:function
extern DrawSplineBasis:function
extern CheckCollisionBoxes:function
extern GetGestureHoldDuration:function
extern Vector2Refract:function
extern GetWindowPosition:function
extern ColorToInt:function
extern SetSoundPitch:function
extern Vector2Scale:function
extern fseek:function
extern CheckCollisionPointRec:function
extern UpdateTextureRec:function
extern TextFormat:function
extern WaveCopy:function
extern IsAudioStreamPlaying:function
extern Vector2Add:function
extern QuaternionSubtract:function
extern SetExitKey:function
extern CodepointToUTF8:function
extern StopSound:function
extern sqrtf:function
extern Vector2Distance:function
extern GenImageCellular:function
extern ImageResizeNN:function
extern ImageDraw:function
extern LoadModel:function
extern Vector3Distance:function
extern Vector4Distance:function
extern ColorIsEqual:function
extern UnloadFontData:function
extern UpdateModelAnimation:function
extern SetSoundPan:function
extern LoadImageColors:function
extern DrawSphere:function
extern GetShaderLocationAttrib:function
extern SetTextureWrap:function
extern LoadFont:function
extern DrawCircle3D:function
extern QuaternionNormalize:function
extern malloc:function
extern LoadCodepoints:function
extern Vector2Lerp:function
extern fprintf:function
extern SetWindowPosition:function
extern GetScreenHeight:function
extern ImageDrawLine:function
extern ImageDrawTriangleStrip:function
extern TextIsEqual:function
extern SetModelMeshMaterial:function
extern exit:function
extern Vector4Lerp:function
extern ChangeDirectory:function
extern UnloadCodepoints:function
extern Vector3Divide:function
extern ImageDrawTriangleFan:function
extern DrawTextureEx:function
extern TextToPascal:function
extern WindowShouldClose:function
extern IsGamepadButtonPressed:function
extern IsModelAnimationValid:function
extern Vector3Project:function
extern MatrixSubtract:function
extern ColorTint:function
extern SetTextLineSpacing:function
extern PlaySound:function
extern MatrixLookAt:function
extern LoadWaveFromMemory:function
extern GetWorldToScreen2D:function
extern fread:function
extern GetCodepointPrevious:function
extern IsAudioStreamProcessed:function
extern SetAudioStreamPitch:function
extern ceilf:function
extern log10:function
extern tan:function
extern SetWindowMinSize:function
extern GetMonitorRefreshRate:function
extern DrawRectangle:function
extern BeginVrStereoMode:function
extern GetGestureDragAngle:function
extern GenMeshTorus:function
extern ExportWaveAsCode:function
extern SetWindowMaxSize:function
extern GetMonitorPhysicalWidth:function
extern LoadFileText:function
extern DrawCylinderEx:function
extern SetMusicPitch:function
extern modf:function
extern StopAutomationEventRecording:function
extern TextLength:function
extern logf:function
extern DrawLineStrip:function
extern setbuf:function
extern DisableEventWaiting:function
extern ImageDrawPixelV:function
extern DrawModelWires:function
extern GetShapesTextureRectangle:function
extern DrawPolyLinesEx:function
extern DrawBillboardPro:function
extern Vector3Min:function
extern DrawCircleSectorLines:function
extern UnloadWaveSamples:function
extern fmodf:function
extern InitWindow:function
extern ImageFormat:function
extern GetMeshBoundingBox:function
extern SetMusicPan:function
extern Vector3Max:function
extern QuaternionAddValue:function
extern QuaternionSlerp:function
extern EncodeDataBase64:function
extern DrawLine3D:function
extern MatrixInvert:function
extern Vector3DotProduct:function
extern ImageDrawLineV:function
extern sinf:function
extern GetShaderLocation:function
extern GetGestureDragVector:function
extern Vector3ClampValue:function
extern GetMonitorCount:function
extern GenMeshHemiSphere:function
extern fmaxf:function
extern sinh:function
extern GetMusicTimeLength:function
extern Vector4Equals:function
extern EndShaderMode:function
extern GetMouseDelta:function
extern ColorToHSV:function
extern Vector3Clamp:function
extern GetScreenToWorldRayEx:function
extern GetCameraMatrix2D:function
extern GetCharPressed:function
extern DrawRectangleRounded:function
extern ExportImageAsCode:function
extern UnloadModel:function
extern LoadMaterialDefault:function
extern UnloadModelAnimation:function
extern SetShaderValueMatrix:function
extern GetShapesTexture:function
extern ImageResize:function
extern SeekMusicStream:function
extern Remap:function
extern SetShaderValueV:function
extern GetWorkingDirectory:function
extern DrawTriangleStrip:function
extern LoadShader:function
extern GetTouchPosition:function
extern IsFileExtension:function
extern IsMouseButtonDown:function
extern DrawRingLines:function
extern DrawSplineCatmullRom:function
extern LoadMusicStreamFromMemory:function
extern Wrap:function
extern DrawCapsule:function
extern IsKeyPressedRepeat:function
extern GenImageColor:function
extern ImageDrawRectangleV:function
extern MatrixRotateX:function
extern tgammaf:function
extern UnloadRandomSequence:function
extern SetMouseScale:function
extern UpdateCameraPro:function
extern TextAppend:function
extern IsMusicStreamPlaying:function
extern MatrixRotateY:function
extern GenMeshHeightmap:function
extern MatrixRotateZ:function
extern SetWindowSize:function
extern IsGamepadButtonDown:function
extern SetWindowIcons:function
extern SetShaderValue:function
extern TextCopy:function
extern SetClipboardText:function
extern GetMouseX:function
extern GenMeshCylinder:function
extern floor:function
extern fabsf:function
extern EndScissorMode:function
extern GetMouseY:function
extern Vector4MoveTowards:function
extern ComputeMD5:function
extern ImageDrawCircle:function
extern IsFontValid:function
extern DrawCubeV:function
extern Vector3Reject:function
extern GetGesturePinchVector:function
extern ImageDrawTriangleEx:function
extern LoadFontFromMemory:function
extern OpenURL:function
extern CheckCollisionLines:function
extern DrawCapsuleWires:function
extern LoadDirectoryFiles:function
extern LoadImageAnim:function
extern ExportFontAsCode:function
extern SaveFileData:function
extern IsPathFile:function
extern atof:function
extern ComputeSHA1:function
extern IsKeyReleased:function
extern SetMousePosition:function
extern CheckCollisionPointTriangle:function
extern UnloadUTF8:function
extern TextToCamel:function
extern cosf:function
extern asin:function
extern GetMouseWheelMoveV:function
extern DrawLineV:function
extern Vector4SubtractValue:function
extern atoi:function
extern exp:function
extern cosh:function
extern DrawPolyLines:function
extern ColorContrast:function
extern Vector3Angle:function
extern remove:function
extern LoadTextureCubemap:function
extern DrawRectangleRoundedLines:function
extern Vector4Scale:function
extern MatrixRotateXYZ:function
extern atol:function
extern BeginScissorMode:function
extern GetGamepadName:function
extern ImageAlphaClear:function
extern DrawTextEx:function
extern GetGlyphInfo:function
extern QuaternionIdentity:function
extern strfromd:function
extern cbrtf:function
extern ImageResizeCanvas:function
extern LoadModelFromMesh:function
extern strfromf:function
extern GetClipboardImage:function
extern srandom:function
extern MeasureTextEx:function
extern DrawGrid:function
extern DrawMeshInstanced:function
extern MatrixDecompose:function
extern ImageAlphaMask:function
extern UnloadImagePalette:function
extern Vector3Barycenter:function
extern EndVrStereoMode:function
extern ftell:function
extern tgamma:function
extern LoadImageFromScreen:function
extern GetPixelDataSize:function
extern fopen:function
extern abort:function
extern ColorBrightness:function
extern CloseAudioDevice:function
extern PlayAutomationEvent:function
extern SetGamepadMappings:function
extern CheckCollisionBoxSphere:function
extern Vector2Divide:function
extern QuaternionDivide:function
extern MaximizeWindow:function
extern WaveFormat:function
extern DrawRectangleRec:function
extern ImageAlphaCrop:function
extern ImageColorGrayscale:function
extern IsRenderTextureValid:function
extern MatrixScale:function
extern DrawPlane:function
extern MatrixAdd:function
extern finite:function
extern GetColor:function
extern DrawSphereWires:function
extern Vector4Invert:function
extern MatrixIdentity:function
extern feof:function
extern GetFileName:function
extern GetGamepadButtonPressed:function
extern MatrixOrtho:function
extern free:function
extern GetDirectoryPath:function
extern UnloadAutomationEventList:function
extern GenImageText:function
extern SetAudioStreamVolume:function
extern getc:function
extern IsShaderValid:function
extern LoadShaderFromMemory:function
extern UnloadDroppedFiles:function
extern DrawTextPro:function
extern MatrixTrace:function
extern system:function
extern ImageTextEx:function
extern ColorAlpha:function
extern GetCodepoint:function
extern Vector2Multiply:function
extern fmod:function
extern IsMouseButtonUp:function
extern Vector3Multiply:function
extern ClearBackground:function
extern Vector3DistanceSqr:function
extern Vector4Multiply:function
extern GetMonitorWidth:function
extern UnloadFileText:function
extern fgetc:function
extern IsWindowReady:function
extern GetApplicationDirectory:function
extern Vector4Length:function
extern GetWorldToScreen:function
extern DrawSplineSegmentBezierQuadratic:function
extern GenMeshTangents:function
extern UpdateModelAnimationBones:function
extern IsGamepadAvailable:function
extern UpdateCamera:function
extern Vector3RotateByAxisAngle:function
extern BeginBlendMode:function
extern ImageRotateCCW:function
extern ResumeAudioStream:function
extern Vector3Add:function
extern Vector4DotProduct:function
extern ColorNormalize:function
extern MatrixDeterminant:function
extern fscanf:function
extern LoadRenderTexture:function
extern Normalize:function
extern Vector3Equals:function
extern copysignf:function
extern EndMode2D:function
extern DrawPoly:function
extern UnloadVrStereoConfig:function
extern SetMouseCursor:function
extern hypot:function
extern ImageDrawCircleLinesV:function
extern UpdateTexture:function
extern LoadFontEx:function
extern Vector2Rotate:function
extern Vector3Perpendicular:function
extern SetTraceLogLevel:function
extern DirectoryExists:function
extern IsSoundValid:function
extern Vector3ToFloatV:function
extern abs:function
extern ImageDrawText:function
extern TextToInteger:function
extern InitAudioDevice:function
extern QuaternionFromAxisAngle:function
extern ImageCrop:function
extern sinhf:function
extern UnloadImageColors:function
extern DrawTextCodepoint:function
extern DrawRectangleV:function
extern DrawTextureRec:function
extern DrawBillboard:function
extern log2f:function
extern LoadFileData:function
extern ImageFromImage:function
extern ImageColorInvert:function
extern ImageColorBrightness:function
extern Vector4Negate:function
extern IsWindowMaximized:function
extern DrawEllipse:function
extern GetSplinePointBezierCubic:function
extern PauseAudioStream:function
extern ceil:function
extern IsWindowFocused:function
extern GetMonitorPosition:function
extern DrawTextureNPatch:function
extern Vector2LengthSqr:function
extern ExportMeshAsCode:function
extern ResumeMusicStream:function
extern LoadAudioStream:function
extern QuaternionToMatrix:function
extern MatrixPerspective:function
extern GetRenderWidth:function
extern Vector2MoveTowards:function
extern BeginShaderMode:function
extern MemRealloc:function
extern GetGestureDetected:function
extern GetSplinePointBezierQuad:function
extern ExportImageToMemory:function
extern GetRayCollisionBox:function
extern Vector2Transform:function
extern EndDrawing:function
extern DecodeDataBase64:function
extern SetTextureFilter:function
extern Vector3OrthoNormalize:function
extern atan:function
extern ColorFromHSV:function
extern GetCodepointNext:function
extern StopAudioStream:function
extern GetCollisionRec:function
extern ImageDrawRectangle:function
extern QuaternionToEuler:function
extern LoadUTF8:function
extern floorf:function
extern LoadImageFromTexture:function
extern LoadTextureFromImage:function
extern DrawCylinder:function
extern rewind:function
extern getenv:function
extern log10f:function
extern tanf:function
extern GetFPS:function
extern LoadSound:function
extern IsWindowResized:function
extern ImageClearBackground:function
extern IsAudioStreamValid:function
extern SetAutomationEventList:function
extern DrawTextCodepoints:function
extern GenMeshCubicmap:function
extern PauseMusicStream:function
extern Vector4Min:function
extern MatrixFrustum:function
extern ImageRotateCW:function
extern UpdateSound:function
extern SetWindowIcon:function
extern EndTextureMode:function
extern GetGamepadAxisCount:function
extern LoadImageRaw:function
extern LoadMusicStream:function
extern IsMusicValid:function
extern Vector4Max:function
extern GenMeshSphere:function
extern SetConfigFlags:function
extern ferror:function
extern DrawCircleSector:function
extern UnloadMesh:function
extern BeginDrawing:function
extern LoadImagePalette:function
extern ColorLerp:function
extern UploadMesh:function
extern Vector2Clamp:function
extern printf:function
extern EndMode3D:function
extern DrawSplineSegmentBezierCubic:function
extern ImageBlurGaussian:function
extern ImageDrawTextEx:function
extern LoadSoundAlias:function
extern StopMusicStream:function
extern DrawRectanglePro:function
extern DrawSplineLinear:function
extern UnloadTexture:function
extern UnloadRenderTexture:function
extern TextSubtext:function
extern PlayAudioStream:function
extern initstate:function
extern IsWindowState:function
extern SetAutomationEventBaseFrame:function
extern GetSplinePointCatmullRom:function
extern DrawTextureV:function
extern DrawLine:function
extern UnloadSoundAlias:function
extern Vector3RotateByQuaternion:function
extern putchar:function
extern DrawLineBezier:function
extern DrawEllipseLines:function
extern DrawFPS:function
extern ImageToPOT:function
extern ImageDrawCircleV:function
extern DrawModelPointsEx:function
extern Vector3Lerp:function
extern MinimizeWindow:function
extern GetTouchPointId:function
extern BeginTextureMode:function
extern DrawCircleLines:function
extern DrawMesh:function
extern atan2f:function
extern EnableEventWaiting:function
extern PollInputEvents:function
extern SetMouseOffset:function
extern GenImageWhiteNoise:function
extern GetFontDefault:function
extern GetGlyphIndex:function
extern GetWindowScaleDPI:function
extern IsKeyDown:function
extern IsTextureValid:function
extern sscanf:function
extern DrawRectangleLines:function
extern Vector3LengthSqr:function
extern Vector3Invert:function
extern DrawModel:function
extern GetRayCollisionSphere:function
extern IsWaveValid:function
extern DrawSplineBezierCubic:function
extern GetMonitorHeight:function
extern MemFree:function
extern LoadDroppedFiles:function
extern realloc:function
extern LoadMaterials:function
extern Vector3Transform:function
extern TakeScreenshot:function
extern PlayMusicStream:function
extern GenImageChecked:function
extern CheckCollisionSpheres:function
extern GetMasterVolume:function
extern exp2f:function
extern cos:function
extern GetRayCollisionMesh:function
extern QuaternionToAxisAngle:function
extern ungetc:function
extern QuaternionMultiply:function
extern DrawSplineSegmentLinear:function
extern GetImageAlphaBorder:function
extern WaveCrop:function
extern QuaternionNlerp:function
extern ColorFromNormalized:function
extern Vector3Length:function
extern SetGamepadVibration:function
extern QuaternionFromVector3ToVector3:function
extern fmin:function
extern UpdateMeshBuffer:function
extern scanf:function
extern GenMeshPoly:function
extern Vector3SubtractValue:function
extern Vector3Reflect:function
extern fmax:function
extern SetWindowMonitor:function
extern DrawRectangleRoundedLinesEx:function
extern UnloadSound:function
extern Vector2Angle:function
extern DrawCube:function
extern SetSoundVolume:function
extern StartAutomationEventRecording:function
extern LoadFontFromImage:function
extern Vector3Scale:function
extern freopen:function
extern GetTime:function
extern DrawPoint3D:function
extern QuaternionAdd:function
extern clearerr:function
extern ImageColorContrast:function
extern DrawTexturePro:function
extern SetMasterVolume:function
extern Vector2Equals:function
extern asinf:function
extern SetShaderValueTexture:function
extern LoadTexture:function
extern TextSplit:function
extern TextToLower:function
extern QuaternionEquals:function
extern DrawCylinderWires:function
extern DrawLineEx:function
extern Vector2LineAngle:function
extern MatrixTranspose:function
extern GetClipboardText:function
extern GetMouseWheelMove:function
extern LoadImageAnimFromMemory:function
extern MatrixMultiply:function
extern GetTouchPointCount:function
extern UnloadWave:function
extern Vector2Normalize:function
extern GenMeshPlane:function
extern GetGesturePinchAngle:function
extern GenImageGradientRadial:function
extern GetRenderHeight:function
extern IsSoundPlaying:function
extern UnloadShader:function
extern LoadRandomSequence:function
extern ImageMipmaps:function
extern ResumeSound:function
extern Vector3Negate:function
extern Vector3CubicHermite:function
extern IsKeyPressed:function
extern DrawRectangleLinesEx:function
extern fabs:function
extern powf:function
extern UnloadFileData:function
extern IsGestureDetected:function
extern getchar:function
extern GetCameraMatrix:function
extern GetMousePosition:function
extern DrawSplineSegmentBasis:function
extern ImageDrawCircleLines:function
extern TextFindIndex:function
extern exp2:function
extern GetPrevDirectoryPath:function
extern DrawTexture:function
extern Vector4LengthSqr:function
extern strtod:function
extern BeginMode2D:function
extern GetScreenToWorld2D:function
extern ExportAutomationEventList:function
extern SetShapesTexture:function
extern GetPixelColor:function
extern UpdateAudioStream:function
extern strtof:function
extern GetImageColor:function
extern GenTextureMipmaps:function
extern LoadImage:function
extern MatrixTranslate:function
extern GetWindowHandle:function
extern ImageKernelConvolution:function
extern MatrixRotate:function
extern MatrixToFloatV:function
extern SetMusicVolume:function
extern CompressData:function
extern GenImageGradientLinear:function
extern IsWindowFullscreen:function
extern UnloadModelAnimations:function
extern strtol:function
extern round:function
extern GetWorldToScreenEx:function
extern ImageText:function
extern LoadWaveSamples:function
extern Vector4DistanceSqr:function
extern Vector2Min:function
extern sqrt:function
extern IsKeyUp:function
extern Vector2Reflect:function
extern UnloadDirectoryFiles:function
extern Vector2Max:function
extern strtold:function
extern acosf:function
extern DrawSplineSegmentCatmullRom:function
extern SetMaterialTexture:function
extern SetWindowFocused:function
extern IsFileNameValid:function
extern SetPixelColor:function
extern DrawTriangleStrip3D:function
extern DrawCubeWiresV:function
extern DrawBoundingBox:function
extern Clamp:function
extern Vector2Subtract:function
extern calloc:function
extern roundf:function
extern CloseWindow:function
extern SetRandomSeed:function
extern DrawCircleGradient:function
extern DrawRectangleGradientEx:function
extern GetCodepointCount:function
extern Vector3Subtract:function
extern GetFileModTime:function
extern DecompressData:function
extern GetGamepadAxisMovement:function
extern DrawCylinderWiresEx:function
extern ExportMesh:function
extern Vector4Subtract:function
extern MatrixRotateZYX:function
extern Fade:function
extern UpdateMusicStream:function
extern Vector4Add:function
extern setlinebuf:function
extern TraceLog:function
extern LoadFontData:function
extern ImageRotate:function
extern ImageDrawPixel:function
extern GetGlyphAtlasRec:function
extern snprintf:function
extern TextToUpper:function
extern SwapScreenBuffer:function
extern atan2:function
extern GetScreenToWorldRay:function
extern IsMouseButtonPressed:function
extern CheckCollisionRecs:function
extern Vector3Normalize:function
extern QuaternionFromEuler:function
extern ToggleBorderlessWindowed:function
extern CheckCollisionPointPoly:function
extern ImageFlipHorizontal:function
extern QuaternionLerp:function
extern perror:function
extern GetFrameTime:function
extern ComputeCRC32:function
extern UnloadFont:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0
extern stdin:data
extern stdout:data
extern stderr:data
global FP_PRECISION:data
FP_PRECISION:
dq 0.0000010000


section .rodata
STR0:
db "Hello world!",0
FP0:
dq 0.0
FP1:
dq 2.5
FP2:
dq 1.0
FP3:
dq 60.0
FP4:
dq 0.5
FP5:
dq 0.25
FP6:
dq 2.0
FP7:
dq 0.1
FP8:
dq 0.05
FP9:
dq 5.0
