#include "raylib.h"

#if defined(_WIN32)
#define SHIM_EXPORT __declspec(dllexport)
#else
#define SHIM_EXPORT __attribute__((visibility("default")))
#endif

SHIM_EXPORT void __claw_ClearBackground(Color *color) {
    ClearBackground(*color);
}

SHIM_EXPORT Font *__claw_cE3AE40FE40GetFontDefault(Font *result) {
    *result = GetFontDefault();
    return result;
}

SHIM_EXPORT Image *__claw_LoadImage(Image *result, const char *file_name) {
    *result = LoadImage(file_name);
    return result;
}

SHIM_EXPORT Texture2D *__claw_LoadTexture(Texture2D *result, const char *file_name) {
    *result = LoadTexture(file_name);
    return result;
}

SHIM_EXPORT Shader *__claw_LoadShader(Shader *result,
                                      const char *vs_file_name,
                                      const char *fs_file_name) {
    *result = LoadShader(vs_file_name, fs_file_name);
    return result;
}

SHIM_EXPORT RenderTexture2D *__claw_LoadRenderTexture(RenderTexture2D *result,
                                                      int width,
                                                      int height) {
    *result = LoadRenderTexture(width, height);
    return result;
}

SHIM_EXPORT Music *__claw_LoadMusicStream(Music *result, const char *file_name) {
    *result = LoadMusicStream(file_name);
    return result;
}

SHIM_EXPORT Sound *__claw_LoadSound(Sound *result, const char *file_name) {
    *result = LoadSound(file_name);
    return result;
}

SHIM_EXPORT void __claw_UnloadFont(Font *font) {
    UnloadFont(*font);
}

SHIM_EXPORT void __claw_UnloadImage(Image *image) {
    UnloadImage(*image);
}

SHIM_EXPORT void __claw_UnloadMusicStream(Music *music) {
    UnloadMusicStream(*music);
}

SHIM_EXPORT void __claw_UnloadRenderTexture(RenderTexture2D *target) {
    UnloadRenderTexture(*target);
}

SHIM_EXPORT void __claw_UnloadShader(Shader *shader) {
    UnloadShader(*shader);
}

SHIM_EXPORT void __claw_UnloadSound(Sound *sound) {
    UnloadSound(*sound);
}

SHIM_EXPORT void __claw_UnloadTexture(Texture2D *texture) {
    UnloadTexture(*texture);
}

SHIM_EXPORT void __claw_SetTextureFilter(Texture2D *texture, int filter) {
    SetTextureFilter(*texture, filter);
}

SHIM_EXPORT void __claw_SetTextureWrap(Texture2D *texture, int wrap) {
    SetTextureWrap(*texture, wrap);
}

SHIM_EXPORT void __claw_BeginTextureMode(RenderTexture2D *target) {
    BeginTextureMode(*target);
}

SHIM_EXPORT void __claw_BeginShaderMode(Shader *shader) {
    BeginShaderMode(*shader);
}

SHIM_EXPORT void __claw_DrawTexturePro(Texture2D *texture,
                                       Rectangle *source,
                                       Rectangle *dest,
                                       Vector2 *origin,
                                       float rotation,
                                       Color *tint) {
    DrawTexturePro(*texture, *source, *dest, *origin, rotation, *tint);
}

SHIM_EXPORT void __claw_DrawText(const char *text,
                                 int pos_x,
                                 int pos_y,
                                 int font_size,
                                 Color *color) {
    DrawText(text, pos_x, pos_y, font_size, *color);
}

SHIM_EXPORT void __claw_DrawTextEx(Font *font,
                                   const char *text,
                                   Vector2 *position,
                                   float font_size,
                                   float spacing,
                                   Color *tint) {
    DrawTextEx(*font, text, *position, font_size, spacing, *tint);
}

SHIM_EXPORT void __claw_DrawLineEx(Vector2 *start_pos,
                                   Vector2 *end_pos,
                                   float thick,
                                   Color *color) {
    DrawLineEx(*start_pos, *end_pos, thick, *color);
}

SHIM_EXPORT void __claw_DrawRectangle(int pos_x,
                                      int pos_y,
                                      int width,
                                      int height,
                                      Color *color) {
    DrawRectangle(pos_x, pos_y, width, height, *color);
}

SHIM_EXPORT void __claw_DrawTriangle(Vector2 *v1,
                                     Vector2 *v2,
                                     Vector2 *v3,
                                     Color *color) {
    DrawTriangle(*v1, *v2, *v3, *color);
}

SHIM_EXPORT void __claw_DrawTriangleLines(Vector2 *v1,
                                          Vector2 *v2,
                                          Vector2 *v3,
                                          Color *color) {
    DrawTriangleLines(*v1, *v2, *v3, *color);
}

SHIM_EXPORT Color *__claw_GetImageColor(Color *result,
                                        Image *image,
                                        int x,
                                        int y) {
    *result = GetImageColor(*image, x, y);
    return result;
}

SHIM_EXPORT void __claw_PlayMusicStream(Music *music) {
    PlayMusicStream(*music);
}

SHIM_EXPORT void __claw_StopMusicStream(Music *music) {
    StopMusicStream(*music);
}

SHIM_EXPORT void __claw_UpdateMusicStream(Music *music) {
    UpdateMusicStream(*music);
}

SHIM_EXPORT void __claw_SetMusicPan(Music *music, float pan) {
    SetMusicPan(*music, pan);
}

SHIM_EXPORT void __claw_SetMusicPitch(Music *music, float pitch) {
    SetMusicPitch(*music, pitch);
}

SHIM_EXPORT void __claw_SetMusicVolume(Music *music, float volume) {
    SetMusicVolume(*music, volume);
}

SHIM_EXPORT void __claw_PlaySound(Sound *sound) {
    PlaySound(*sound);
}

SHIM_EXPORT void __claw_StopSound(Sound *sound) {
    StopSound(*sound);
}

SHIM_EXPORT bool __claw_IsSoundPlaying(Sound *sound) {
    return IsSoundPlaying(*sound);
}

SHIM_EXPORT void __claw_SetSoundPan(Sound *sound, float pan) {
    SetSoundPan(*sound, pan);
}

SHIM_EXPORT void __claw_SetSoundPitch(Sound *sound, float pitch) {
    SetSoundPitch(*sound, pitch);
}

SHIM_EXPORT void __claw_SetSoundVolume(Sound *sound, float volume) {
    SetSoundVolume(*sound, volume);
}
