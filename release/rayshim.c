/* Generated from Claylib x86_64-pc-linux-gnu bindings for Immortal Coil release bundles. */
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#if defined(_WIN32)
#include <winsock2.h>
#else
#include <sys/select.h>
#endif
#include <math.h>
#include "raylib.h"
#include "raymath.h"
#include "rcamera.h"
#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

#if defined(_WIN32)
#define SHIM_EXPORT __declspec(dllexport)
#else
#define SHIM_EXPORT __attribute__((visibility("default")))
#endif

SHIM_EXPORT void __claw_AttachAudioStreamProcessor(AudioStream * stream, AudioCallback processor) {
    AttachAudioStreamProcessor((*stream), processor);
}

SHIM_EXPORT void __claw_BeginMode2D(Camera2D * camera) {
    BeginMode2D((*camera));
}

SHIM_EXPORT void __claw_BeginMode3D(Camera3D * camera) {
    BeginMode3D((*camera));
}

SHIM_EXPORT void __claw_BeginShaderMode(Shader * shader) {
    BeginShaderMode((*shader));
}

SHIM_EXPORT void __claw_BeginTextureMode(RenderTexture2D * target) {
    BeginTextureMode((*target));
}

SHIM_EXPORT void __claw_BeginVrStereoMode(VrStereoConfig * config) {
    BeginVrStereoMode((*config));
}

SHIM_EXPORT bool __claw_CheckCollisionBoxSphere(BoundingBox * box, Vector3 * center, float radius) {
    return CheckCollisionBoxSphere((*box), (*center), radius);
}

SHIM_EXPORT bool __claw_CheckCollisionBoxes(BoundingBox * box1, BoundingBox * box2) {
    return CheckCollisionBoxes((*box1), (*box2));
}

SHIM_EXPORT bool __claw_CheckCollisionCircleRec(Vector2 * center, float radius, Rectangle * rec) {
    return CheckCollisionCircleRec((*center), radius, (*rec));
}

SHIM_EXPORT bool __claw_CheckCollisionCircles(Vector2 * center1, float radius1, Vector2 * center2, float radius2) {
    return CheckCollisionCircles((*center1), radius1, (*center2), radius2);
}

SHIM_EXPORT bool __claw_CheckCollisionLines(Vector2 * start_pos1, Vector2 * end_pos1, Vector2 * start_pos2, Vector2 * end_pos2, Vector2 * collision_point) {
    return CheckCollisionLines((*start_pos1), (*end_pos1), (*start_pos2), (*end_pos2), collision_point);
}

SHIM_EXPORT bool __claw_CheckCollisionPointCircle(Vector2 * point, Vector2 * center, float radius) {
    return CheckCollisionPointCircle((*point), (*center), radius);
}

SHIM_EXPORT bool __claw_CheckCollisionPointLine(Vector2 * point, Vector2 * p1, Vector2 * p2, int threshold) {
    return CheckCollisionPointLine((*point), (*p1), (*p2), threshold);
}

SHIM_EXPORT bool __claw_CheckCollisionPointPoly(Vector2 * point, Vector2 * points, int point_count) {
    return CheckCollisionPointPoly((*point), points, point_count);
}

SHIM_EXPORT bool __claw_CheckCollisionPointRec(Vector2 * point, Rectangle * rec) {
    return CheckCollisionPointRec((*point), (*rec));
}

SHIM_EXPORT bool __claw_CheckCollisionPointTriangle(Vector2 * point, Vector2 * p1, Vector2 * p2, Vector2 * p3) {
    return CheckCollisionPointTriangle((*point), (*p1), (*p2), (*p3));
}

SHIM_EXPORT bool __claw_CheckCollisionRecs(Rectangle * rec1, Rectangle * rec2) {
    return CheckCollisionRecs((*rec1), (*rec2));
}

SHIM_EXPORT bool __claw_CheckCollisionSpheres(Vector3 * center1, float radius1, Vector3 * center2, float radius2) {
    return CheckCollisionSpheres((*center1), radius1, (*center2), radius2);
}

SHIM_EXPORT float __claw_Clamp(float value, float min, float max) {
    return Clamp(value, min, max);
}

SHIM_EXPORT void __claw_ClearBackground(Color * color) {
    ClearBackground((*color));
}

SHIM_EXPORT Color * __claw_ColorAlpha(Color * result, Color * color, float alpha) {
    Color _claw_result = ColorAlpha((*color), alpha);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_ColorAlphaBlend(Color * result, Color * dst, Color * src, Color * tint) {
    Color _claw_result = ColorAlphaBlend((*dst), (*src), (*tint));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_ColorBrightness(Color * result, Color * color, float factor) {
    Color _claw_result = ColorBrightness((*color), factor);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_ColorContrast(Color * result, Color * color, float contrast) {
    Color _claw_result = ColorContrast((*color), contrast);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_ColorFromHSV(Color * result, float hue, float saturation, float value) {
    Color _claw_result = ColorFromHSV(hue, saturation, value);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_ColorFromNormalized(Color * result, Vector4 * normalized) {
    Color _claw_result = ColorFromNormalized((*normalized));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector4 * __claw_ColorNormalize(Vector4 * result, Color * color) {
    Vector4 _claw_result = ColorNormalize((*color));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_ColorTint(Color * result, Color * color, Color * tint) {
    Color _claw_result = ColorTint((*color), (*tint));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_ColorToHSV(Vector3 * result, Color * color) {
    Vector3 _claw_result = ColorToHSV((*color));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_ColorToInt(Color * color) {
    return ColorToInt((*color));
}

SHIM_EXPORT void __claw_DetachAudioStreamProcessor(AudioStream * stream, AudioCallback processor) {
    DetachAudioStreamProcessor((*stream), processor);
}

SHIM_EXPORT void __claw_DrawBillboard(Camera * camera, Texture2D * texture, Vector3 * position, float size, Color * tint) {
    DrawBillboard((*camera), (*texture), (*position), size, (*tint));
}

SHIM_EXPORT void __claw_DrawBillboardPro(Camera * camera, Texture2D * texture, Rectangle * source, Vector3 * position, Vector3 * up, Vector2 * size, Vector2 * origin, float rotation, Color * tint) {
    DrawBillboardPro((*camera), (*texture), (*source), (*position), (*up), (*size), (*origin), rotation, (*tint));
}

SHIM_EXPORT void __claw_DrawBillboardRec(Camera * camera, Texture2D * texture, Rectangle * source, Vector3 * position, Vector2 * size, Color * tint) {
    DrawBillboardRec((*camera), (*texture), (*source), (*position), (*size), (*tint));
}

SHIM_EXPORT void __claw_DrawBoundingBox(BoundingBox * box, Color * color) {
    DrawBoundingBox((*box), (*color));
}

SHIM_EXPORT void __claw_DrawCapsule(Vector3 * start_pos, Vector3 * end_pos, float radius, int slices, int rings, Color * color) {
    DrawCapsule((*start_pos), (*end_pos), radius, slices, rings, (*color));
}

SHIM_EXPORT void __claw_DrawCapsuleWires(Vector3 * start_pos, Vector3 * end_pos, float radius, int slices, int rings, Color * color) {
    DrawCapsuleWires((*start_pos), (*end_pos), radius, slices, rings, (*color));
}

SHIM_EXPORT void __claw_DrawCircle(int center_x, int center_y, float radius, Color * color) {
    DrawCircle(center_x, center_y, radius, (*color));
}

SHIM_EXPORT void __claw_DrawCircle3D(Vector3 * center, float radius, Vector3 * rotation_axis, float rotation_angle, Color * color) {
    DrawCircle3D((*center), radius, (*rotation_axis), rotation_angle, (*color));
}

SHIM_EXPORT void __claw_DrawCircleGradient(int center_x, int center_y, float radius, Color * color1, Color * color2) {
    DrawCircleGradient(center_x, center_y, radius, (*color1), (*color2));
}

SHIM_EXPORT void __claw_DrawCircleLines(int center_x, int center_y, float radius, Color * color) {
    DrawCircleLines(center_x, center_y, radius, (*color));
}

SHIM_EXPORT void __claw_DrawCircleSector(Vector2 * center, float radius, float start_angle, float end_angle, int segments, Color * color) {
    DrawCircleSector((*center), radius, start_angle, end_angle, segments, (*color));
}

SHIM_EXPORT void __claw_DrawCircleSectorLines(Vector2 * center, float radius, float start_angle, float end_angle, int segments, Color * color) {
    DrawCircleSectorLines((*center), radius, start_angle, end_angle, segments, (*color));
}

SHIM_EXPORT void __claw_DrawCircleV(Vector2 * center, float radius, Color * color) {
    DrawCircleV((*center), radius, (*color));
}

SHIM_EXPORT void __claw_DrawCube(Vector3 * position, float width, float height, float length, Color * color) {
    DrawCube((*position), width, height, length, (*color));
}

SHIM_EXPORT void __claw_DrawCubeV(Vector3 * position, Vector3 * size, Color * color) {
    DrawCubeV((*position), (*size), (*color));
}

SHIM_EXPORT void __claw_DrawCubeWires(Vector3 * position, float width, float height, float length, Color * color) {
    DrawCubeWires((*position), width, height, length, (*color));
}

SHIM_EXPORT void __claw_DrawCubeWiresV(Vector3 * position, Vector3 * size, Color * color) {
    DrawCubeWiresV((*position), (*size), (*color));
}

SHIM_EXPORT void __claw_DrawCylinder(Vector3 * position, float radius_top, float radius_bottom, float height, int slices, Color * color) {
    DrawCylinder((*position), radius_top, radius_bottom, height, slices, (*color));
}

SHIM_EXPORT void __claw_DrawCylinderEx(Vector3 * start_pos, Vector3 * end_pos, float start_radius, float end_radius, int sides, Color * color) {
    DrawCylinderEx((*start_pos), (*end_pos), start_radius, end_radius, sides, (*color));
}

SHIM_EXPORT void __claw_DrawCylinderWires(Vector3 * position, float radius_top, float radius_bottom, float height, int slices, Color * color) {
    DrawCylinderWires((*position), radius_top, radius_bottom, height, slices, (*color));
}

SHIM_EXPORT void __claw_DrawCylinderWiresEx(Vector3 * start_pos, Vector3 * end_pos, float start_radius, float end_radius, int sides, Color * color) {
    DrawCylinderWiresEx((*start_pos), (*end_pos), start_radius, end_radius, sides, (*color));
}

SHIM_EXPORT void __claw_DrawEllipse(int center_x, int center_y, float radius_h, float radius_v, Color * color) {
    DrawEllipse(center_x, center_y, radius_h, radius_v, (*color));
}

SHIM_EXPORT void __claw_DrawEllipseLines(int center_x, int center_y, float radius_h, float radius_v, Color * color) {
    DrawEllipseLines(center_x, center_y, radius_h, radius_v, (*color));
}

SHIM_EXPORT void __claw_DrawLine(int start_pos_x, int start_pos_y, int end_pos_x, int end_pos_y, Color * color) {
    DrawLine(start_pos_x, start_pos_y, end_pos_x, end_pos_y, (*color));
}

SHIM_EXPORT void __claw_DrawLine3D(Vector3 * start_pos, Vector3 * end_pos, Color * color) {
    DrawLine3D((*start_pos), (*end_pos), (*color));
}

SHIM_EXPORT void __claw_DrawLineBezier(Vector2 * start_pos, Vector2 * end_pos, float thick, Color * color) {
    DrawLineBezier((*start_pos), (*end_pos), thick, (*color));
}

SHIM_EXPORT void __claw_DrawLineBezierCubic(Vector2 * start_pos, Vector2 * end_pos, Vector2 * start_control_pos, Vector2 * end_control_pos, float thick, Color * color) {
    DrawLineBezierCubic((*start_pos), (*end_pos), (*start_control_pos), (*end_control_pos), thick, (*color));
}

SHIM_EXPORT void __claw_DrawLineBezierQuad(Vector2 * start_pos, Vector2 * end_pos, Vector2 * control_pos, float thick, Color * color) {
    DrawLineBezierQuad((*start_pos), (*end_pos), (*control_pos), thick, (*color));
}

SHIM_EXPORT void __claw_DrawLineEx(Vector2 * start_pos, Vector2 * end_pos, float thick, Color * color) {
    DrawLineEx((*start_pos), (*end_pos), thick, (*color));
}

SHIM_EXPORT void __claw_DrawLineStrip(Vector2 * points, int point_count, Color * color) {
    DrawLineStrip(points, point_count, (*color));
}

SHIM_EXPORT void __claw_DrawLineV(Vector2 * start_pos, Vector2 * end_pos, Color * color) {
    DrawLineV((*start_pos), (*end_pos), (*color));
}

SHIM_EXPORT void __claw_DrawMesh(Mesh * mesh, Material * material, Matrix * transform) {
    DrawMesh((*mesh), (*material), (*transform));
}

SHIM_EXPORT void __claw_DrawMeshInstanced(Mesh * mesh, Material * material, Matrix * transforms, int instances) {
    DrawMeshInstanced((*mesh), (*material), transforms, instances);
}

SHIM_EXPORT void __claw_DrawModel(Model * model, Vector3 * position, float scale, Color * tint) {
    DrawModel((*model), (*position), scale, (*tint));
}

SHIM_EXPORT void __claw_DrawModelEx(Model * model, Vector3 * position, Vector3 * rotation_axis, float rotation_angle, Vector3 * scale, Color * tint) {
    DrawModelEx((*model), (*position), (*rotation_axis), rotation_angle, (*scale), (*tint));
}

SHIM_EXPORT void __claw_DrawModelWires(Model * model, Vector3 * position, float scale, Color * tint) {
    DrawModelWires((*model), (*position), scale, (*tint));
}

SHIM_EXPORT void __claw_DrawModelWiresEx(Model * model, Vector3 * position, Vector3 * rotation_axis, float rotation_angle, Vector3 * scale, Color * tint) {
    DrawModelWiresEx((*model), (*position), (*rotation_axis), rotation_angle, (*scale), (*tint));
}

SHIM_EXPORT void __claw_DrawPixel(int pos_x, int pos_y, Color * color) {
    DrawPixel(pos_x, pos_y, (*color));
}

SHIM_EXPORT void __claw_DrawPixelV(Vector2 * position, Color * color) {
    DrawPixelV((*position), (*color));
}

SHIM_EXPORT void __claw_DrawPlane(Vector3 * center_pos, Vector2 * size, Color * color) {
    DrawPlane((*center_pos), (*size), (*color));
}

SHIM_EXPORT void __claw_DrawPoint3D(Vector3 * position, Color * color) {
    DrawPoint3D((*position), (*color));
}

SHIM_EXPORT void __claw_DrawPoly(Vector2 * center, int sides, float radius, float rotation, Color * color) {
    DrawPoly((*center), sides, radius, rotation, (*color));
}

SHIM_EXPORT void __claw_DrawPolyLines(Vector2 * center, int sides, float radius, float rotation, Color * color) {
    DrawPolyLines((*center), sides, radius, rotation, (*color));
}

SHIM_EXPORT void __claw_DrawPolyLinesEx(Vector2 * center, int sides, float radius, float rotation, float line_thick, Color * color) {
    DrawPolyLinesEx((*center), sides, radius, rotation, line_thick, (*color));
}

SHIM_EXPORT void __claw_DrawRay(Ray * ray, Color * color) {
    DrawRay((*ray), (*color));
}

SHIM_EXPORT void __claw_DrawRectangle(int pos_x, int pos_y, int width, int height, Color * color) {
    DrawRectangle(pos_x, pos_y, width, height, (*color));
}

SHIM_EXPORT void __claw_DrawRectangleGradientEx(Rectangle * rec, Color * col1, Color * col2, Color * col3, Color * col4) {
    DrawRectangleGradientEx((*rec), (*col1), (*col2), (*col3), (*col4));
}

SHIM_EXPORT void __claw_DrawRectangleGradientH(int pos_x, int pos_y, int width, int height, Color * color1, Color * color2) {
    DrawRectangleGradientH(pos_x, pos_y, width, height, (*color1), (*color2));
}

SHIM_EXPORT void __claw_DrawRectangleGradientV(int pos_x, int pos_y, int width, int height, Color * color1, Color * color2) {
    DrawRectangleGradientV(pos_x, pos_y, width, height, (*color1), (*color2));
}

SHIM_EXPORT void __claw_DrawRectangleLines(int pos_x, int pos_y, int width, int height, Color * color) {
    DrawRectangleLines(pos_x, pos_y, width, height, (*color));
}

SHIM_EXPORT void __claw_DrawRectangleLinesEx(Rectangle * rec, float line_thick, Color * color) {
    DrawRectangleLinesEx((*rec), line_thick, (*color));
}

SHIM_EXPORT void __claw_DrawRectanglePro(Rectangle * rec, Vector2 * origin, float rotation, Color * color) {
    DrawRectanglePro((*rec), (*origin), rotation, (*color));
}

SHIM_EXPORT void __claw_DrawRectangleRec(Rectangle * rec, Color * color) {
    DrawRectangleRec((*rec), (*color));
}

SHIM_EXPORT void __claw_DrawRectangleRounded(Rectangle * rec, float roundness, int segments, Color * color) {
    DrawRectangleRounded((*rec), roundness, segments, (*color));
}

SHIM_EXPORT void __claw_DrawRectangleRoundedLines(Rectangle * rec, float roundness, int segments, float line_thick, Color * color) {
    DrawRectangleRoundedLines((*rec), roundness, segments, line_thick, (*color));
}

SHIM_EXPORT void __claw_DrawRectangleV(Vector2 * position, Vector2 * size, Color * color) {
    DrawRectangleV((*position), (*size), (*color));
}

SHIM_EXPORT void __claw_DrawRing(Vector2 * center, float inner_radius, float outer_radius, float start_angle, float end_angle, int segments, Color * color) {
    DrawRing((*center), inner_radius, outer_radius, start_angle, end_angle, segments, (*color));
}

SHIM_EXPORT void __claw_DrawRingLines(Vector2 * center, float inner_radius, float outer_radius, float start_angle, float end_angle, int segments, Color * color) {
    DrawRingLines((*center), inner_radius, outer_radius, start_angle, end_angle, segments, (*color));
}

SHIM_EXPORT void __claw_DrawSphere(Vector3 * center_pos, float radius, Color * color) {
    DrawSphere((*center_pos), radius, (*color));
}

SHIM_EXPORT void __claw_DrawSphereEx(Vector3 * center_pos, float radius, int rings, int slices, Color * color) {
    DrawSphereEx((*center_pos), radius, rings, slices, (*color));
}

SHIM_EXPORT void __claw_DrawSphereWires(Vector3 * center_pos, float radius, int rings, int slices, Color * color) {
    DrawSphereWires((*center_pos), radius, rings, slices, (*color));
}

SHIM_EXPORT void __claw_DrawText(char * text, int pos_x, int pos_y, int font_size, Color * color) {
    DrawText(text, pos_x, pos_y, font_size, (*color));
}

SHIM_EXPORT void __claw_DrawTextCodepoint(Font * font, int codepoint, Vector2 * position, float font_size, Color * tint) {
    DrawTextCodepoint((*font), codepoint, (*position), font_size, (*tint));
}

SHIM_EXPORT void __claw_DrawTextCodepoints(Font * font, int * codepoints, int count, Vector2 * position, float font_size, float spacing, Color * tint) {
    DrawTextCodepoints((*font), codepoints, count, (*position), font_size, spacing, (*tint));
}

SHIM_EXPORT void __claw_DrawTextEx(Font * font, char * text, Vector2 * position, float font_size, float spacing, Color * tint) {
    DrawTextEx((*font), text, (*position), font_size, spacing, (*tint));
}

SHIM_EXPORT void __claw_DrawTextPro(Font * font, char * text, Vector2 * position, Vector2 * origin, float rotation, float font_size, float spacing, Color * tint) {
    DrawTextPro((*font), text, (*position), (*origin), rotation, font_size, spacing, (*tint));
}

SHIM_EXPORT void __claw_DrawTexture(Texture2D * texture, int pos_x, int pos_y, Color * tint) {
    DrawTexture((*texture), pos_x, pos_y, (*tint));
}

SHIM_EXPORT void __claw_DrawTextureEx(Texture2D * texture, Vector2 * position, float rotation, float scale, Color * tint) {
    DrawTextureEx((*texture), (*position), rotation, scale, (*tint));
}

SHIM_EXPORT void __claw_DrawTextureNPatch(Texture2D * texture, NPatchInfo * n_patch_info, Rectangle * dest, Vector2 * origin, float rotation, Color * tint) {
    DrawTextureNPatch((*texture), (*n_patch_info), (*dest), (*origin), rotation, (*tint));
}

SHIM_EXPORT void __claw_DrawTexturePro(Texture2D * texture, Rectangle * source, Rectangle * dest, Vector2 * origin, float rotation, Color * tint) {
    DrawTexturePro((*texture), (*source), (*dest), (*origin), rotation, (*tint));
}

SHIM_EXPORT void __claw_DrawTextureRec(Texture2D * texture, Rectangle * source, Vector2 * position, Color * tint) {
    DrawTextureRec((*texture), (*source), (*position), (*tint));
}

SHIM_EXPORT void __claw_DrawTextureV(Texture2D * texture, Vector2 * position, Color * tint) {
    DrawTextureV((*texture), (*position), (*tint));
}

SHIM_EXPORT void __claw_DrawTriangle(Vector2 * v1, Vector2 * v2, Vector2 * v3, Color * color) {
    DrawTriangle((*v1), (*v2), (*v3), (*color));
}

SHIM_EXPORT void __claw_DrawTriangle3D(Vector3 * v1, Vector3 * v2, Vector3 * v3, Color * color) {
    DrawTriangle3D((*v1), (*v2), (*v3), (*color));
}

SHIM_EXPORT void __claw_DrawTriangleFan(Vector2 * points, int point_count, Color * color) {
    DrawTriangleFan(points, point_count, (*color));
}

SHIM_EXPORT void __claw_DrawTriangleLines(Vector2 * v1, Vector2 * v2, Vector2 * v3, Color * color) {
    DrawTriangleLines((*v1), (*v2), (*v3), (*color));
}

SHIM_EXPORT void __claw_DrawTriangleStrip(Vector2 * points, int point_count, Color * color) {
    DrawTriangleStrip(points, point_count, (*color));
}

SHIM_EXPORT void __claw_DrawTriangleStrip3D(Vector3 * points, int point_count, Color * color) {
    DrawTriangleStrip3D(points, point_count, (*color));
}

SHIM_EXPORT bool __claw_ExportFontAsCode(Font * font, char * file_name) {
    return ExportFontAsCode((*font), file_name);
}

SHIM_EXPORT bool __claw_ExportImage(Image * image, char * file_name) {
    return ExportImage((*image), file_name);
}

SHIM_EXPORT bool __claw_ExportImageAsCode(Image * image, char * file_name) {
    return ExportImageAsCode((*image), file_name);
}

SHIM_EXPORT bool __claw_ExportMesh(Mesh * mesh, char * file_name) {
    return ExportMesh((*mesh), file_name);
}

SHIM_EXPORT bool __claw_ExportWave(Wave * wave, char * file_name) {
    return ExportWave((*wave), file_name);
}

SHIM_EXPORT bool __claw_ExportWaveAsCode(Wave * wave, char * file_name) {
    return ExportWaveAsCode((*wave), file_name);
}

SHIM_EXPORT Color * __claw_Fade(Color * result, Color * color, float alpha) {
    Color _claw_result = Fade((*color), alpha);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_FloatEquals(float x, float y) {
    return FloatEquals(x, y);
}

SHIM_EXPORT Image * __claw_GenImageCellular(Image * result, int width, int height, int tile_size) {
    Image _claw_result = GenImageCellular(width, height, tile_size);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageChecked(Image * result, int width, int height, int checks_x, int checks_y, Color * col1, Color * col2) {
    Image _claw_result = GenImageChecked(width, height, checks_x, checks_y, (*col1), (*col2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageColor(Image * result, int width, int height, Color * color) {
    Image _claw_result = GenImageColor(width, height, (*color));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageFontAtlas(Image * result, GlyphInfo * chars, Rectangle * * recs, int glyph_count, int font_size, int padding, int pack_method) {
    Image _claw_result = GenImageFontAtlas(chars, recs, glyph_count, font_size, padding, pack_method);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageGradientH(Image * result, int width, int height, Color * left, Color * right) {
    Image _claw_result = GenImageGradientH(width, height, (*left), (*right));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageGradientRadial(Image * result, int width, int height, float density, Color * inner, Color * outer) {
    Image _claw_result = GenImageGradientRadial(width, height, density, (*inner), (*outer));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageGradientV(Image * result, int width, int height, Color * top, Color * bottom) {
    Image _claw_result = GenImageGradientV(width, height, (*top), (*bottom));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImagePerlinNoise(Image * result, int width, int height, int offset_x, int offset_y, float scale) {
    Image _claw_result = GenImagePerlinNoise(width, height, offset_x, offset_y, scale);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageText(Image * result, int width, int height, char * text) {
    Image _claw_result = GenImageText(width, height, text);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_GenImageWhiteNoise(Image * result, int width, int height, float factor) {
    Image _claw_result = GenImageWhiteNoise(width, height, factor);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshCone(Mesh * result, float radius, float height, int slices) {
    Mesh _claw_result = GenMeshCone(radius, height, slices);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshCube(Mesh * result, float width, float height, float length) {
    Mesh _claw_result = GenMeshCube(width, height, length);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshCubicmap(Mesh * result, Image * cubicmap, Vector3 * cube_size) {
    Mesh _claw_result = GenMeshCubicmap((*cubicmap), (*cube_size));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshCylinder(Mesh * result, float radius, float height, int slices) {
    Mesh _claw_result = GenMeshCylinder(radius, height, slices);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshHeightmap(Mesh * result, Image * heightmap, Vector3 * size) {
    Mesh _claw_result = GenMeshHeightmap((*heightmap), (*size));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshHemiSphere(Mesh * result, float radius, int rings, int slices) {
    Mesh _claw_result = GenMeshHemiSphere(radius, rings, slices);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshKnot(Mesh * result, float radius, float size, int rad_seg, int sides) {
    Mesh _claw_result = GenMeshKnot(radius, size, rad_seg, sides);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshPlane(Mesh * result, float width, float length, int res_x, int res_z) {
    Mesh _claw_result = GenMeshPlane(width, length, res_x, res_z);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshPoly(Mesh * result, int sides, float radius) {
    Mesh _claw_result = GenMeshPoly(sides, radius);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshSphere(Mesh * result, float radius, int rings, int slices) {
    Mesh _claw_result = GenMeshSphere(radius, rings, slices);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Mesh * __claw_GenMeshTorus(Mesh * result, float radius, float size, int rad_seg, int sides) {
    Mesh _claw_result = GenMeshTorus(radius, size, rad_seg, sides);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_GetCameraForward(Vector3 * result, Camera * camera) {
    Vector3 _claw_result = GetCameraForward(camera);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_GetCameraMatrix(Matrix * result, Camera * camera) {
    Matrix _claw_result = GetCameraMatrix((*camera));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_GetCameraMatrix2D(Matrix * result, Camera2D * camera) {
    Matrix _claw_result = GetCameraMatrix2D((*camera));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_GetCameraProjectionMatrix(Matrix * result, Camera * camera, float aspect) {
    Matrix _claw_result = GetCameraProjectionMatrix(camera, aspect);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_GetCameraRight(Vector3 * result, Camera * camera) {
    Vector3 _claw_result = GetCameraRight(camera);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_GetCameraUp(Vector3 * result, Camera * camera) {
    Vector3 _claw_result = GetCameraUp(camera);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_GetCameraViewMatrix(Matrix * result, Camera * camera) {
    Matrix _claw_result = GetCameraViewMatrix(camera);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Rectangle * __claw_GetCollisionRec(Rectangle * result, Rectangle * rec1, Rectangle * rec2) {
    Rectangle _claw_result = GetCollisionRec((*rec1), (*rec2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_GetColor(Color * result, unsigned int hex_value) {
    Color _claw_result = GetColor(hex_value);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Font * __claw_cE3AE40FE40GetFontDefault(Font * result) {
    Font _claw_result = GetFontDefault();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetGestureDragVector(Vector2 * result) {
    Vector2 _claw_result = GetGestureDragVector();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetGesturePinchVector(Vector2 * result) {
    Vector2 _claw_result = GetGesturePinchVector();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Rectangle * __claw_GetGlyphAtlasRec(Rectangle * result, Font * font, int codepoint) {
    Rectangle _claw_result = GetGlyphAtlasRec((*font), codepoint);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_GetGlyphIndex(Font * font, int codepoint) {
    return GetGlyphIndex((*font), codepoint);
}

SHIM_EXPORT GlyphInfo * __claw_GetGlyphInfo(GlyphInfo * result, Font * font, int codepoint) {
    GlyphInfo _claw_result = GetGlyphInfo((*font), codepoint);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Rectangle * __claw_GetImageAlphaBorder(Rectangle * result, Image * image, float threshold) {
    Rectangle _claw_result = GetImageAlphaBorder((*image), threshold);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_GetImageColor(Color * result, Image * image, int x, int y) {
    Color _claw_result = GetImageColor((*image), x, y);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT BoundingBox * __claw_GetMeshBoundingBox(BoundingBox * result, Mesh * mesh) {
    BoundingBox _claw_result = GetMeshBoundingBox((*mesh));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT BoundingBox * __claw_GetModelBoundingBox(BoundingBox * result, Model * model) {
    BoundingBox _claw_result = GetModelBoundingBox((*model));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_GetMonitorPosition(Vector2 * result, int monitor) {
    Vector2 _claw_result = GetMonitorPosition(monitor);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetMouseDelta(Vector2 * result) {
    Vector2 _claw_result = GetMouseDelta();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetMousePosition(Vector2 * result) {
    Vector2 _claw_result = GetMousePosition();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Ray * __claw_GetMouseRay(Ray * result, Vector2 * mouse_position, Camera * camera) {
    Ray _claw_result = GetMouseRay((*mouse_position), (*camera));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetMouseWheelMoveV(Vector2 * result) {
    Vector2 _claw_result = GetMouseWheelMoveV();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_GetMusicTimeLength(Music * music) {
    return GetMusicTimeLength((*music));
}

SHIM_EXPORT float __claw_GetMusicTimePlayed(Music * music) {
    return GetMusicTimePlayed((*music));
}

SHIM_EXPORT Color * __claw_GetPixelColor(Color * result, void * src_ptr, int format) {
    Color _claw_result = GetPixelColor(src_ptr, format);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT RayCollision * __claw_GetRayCollisionBox(RayCollision * result, Ray * ray, BoundingBox * box) {
    RayCollision _claw_result = GetRayCollisionBox((*ray), (*box));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT RayCollision * __claw_GetRayCollisionMesh(RayCollision * result, Ray * ray, Mesh * mesh, Matrix * transform) {
    RayCollision _claw_result = GetRayCollisionMesh((*ray), (*mesh), (*transform));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT RayCollision * __claw_GetRayCollisionQuad(RayCollision * result, Ray * ray, Vector3 * p1, Vector3 * p2, Vector3 * p3, Vector3 * p4) {
    RayCollision _claw_result = GetRayCollisionQuad((*ray), (*p1), (*p2), (*p3), (*p4));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT RayCollision * __claw_GetRayCollisionSphere(RayCollision * result, Ray * ray, Vector3 * center, float radius) {
    RayCollision _claw_result = GetRayCollisionSphere((*ray), (*center), radius);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT RayCollision * __claw_GetRayCollisionTriangle(RayCollision * result, Ray * ray, Vector3 * p1, Vector3 * p2, Vector3 * p3) {
    RayCollision _claw_result = GetRayCollisionTriangle((*ray), (*p1), (*p2), (*p3));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_GetScreenToWorld2D(Vector2 * result, Vector2 * position, Camera2D * camera) {
    Vector2 _claw_result = GetScreenToWorld2D((*position), (*camera));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_GetShaderLocation(Shader * shader, char * uniform_name) {
    return GetShaderLocation((*shader), uniform_name);
}

SHIM_EXPORT int __claw_GetShaderLocationAttrib(Shader * shader, char * attrib_name) {
    return GetShaderLocationAttrib((*shader), attrib_name);
}

SHIM_EXPORT Vector2 * __claw_GetTouchPosition(Vector2 * result, int index) {
    Vector2 _claw_result = GetTouchPosition(index);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetWindowPosition(Vector2 * result) {
    Vector2 _claw_result = GetWindowPosition();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40GetWindowScaleDPI(Vector2 * result) {
    Vector2 _claw_result = GetWindowScaleDPI();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_GetWorldToScreen(Vector2 * result, Vector3 * position, Camera * camera) {
    Vector2 _claw_result = GetWorldToScreen((*position), (*camera));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_GetWorldToScreen2D(Vector2 * result, Vector2 * position, Camera2D * camera) {
    Vector2 _claw_result = GetWorldToScreen2D((*position), (*camera));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_GetWorldToScreenEx(Vector2 * result, Vector3 * position, Camera * camera, int width, int height) {
    Vector2 _claw_result = GetWorldToScreenEx((*position), (*camera), width, height);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT bool __claw_GuiButton(Rectangle * bounds, char * text) {
    return GuiButton((*bounds), text);
}

SHIM_EXPORT bool __claw_GuiCheckBox(Rectangle * bounds, char * text, bool checked) {
    return GuiCheckBox((*bounds), text, checked);
}

SHIM_EXPORT float __claw_GuiColorBarAlpha(Rectangle * bounds, char * text, float alpha) {
    return GuiColorBarAlpha((*bounds), text, alpha);
}

SHIM_EXPORT float __claw_GuiColorBarHue(Rectangle * bounds, char * text, float value) {
    return GuiColorBarHue((*bounds), text, value);
}

SHIM_EXPORT Color * __claw_GuiColorPanel(Color * result, Rectangle * bounds, char * text, Color * color) {
    Color _claw_result = GuiColorPanel((*bounds), text, (*color));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_GuiColorPicker(Color * result, Rectangle * bounds, char * text, Color * color) {
    Color _claw_result = GuiColorPicker((*bounds), text, (*color));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_GuiComboBox(Rectangle * bounds, char * text, int active) {
    return GuiComboBox((*bounds), text, active);
}

SHIM_EXPORT void __claw_GuiDrawIcon(int icon_id, int pos_x, int pos_y, int pixel_size, Color * color) {
    GuiDrawIcon(icon_id, pos_x, pos_y, pixel_size, (*color));
}

SHIM_EXPORT bool __claw_GuiDropdownBox(Rectangle * bounds, char * text, int * active, bool edit_mode) {
    return GuiDropdownBox((*bounds), text, active, edit_mode);
}

SHIM_EXPORT void __claw_GuiDummyRec(Rectangle * bounds, char * text) {
    GuiDummyRec((*bounds), text);
}

SHIM_EXPORT Font * __claw_cE3AE40FE40GuiGetFont(Font * result) {
    Font _claw_result = GuiGetFont();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_GuiGrid(Vector2 * result, Rectangle * bounds, char * text, float spacing, int subdivs) {
    Vector2 _claw_result = GuiGrid((*bounds), text, spacing, subdivs);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_GuiGroupBox(Rectangle * bounds, char * text) {
    GuiGroupBox((*bounds), text);
}

SHIM_EXPORT void __claw_GuiLabel(Rectangle * bounds, char * text) {
    GuiLabel((*bounds), text);
}

SHIM_EXPORT bool __claw_GuiLabelButton(Rectangle * bounds, char * text) {
    return GuiLabelButton((*bounds), text);
}

SHIM_EXPORT void __claw_GuiLine(Rectangle * bounds, char * text) {
    GuiLine((*bounds), text);
}

SHIM_EXPORT int __claw_GuiListView(Rectangle * bounds, char * text, int * scroll_index, int active) {
    return GuiListView((*bounds), text, scroll_index, active);
}

SHIM_EXPORT int __claw_GuiListViewEx(Rectangle * bounds, char * text, int count, int * focus, int * scroll_index, int active) {
    return GuiListViewEx((*bounds), (const char **)text, count, focus, scroll_index, active);
}

SHIM_EXPORT int __claw_GuiMessageBox(Rectangle * bounds, char * title, char * message, char * buttons) {
    return GuiMessageBox((*bounds), title, message, buttons);
}

SHIM_EXPORT void __claw_GuiPanel(Rectangle * bounds, char * text) {
    GuiPanel((*bounds), text);
}

SHIM_EXPORT float __claw_GuiProgressBar(Rectangle * bounds, char * text_left, char * text_right, float value, float min_value, float max_value) {
    return GuiProgressBar((*bounds), text_left, text_right, value, min_value, max_value);
}

SHIM_EXPORT Rectangle * __claw_GuiScrollPanel(Rectangle * result, Rectangle * bounds, char * text, Rectangle * content, Vector2 * scroll) {
    Rectangle _claw_result = GuiScrollPanel((*bounds), text, (*content), scroll);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_GuiSetFont(Font * font) {
    GuiSetFont((*font));
}

SHIM_EXPORT float __claw_GuiSlider(Rectangle * bounds, char * text_left, char * text_right, float value, float min_value, float max_value) {
    return GuiSlider((*bounds), text_left, text_right, value, min_value, max_value);
}

SHIM_EXPORT float __claw_GuiSliderBar(Rectangle * bounds, char * text_left, char * text_right, float value, float min_value, float max_value) {
    return GuiSliderBar((*bounds), text_left, text_right, value, min_value, max_value);
}

SHIM_EXPORT float __claw_GuiSliderPro(Rectangle * bounds, char * text_left, char * text_right, float value, float min_value, float max_value, int slider_width) {
    return GuiSliderPro((*bounds), text_left, text_right, value, min_value, max_value, slider_width);
}

SHIM_EXPORT bool __claw_GuiSpinner(Rectangle * bounds, char * text, int * value, int min_value, int max_value, bool edit_mode) {
    return GuiSpinner((*bounds), text, value, min_value, max_value, edit_mode);
}

SHIM_EXPORT void __claw_GuiStatusBar(Rectangle * bounds, char * text) {
    GuiStatusBar((*bounds), text);
}

SHIM_EXPORT int __claw_GuiTabBar(Rectangle * bounds, char * text, int count, int * active) {
    return GuiTabBar((*bounds), (const char **)text, count, active);
}

SHIM_EXPORT bool __claw_GuiTextBox(Rectangle * bounds, char * text, int text_size, bool edit_mode) {
    return GuiTextBox((*bounds), text, text_size, edit_mode);
}

SHIM_EXPORT int __claw_GuiTextInputBox(Rectangle * bounds, char * title, char * message, char * buttons, char * text, int text_max_size, int * secret_view_active) {
    return GuiTextInputBox((*bounds), title, message, buttons, text, text_max_size, secret_view_active);
}

SHIM_EXPORT bool __claw_GuiToggle(Rectangle * bounds, char * text, bool active) {
    return GuiToggle((*bounds), text, active);
}

SHIM_EXPORT int __claw_GuiToggleGroup(Rectangle * bounds, char * text, int active) {
    return GuiToggleGroup((*bounds), text, active);
}

SHIM_EXPORT bool __claw_GuiValueBox(Rectangle * bounds, char * text, int * value, int min_value, int max_value, bool edit_mode) {
    return GuiValueBox((*bounds), text, value, min_value, max_value, edit_mode);
}

SHIM_EXPORT bool __claw_GuiWindowBox(Rectangle * bounds, char * title) {
    return GuiWindowBox((*bounds), title);
}

SHIM_EXPORT void __claw_ImageAlphaClear(Image * image, Color * color, float threshold) {
    ImageAlphaClear(image, (*color), threshold);
}

SHIM_EXPORT void __claw_ImageAlphaMask(Image * image, Image * alpha_mask) {
    ImageAlphaMask(image, (*alpha_mask));
}

SHIM_EXPORT void __claw_ImageClearBackground(Image * dst, Color * color) {
    ImageClearBackground(dst, (*color));
}

SHIM_EXPORT void __claw_ImageColorReplace(Image * image, Color * color, Color * replace) {
    ImageColorReplace(image, (*color), (*replace));
}

SHIM_EXPORT void __claw_ImageColorTint(Image * image, Color * color) {
    ImageColorTint(image, (*color));
}

SHIM_EXPORT Image * __claw_ImageCopy(Image * result, Image * image) {
    Image _claw_result = ImageCopy((*image));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_ImageCrop(Image * image, Rectangle * crop) {
    ImageCrop(image, (*crop));
}

SHIM_EXPORT void __claw_ImageDraw(Image * dst, Image * src, Rectangle * src_rec, Rectangle * dst_rec, Color * tint) {
    ImageDraw(dst, (*src), (*src_rec), (*dst_rec), (*tint));
}

SHIM_EXPORT void __claw_ImageDrawCircle(Image * dst, int center_x, int center_y, int radius, Color * color) {
    ImageDrawCircle(dst, center_x, center_y, radius, (*color));
}

SHIM_EXPORT void __claw_ImageDrawCircleLines(Image * dst, int center_x, int center_y, int radius, Color * color) {
    ImageDrawCircleLines(dst, center_x, center_y, radius, (*color));
}

SHIM_EXPORT void __claw_ImageDrawCircleLinesV(Image * dst, Vector2 * center, int radius, Color * color) {
    ImageDrawCircleLinesV(dst, (*center), radius, (*color));
}

SHIM_EXPORT void __claw_ImageDrawCircleV(Image * dst, Vector2 * center, int radius, Color * color) {
    ImageDrawCircleV(dst, (*center), radius, (*color));
}

SHIM_EXPORT void __claw_ImageDrawLine(Image * dst, int start_pos_x, int start_pos_y, int end_pos_x, int end_pos_y, Color * color) {
    ImageDrawLine(dst, start_pos_x, start_pos_y, end_pos_x, end_pos_y, (*color));
}

SHIM_EXPORT void __claw_ImageDrawLineV(Image * dst, Vector2 * start, Vector2 * end, Color * color) {
    ImageDrawLineV(dst, (*start), (*end), (*color));
}

SHIM_EXPORT void __claw_ImageDrawPixel(Image * dst, int pos_x, int pos_y, Color * color) {
    ImageDrawPixel(dst, pos_x, pos_y, (*color));
}

SHIM_EXPORT void __claw_ImageDrawPixelV(Image * dst, Vector2 * position, Color * color) {
    ImageDrawPixelV(dst, (*position), (*color));
}

SHIM_EXPORT void __claw_ImageDrawRectangle(Image * dst, int pos_x, int pos_y, int width, int height, Color * color) {
    ImageDrawRectangle(dst, pos_x, pos_y, width, height, (*color));
}

SHIM_EXPORT void __claw_ImageDrawRectangleLines(Image * dst, Rectangle * rec, int thick, Color * color) {
    ImageDrawRectangleLines(dst, (*rec), thick, (*color));
}

SHIM_EXPORT void __claw_ImageDrawRectangleRec(Image * dst, Rectangle * rec, Color * color) {
    ImageDrawRectangleRec(dst, (*rec), (*color));
}

SHIM_EXPORT void __claw_ImageDrawRectangleV(Image * dst, Vector2 * position, Vector2 * size, Color * color) {
    ImageDrawRectangleV(dst, (*position), (*size), (*color));
}

SHIM_EXPORT void __claw_ImageDrawText(Image * dst, char * text, int pos_x, int pos_y, int font_size, Color * color) {
    ImageDrawText(dst, text, pos_x, pos_y, font_size, (*color));
}

SHIM_EXPORT void __claw_ImageDrawTextEx(Image * dst, Font * font, char * text, Vector2 * position, float font_size, float spacing, Color * tint) {
    ImageDrawTextEx(dst, (*font), text, (*position), font_size, spacing, (*tint));
}

SHIM_EXPORT Image * __claw_ImageFromImage(Image * result, Image * image, Rectangle * rec) {
    Image _claw_result = ImageFromImage((*image), (*rec));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_ImageResizeCanvas(Image * image, int new_width, int new_height, int offset_x, int offset_y, Color * fill) {
    ImageResizeCanvas(image, new_width, new_height, offset_x, offset_y, (*fill));
}

SHIM_EXPORT Image * __claw_ImageText(Image * result, char * text, int font_size, Color * color) {
    Image _claw_result = ImageText(text, font_size, (*color));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_ImageTextEx(Image * result, Font * font, char * text, float font_size, float spacing, Color * tint) {
    Image _claw_result = ImageTextEx((*font), text, font_size, spacing, (*tint));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_ImageToPOT(Image * image, Color * fill) {
    ImageToPOT(image, (*fill));
}

SHIM_EXPORT bool __claw_IsAudioStreamPlaying(AudioStream * stream) {
    return IsAudioStreamPlaying((*stream));
}

SHIM_EXPORT bool __claw_IsAudioStreamProcessed(AudioStream * stream) {
    return IsAudioStreamProcessed((*stream));
}

SHIM_EXPORT bool __claw_IsAudioStreamReady(AudioStream * stream) {
    return IsAudioStreamReady((*stream));
}

SHIM_EXPORT bool __claw_IsFontReady(Font * font) {
    return IsFontReady((*font));
}

SHIM_EXPORT bool __claw_IsImageReady(Image * image) {
    return IsImageReady((*image));
}

SHIM_EXPORT bool __claw_IsMaterialReady(Material * material) {
    return IsMaterialReady((*material));
}

SHIM_EXPORT bool __claw_IsModelAnimationValid(Model * model, ModelAnimation * anim) {
    return IsModelAnimationValid((*model), (*anim));
}

SHIM_EXPORT bool __claw_IsModelReady(Model * model) {
    return IsModelReady((*model));
}

SHIM_EXPORT bool __claw_IsMusicReady(Music * music) {
    return IsMusicReady((*music));
}

SHIM_EXPORT bool __claw_IsMusicStreamPlaying(Music * music) {
    return IsMusicStreamPlaying((*music));
}

SHIM_EXPORT bool __claw_IsRenderTextureReady(RenderTexture2D * target) {
    return IsRenderTextureReady((*target));
}

SHIM_EXPORT bool __claw_IsShaderReady(Shader * shader) {
    return IsShaderReady((*shader));
}

SHIM_EXPORT bool __claw_IsSoundPlaying(Sound * sound) {
    return IsSoundPlaying((*sound));
}

SHIM_EXPORT bool __claw_IsSoundReady(Sound * sound) {
    return IsSoundReady((*sound));
}

SHIM_EXPORT bool __claw_IsTextureReady(Texture2D * texture) {
    return IsTextureReady((*texture));
}

SHIM_EXPORT bool __claw_IsWaveReady(Wave * wave) {
    return IsWaveReady((*wave));
}

SHIM_EXPORT float __claw_Lerp(float start, float end, float amount) {
    return Lerp(start, end, amount);
}

SHIM_EXPORT AudioStream * __claw_LoadAudioStream(AudioStream * result, unsigned int sample_rate, unsigned int sample_size, unsigned int channels) {
    AudioStream _claw_result = LoadAudioStream(sample_rate, sample_size, channels);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT FilePathList * __claw_LoadDirectoryFiles(FilePathList * result, char * dir_path) {
    FilePathList _claw_result = LoadDirectoryFiles(dir_path);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT FilePathList * __claw_LoadDirectoryFilesEx(FilePathList * result, char * base_path, char * filter, bool scan_subdirs) {
    FilePathList _claw_result = LoadDirectoryFilesEx(base_path, filter, scan_subdirs);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT FilePathList * __claw_cE3AE40FE40LoadDroppedFiles(FilePathList * result) {
    FilePathList _claw_result = LoadDroppedFiles();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Font * __claw_LoadFont(Font * result, char * file_name) {
    Font _claw_result = LoadFont(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Font * __claw_LoadFontEx(Font * result, char * file_name, int font_size, int * font_chars, int glyph_count) {
    Font _claw_result = LoadFontEx(file_name, font_size, font_chars, glyph_count);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Font * __claw_LoadFontFromImage(Font * result, Image * image, Color * key, int first_char) {
    Font _claw_result = LoadFontFromImage((*image), (*key), first_char);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Font * __claw_LoadFontFromMemory(Font * result, char * file_type, unsigned char * file_data, int data_size, int font_size, int * font_chars, int glyph_count) {
    Font _claw_result = LoadFontFromMemory(file_type, file_data, data_size, font_size, font_chars, glyph_count);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_LoadImage(Image * result, char * file_name) {
    Image _claw_result = LoadImage(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_LoadImageAnim(Image * result, char * file_name, int * frames) {
    Image _claw_result = LoadImageAnim(file_name, frames);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_LoadImageColors(Image * image) {
    return LoadImageColors((*image));
}

SHIM_EXPORT Image * __claw_LoadImageFromMemory(Image * result, char * file_type, unsigned char * file_data, int data_size) {
    Image _claw_result = LoadImageFromMemory(file_type, file_data, data_size);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_cE3AE40FE40LoadImageFromScreen(Image * result) {
    Image _claw_result = LoadImageFromScreen();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Image * __claw_LoadImageFromTexture(Image * result, Texture2D * texture) {
    Image _claw_result = LoadImageFromTexture((*texture));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Color * __claw_LoadImagePalette(Image * image, int max_palette_size, int * color_count) {
    return LoadImagePalette((*image), max_palette_size, color_count);
}

SHIM_EXPORT Image * __claw_LoadImageRaw(Image * result, char * file_name, int width, int height, int format, int header_size) {
    Image _claw_result = LoadImageRaw(file_name, width, height, format, header_size);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Material * __claw_cE3AE40FE40LoadMaterialDefault(Material * result) {
    Material _claw_result = LoadMaterialDefault();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Model * __claw_LoadModel(Model * result, char * file_name) {
    Model _claw_result = LoadModel(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Model * __claw_LoadModelFromMesh(Model * result, Mesh * mesh) {
    Model _claw_result = LoadModelFromMesh((*mesh));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Music * __claw_LoadMusicStream(Music * result, char * file_name) {
    Music _claw_result = LoadMusicStream(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Music * __claw_LoadMusicStreamFromMemory(Music * result, char * file_type, unsigned char * data, int data_size) {
    Music _claw_result = LoadMusicStreamFromMemory(file_type, data, data_size);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT RenderTexture2D * __claw_LoadRenderTexture(RenderTexture2D * result, int width, int height) {
    RenderTexture2D _claw_result = LoadRenderTexture(width, height);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Shader * __claw_LoadShader(Shader * result, char * vs_file_name, char * fs_file_name) {
    Shader _claw_result = LoadShader(vs_file_name, fs_file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Shader * __claw_LoadShaderFromMemory(Shader * result, char * vs_code, char * fs_code) {
    Shader _claw_result = LoadShaderFromMemory(vs_code, fs_code);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Sound * __claw_LoadSound(Sound * result, char * file_name) {
    Sound _claw_result = LoadSound(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Sound * __claw_LoadSoundFromWave(Sound * result, Wave * wave) {
    Sound _claw_result = LoadSoundFromWave((*wave));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Texture2D * __claw_LoadTexture(Texture2D * result, char * file_name) {
    Texture2D _claw_result = LoadTexture(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT TextureCubemap * __claw_LoadTextureCubemap(TextureCubemap * result, Image * image, int layout) {
    TextureCubemap _claw_result = LoadTextureCubemap((*image), layout);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Texture2D * __claw_LoadTextureFromImage(Texture2D * result, Image * image) {
    Texture2D _claw_result = LoadTextureFromImage((*image));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT VrStereoConfig * __claw_LoadVrStereoConfig(VrStereoConfig * result, VrDeviceInfo * device) {
    VrStereoConfig _claw_result = LoadVrStereoConfig((*device));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Wave * __claw_LoadWave(Wave * result, char * file_name) {
    Wave _claw_result = LoadWave(file_name);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Wave * __claw_LoadWaveFromMemory(Wave * result, char * file_type, unsigned char * file_data, int data_size) {
    Wave _claw_result = LoadWaveFromMemory(file_type, file_data, data_size);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float * __claw_LoadWaveSamples(Wave * wave) {
    return LoadWaveSamples((*wave));
}

SHIM_EXPORT Matrix * __claw_MatrixAdd(Matrix * result, Matrix * left, Matrix * right) {
    Matrix _claw_result = MatrixAdd((*left), (*right));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_MatrixDeterminant(Matrix * mat) {
    return MatrixDeterminant((*mat));
}

SHIM_EXPORT Matrix * __claw_MatrixFrustum(Matrix * result, double left, double right, double bottom, double top, double near, double far) {
    Matrix _claw_result = MatrixFrustum(left, right, bottom, top, near, far);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_cE3AE40FE40MatrixIdentity(Matrix * result) {
    Matrix _claw_result = MatrixIdentity();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixInvert(Matrix * result, Matrix * mat) {
    Matrix _claw_result = MatrixInvert((*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixLookAt(Matrix * result, Vector3 * eye, Vector3 * target, Vector3 * up) {
    Matrix _claw_result = MatrixLookAt((*eye), (*target), (*up));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixMultiply(Matrix * result, Matrix * left, Matrix * right) {
    Matrix _claw_result = MatrixMultiply((*left), (*right));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixOrtho(Matrix * result, double left, double right, double bottom, double top, double near, double far) {
    Matrix _claw_result = MatrixOrtho(left, right, bottom, top, near, far);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixPerspective(Matrix * result, double fovy, double aspect, double near, double far) {
    Matrix _claw_result = MatrixPerspective(fovy, aspect, near, far);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixRotate(Matrix * result, Vector3 * axis, float angle) {
    Matrix _claw_result = MatrixRotate((*axis), angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixRotateX(Matrix * result, float angle) {
    Matrix _claw_result = MatrixRotateX(angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixRotateXYZ(Matrix * result, Vector3 * angle) {
    Matrix _claw_result = MatrixRotateXYZ((*angle));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixRotateY(Matrix * result, float angle) {
    Matrix _claw_result = MatrixRotateY(angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixRotateZ(Matrix * result, float angle) {
    Matrix _claw_result = MatrixRotateZ(angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixRotateZYX(Matrix * result, Vector3 * angle) {
    Matrix _claw_result = MatrixRotateZYX((*angle));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixScale(Matrix * result, float x, float y, float z) {
    Matrix _claw_result = MatrixScale(x, y, z);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixSubtract(Matrix * result, Matrix * left, Matrix * right) {
    Matrix _claw_result = MatrixSubtract((*left), (*right));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float16 * __claw_MatrixToFloatV(float16 * result, Matrix * mat) {
    float16 _claw_result = MatrixToFloatV((*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_MatrixTrace(Matrix * mat) {
    return MatrixTrace((*mat));
}

SHIM_EXPORT Matrix * __claw_MatrixTranslate(Matrix * result, float x, float y, float z) {
    Matrix _claw_result = MatrixTranslate(x, y, z);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_MatrixTranspose(Matrix * result, Matrix * mat) {
    Matrix _claw_result = MatrixTranspose((*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_MeasureTextEx(Vector2 * result, Font * font, char * text, float font_size, float spacing) {
    Vector2 _claw_result = MeasureTextEx((*font), text, font_size, spacing);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Normalize(float value, float start, float end) {
    return Normalize(value, start, end);
}

SHIM_EXPORT void __claw_PauseAudioStream(AudioStream * stream) {
    PauseAudioStream((*stream));
}

SHIM_EXPORT void __claw_PauseMusicStream(Music * music) {
    PauseMusicStream((*music));
}

SHIM_EXPORT void __claw_PauseSound(Sound * sound) {
    PauseSound((*sound));
}

SHIM_EXPORT void __claw_PlayAudioStream(AudioStream * stream) {
    PlayAudioStream((*stream));
}

SHIM_EXPORT void __claw_PlayMusicStream(Music * music) {
    PlayMusicStream((*music));
}

SHIM_EXPORT void __claw_PlaySound(Sound * sound) {
    PlaySound((*sound));
}

SHIM_EXPORT Quaternion * __claw_QuaternionAdd(Quaternion * result, Quaternion * q1, Quaternion * q2) {
    Quaternion _claw_result = QuaternionAdd((*q1), (*q2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionAddValue(Quaternion * result, Quaternion * q, float add) {
    Quaternion _claw_result = QuaternionAddValue((*q), add);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionDivide(Quaternion * result, Quaternion * q1, Quaternion * q2) {
    Quaternion _claw_result = QuaternionDivide((*q1), (*q2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_QuaternionEquals(Quaternion * p, Quaternion * q) {
    return QuaternionEquals((*p), (*q));
}

SHIM_EXPORT Quaternion * __claw_QuaternionFromAxisAngle(Quaternion * result, Vector3 * axis, float angle) {
    Quaternion _claw_result = QuaternionFromAxisAngle((*axis), angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionFromEuler(Quaternion * result, float pitch, float yaw, float roll) {
    Quaternion _claw_result = QuaternionFromEuler(pitch, yaw, roll);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionFromMatrix(Quaternion * result, Matrix * mat) {
    Quaternion _claw_result = QuaternionFromMatrix((*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionFromVector3ToVector3(Quaternion * result, Vector3 * from, Vector3 * to) {
    Quaternion _claw_result = QuaternionFromVector3ToVector3((*from), (*to));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_cE3AE40FE40QuaternionIdentity(Quaternion * result) {
    Quaternion _claw_result = QuaternionIdentity();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionInvert(Quaternion * result, Quaternion * q) {
    Quaternion _claw_result = QuaternionInvert((*q));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_QuaternionLength(Quaternion * q) {
    return QuaternionLength((*q));
}

SHIM_EXPORT Quaternion * __claw_QuaternionLerp(Quaternion * result, Quaternion * q1, Quaternion * q2, float amount) {
    Quaternion _claw_result = QuaternionLerp((*q1), (*q2), amount);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionMultiply(Quaternion * result, Quaternion * q1, Quaternion * q2) {
    Quaternion _claw_result = QuaternionMultiply((*q1), (*q2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionNlerp(Quaternion * result, Quaternion * q1, Quaternion * q2, float amount) {
    Quaternion _claw_result = QuaternionNlerp((*q1), (*q2), amount);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionNormalize(Quaternion * result, Quaternion * q) {
    Quaternion _claw_result = QuaternionNormalize((*q));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionScale(Quaternion * result, Quaternion * q, float mul) {
    Quaternion _claw_result = QuaternionScale((*q), mul);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionSlerp(Quaternion * result, Quaternion * q1, Quaternion * q2, float amount) {
    Quaternion _claw_result = QuaternionSlerp((*q1), (*q2), amount);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionSubtract(Quaternion * result, Quaternion * q1, Quaternion * q2) {
    Quaternion _claw_result = QuaternionSubtract((*q1), (*q2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionSubtractValue(Quaternion * result, Quaternion * q, float sub) {
    Quaternion _claw_result = QuaternionSubtractValue((*q), sub);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_QuaternionToAxisAngle(Quaternion * q, Vector3 * out_axis, float * out_angle) {
    QuaternionToAxisAngle((*q), out_axis, out_angle);
}

SHIM_EXPORT Vector3 * __claw_QuaternionToEuler(Vector3 * result, Quaternion * q) {
    Vector3 _claw_result = QuaternionToEuler((*q));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Matrix * __claw_QuaternionToMatrix(Matrix * result, Quaternion * q) {
    Matrix _claw_result = QuaternionToMatrix((*q));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Quaternion * __claw_QuaternionTransform(Quaternion * result, Quaternion * q, Matrix * mat) {
    Quaternion _claw_result = QuaternionTransform((*q), (*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Remap(float value, float input_start, float input_end, float output_start, float output_end) {
    return Remap(value, input_start, input_end, output_start, output_end);
}

SHIM_EXPORT void __claw_ResumeAudioStream(AudioStream * stream) {
    ResumeAudioStream((*stream));
}

SHIM_EXPORT void __claw_ResumeMusicStream(Music * music) {
    ResumeMusicStream((*music));
}

SHIM_EXPORT void __claw_ResumeSound(Sound * sound) {
    ResumeSound((*sound));
}

SHIM_EXPORT void __claw_SeekMusicStream(Music * music, float position) {
    SeekMusicStream((*music), position);
}

SHIM_EXPORT void __claw_SetAudioStreamCallback(AudioStream * stream, AudioCallback callback) {
    SetAudioStreamCallback((*stream), callback);
}

SHIM_EXPORT void __claw_SetAudioStreamPan(AudioStream * stream, float pan) {
    SetAudioStreamPan((*stream), pan);
}

SHIM_EXPORT void __claw_SetAudioStreamPitch(AudioStream * stream, float pitch) {
    SetAudioStreamPitch((*stream), pitch);
}

SHIM_EXPORT void __claw_SetAudioStreamVolume(AudioStream * stream, float volume) {
    SetAudioStreamVolume((*stream), volume);
}

SHIM_EXPORT void __claw_SetMaterialTexture(Material * material, int map_type, Texture2D * texture) {
    SetMaterialTexture(material, map_type, (*texture));
}

SHIM_EXPORT void __claw_SetMusicPan(Music * music, float pan) {
    SetMusicPan((*music), pan);
}

SHIM_EXPORT void __claw_SetMusicPitch(Music * music, float pitch) {
    SetMusicPitch((*music), pitch);
}

SHIM_EXPORT void __claw_SetMusicVolume(Music * music, float volume) {
    SetMusicVolume((*music), volume);
}

SHIM_EXPORT void __claw_SetPixelColor(void * dst_ptr, Color * color, int format) {
    SetPixelColor(dst_ptr, (*color), format);
}

SHIM_EXPORT void __claw_SetShaderValue(Shader * shader, int loc_index, void * value, int uniform_type) {
    SetShaderValue((*shader), loc_index, value, uniform_type);
}

SHIM_EXPORT void __claw_SetShaderValueMatrix(Shader * shader, int loc_index, Matrix * mat) {
    SetShaderValueMatrix((*shader), loc_index, (*mat));
}

SHIM_EXPORT void __claw_SetShaderValueTexture(Shader * shader, int loc_index, Texture2D * texture) {
    SetShaderValueTexture((*shader), loc_index, (*texture));
}

SHIM_EXPORT void __claw_SetShaderValueV(Shader * shader, int loc_index, void * value, int uniform_type, int count) {
    SetShaderValueV((*shader), loc_index, value, uniform_type, count);
}

SHIM_EXPORT void __claw_SetShapesTexture(Texture2D * texture, Rectangle * source) {
    SetShapesTexture((*texture), (*source));
}

SHIM_EXPORT void __claw_SetSoundPan(Sound * sound, float pan) {
    SetSoundPan((*sound), pan);
}

SHIM_EXPORT void __claw_SetSoundPitch(Sound * sound, float pitch) {
    SetSoundPitch((*sound), pitch);
}

SHIM_EXPORT void __claw_SetSoundVolume(Sound * sound, float volume) {
    SetSoundVolume((*sound), volume);
}

SHIM_EXPORT void __claw_SetTextureFilter(Texture2D * texture, int filter) {
    SetTextureFilter((*texture), filter);
}

SHIM_EXPORT void __claw_SetTextureWrap(Texture2D * texture, int wrap) {
    SetTextureWrap((*texture), wrap);
}

SHIM_EXPORT void __claw_SetWindowIcon(Image * image) {
    SetWindowIcon((*image));
}

SHIM_EXPORT void __claw_StopAudioStream(AudioStream * stream) {
    StopAudioStream((*stream));
}

SHIM_EXPORT void __claw_StopMusicStream(Music * music) {
    StopMusicStream((*music));
}

SHIM_EXPORT void __claw_StopSound(Sound * sound) {
    StopSound((*sound));
}

SHIM_EXPORT void __claw_UnloadAudioStream(AudioStream * stream) {
    UnloadAudioStream((*stream));
}

SHIM_EXPORT void __claw_UnloadDirectoryFiles(FilePathList * files) {
    UnloadDirectoryFiles((*files));
}

SHIM_EXPORT void __claw_UnloadDroppedFiles(FilePathList * files) {
    UnloadDroppedFiles((*files));
}

SHIM_EXPORT void __claw_UnloadFont(Font * font) {
    UnloadFont((*font));
}

SHIM_EXPORT void __claw_UnloadImage(Image * image) {
    UnloadImage((*image));
}

SHIM_EXPORT void __claw_UnloadMaterial(Material * material) {
    UnloadMaterial((*material));
}

SHIM_EXPORT void __claw_UnloadMesh(Mesh * mesh) {
    UnloadMesh((*mesh));
}

SHIM_EXPORT void __claw_UnloadModel(Model * model) {
    UnloadModel((*model));
}

SHIM_EXPORT void __claw_UnloadModelAnimation(ModelAnimation * anim) {
    UnloadModelAnimation((*anim));
}

SHIM_EXPORT void __claw_UnloadMusicStream(Music * music) {
    UnloadMusicStream((*music));
}

SHIM_EXPORT void __claw_UnloadRenderTexture(RenderTexture2D * target) {
    UnloadRenderTexture((*target));
}

SHIM_EXPORT void __claw_UnloadShader(Shader * shader) {
    UnloadShader((*shader));
}

SHIM_EXPORT void __claw_UnloadSound(Sound * sound) {
    UnloadSound((*sound));
}

SHIM_EXPORT void __claw_UnloadTexture(Texture2D * texture) {
    UnloadTexture((*texture));
}

SHIM_EXPORT void __claw_UnloadVrStereoConfig(VrStereoConfig * config) {
    UnloadVrStereoConfig((*config));
}

SHIM_EXPORT void __claw_UnloadWave(Wave * wave) {
    UnloadWave((*wave));
}

SHIM_EXPORT void __claw_UpdateAudioStream(AudioStream * stream, void * data, int frame_count) {
    UpdateAudioStream((*stream), data, frame_count);
}

SHIM_EXPORT void __claw_UpdateCameraPro(Camera * camera, Vector3 * movement, Vector3 * rotation, float zoom) {
    UpdateCameraPro(camera, (*movement), (*rotation), zoom);
}

SHIM_EXPORT void __claw_UpdateMeshBuffer(Mesh * mesh, int index, void * data, int data_size, int offset) {
    UpdateMeshBuffer((*mesh), index, data, data_size, offset);
}

SHIM_EXPORT void __claw_UpdateModelAnimation(Model * model, ModelAnimation * anim, int frame) {
    UpdateModelAnimation((*model), (*anim), frame);
}

SHIM_EXPORT void __claw_UpdateMusicStream(Music * music) {
    UpdateMusicStream((*music));
}

SHIM_EXPORT void __claw_UpdateSound(Sound * sound, void * data, int sample_count) {
    UpdateSound((*sound), data, sample_count);
}

SHIM_EXPORT void __claw_UpdateTexture(Texture2D * texture, void * pixels) {
    UpdateTexture((*texture), pixels);
}

SHIM_EXPORT void __claw_UpdateTextureRec(Texture2D * texture, Rectangle * rec, void * pixels) {
    UpdateTextureRec((*texture), (*rec), pixels);
}

SHIM_EXPORT Vector2 * __claw_Vector2Add(Vector2 * result, Vector2 * v1, Vector2 * v2) {
    Vector2 _claw_result = Vector2Add((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2AddValue(Vector2 * result, Vector2 * v, float add) {
    Vector2 _claw_result = Vector2AddValue((*v), add);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector2Angle(Vector2 * v1, Vector2 * v2) {
    return Vector2Angle((*v1), (*v2));
}

SHIM_EXPORT Vector2 * __claw_Vector2Clamp(Vector2 * result, Vector2 * v, Vector2 * min, Vector2 * max) {
    Vector2 _claw_result = Vector2Clamp((*v), (*min), (*max));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2ClampValue(Vector2 * result, Vector2 * v, float min, float max) {
    Vector2 _claw_result = Vector2ClampValue((*v), min, max);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector2Distance(Vector2 * v1, Vector2 * v2) {
    return Vector2Distance((*v1), (*v2));
}

SHIM_EXPORT float __claw_Vector2DistanceSqr(Vector2 * v1, Vector2 * v2) {
    return Vector2DistanceSqr((*v1), (*v2));
}

SHIM_EXPORT Vector2 * __claw_Vector2Divide(Vector2 * result, Vector2 * v1, Vector2 * v2) {
    Vector2 _claw_result = Vector2Divide((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector2DotProduct(Vector2 * v1, Vector2 * v2) {
    return Vector2DotProduct((*v1), (*v2));
}

SHIM_EXPORT int __claw_Vector2Equals(Vector2 * p, Vector2 * q) {
    return Vector2Equals((*p), (*q));
}

SHIM_EXPORT Vector2 * __claw_Vector2Invert(Vector2 * result, Vector2 * v) {
    Vector2 _claw_result = Vector2Invert((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector2Length(Vector2 * v) {
    return Vector2Length((*v));
}

SHIM_EXPORT float __claw_Vector2LengthSqr(Vector2 * v) {
    return Vector2LengthSqr((*v));
}

SHIM_EXPORT Vector2 * __claw_Vector2Lerp(Vector2 * result, Vector2 * v1, Vector2 * v2, float amount) {
    Vector2 _claw_result = Vector2Lerp((*v1), (*v2), amount);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector2LineAngle(Vector2 * start, Vector2 * end) {
    return Vector2LineAngle((*start), (*end));
}

SHIM_EXPORT Vector2 * __claw_Vector2MoveTowards(Vector2 * result, Vector2 * v, Vector2 * target, float max_distance) {
    Vector2 _claw_result = Vector2MoveTowards((*v), (*target), max_distance);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Multiply(Vector2 * result, Vector2 * v1, Vector2 * v2) {
    Vector2 _claw_result = Vector2Multiply((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Negate(Vector2 * result, Vector2 * v) {
    Vector2 _claw_result = Vector2Negate((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Normalize(Vector2 * result, Vector2 * v) {
    Vector2 _claw_result = Vector2Normalize((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40Vector2One(Vector2 * result) {
    Vector2 _claw_result = Vector2One();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Reflect(Vector2 * result, Vector2 * v, Vector2 * normal) {
    Vector2 _claw_result = Vector2Reflect((*v), (*normal));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Rotate(Vector2 * result, Vector2 * v, float angle) {
    Vector2 _claw_result = Vector2Rotate((*v), angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Scale(Vector2 * result, Vector2 * v, float scale) {
    Vector2 _claw_result = Vector2Scale((*v), scale);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Subtract(Vector2 * result, Vector2 * v1, Vector2 * v2) {
    Vector2 _claw_result = Vector2Subtract((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2SubtractValue(Vector2 * result, Vector2 * v, float sub) {
    Vector2 _claw_result = Vector2SubtractValue((*v), sub);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_Vector2Transform(Vector2 * result, Vector2 * v, Matrix * mat) {
    Vector2 _claw_result = Vector2Transform((*v), (*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector2 * __claw_cE3AE40FE40Vector2Zero(Vector2 * result) {
    Vector2 _claw_result = Vector2Zero();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Add(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3Add((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3AddValue(Vector3 * result, Vector3 * v, float add) {
    Vector3 _claw_result = Vector3AddValue((*v), add);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector3Angle(Vector3 * v1, Vector3 * v2) {
    return Vector3Angle((*v1), (*v2));
}

SHIM_EXPORT Vector3 * __claw_Vector3Barycenter(Vector3 * result, Vector3 * p, Vector3 * a, Vector3 * b, Vector3 * c) {
    Vector3 _claw_result = Vector3Barycenter((*p), (*a), (*b), (*c));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Clamp(Vector3 * result, Vector3 * v, Vector3 * min, Vector3 * max) {
    Vector3 _claw_result = Vector3Clamp((*v), (*min), (*max));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3ClampValue(Vector3 * result, Vector3 * v, float min, float max) {
    Vector3 _claw_result = Vector3ClampValue((*v), min, max);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3CrossProduct(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3CrossProduct((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector3Distance(Vector3 * v1, Vector3 * v2) {
    return Vector3Distance((*v1), (*v2));
}

SHIM_EXPORT float __claw_Vector3DistanceSqr(Vector3 * v1, Vector3 * v2) {
    return Vector3DistanceSqr((*v1), (*v2));
}

SHIM_EXPORT Vector3 * __claw_Vector3Divide(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3Divide((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector3DotProduct(Vector3 * v1, Vector3 * v2) {
    return Vector3DotProduct((*v1), (*v2));
}

SHIM_EXPORT int __claw_Vector3Equals(Vector3 * p, Vector3 * q) {
    return Vector3Equals((*p), (*q));
}

SHIM_EXPORT Vector3 * __claw_Vector3Invert(Vector3 * result, Vector3 * v) {
    Vector3 _claw_result = Vector3Invert((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Vector3Length(Vector3 * v) {
    return Vector3Length((*v));
}

SHIM_EXPORT float __claw_Vector3LengthSqr(Vector3 * v) {
    return Vector3LengthSqr((*v));
}

SHIM_EXPORT Vector3 * __claw_Vector3Lerp(Vector3 * result, Vector3 * v1, Vector3 * v2, float amount) {
    Vector3 _claw_result = Vector3Lerp((*v1), (*v2), amount);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Max(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3Max((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Min(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3Min((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Multiply(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3Multiply((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Negate(Vector3 * result, Vector3 * v) {
    Vector3 _claw_result = Vector3Negate((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Normalize(Vector3 * result, Vector3 * v) {
    Vector3 _claw_result = Vector3Normalize((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_cE3AE40FE40Vector3One(Vector3 * result) {
    Vector3 _claw_result = Vector3One();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT void __claw_Vector3OrthoNormalize(Vector3 * v1, Vector3 * v2) {
    Vector3OrthoNormalize(v1, v2);
}

SHIM_EXPORT Vector3 * __claw_Vector3Perpendicular(Vector3 * result, Vector3 * v) {
    Vector3 _claw_result = Vector3Perpendicular((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Reflect(Vector3 * result, Vector3 * v, Vector3 * normal) {
    Vector3 _claw_result = Vector3Reflect((*v), (*normal));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Refract(Vector3 * result, Vector3 * v, Vector3 * n, float r) {
    Vector3 _claw_result = Vector3Refract((*v), (*n), r);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3RotateByAxisAngle(Vector3 * result, Vector3 * v, Vector3 * axis, float angle) {
    Vector3 _claw_result = Vector3RotateByAxisAngle((*v), (*axis), angle);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3RotateByQuaternion(Vector3 * result, Vector3 * v, Quaternion * q) {
    Vector3 _claw_result = Vector3RotateByQuaternion((*v), (*q));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Scale(Vector3 * result, Vector3 * v, float scalar) {
    Vector3 _claw_result = Vector3Scale((*v), scalar);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Subtract(Vector3 * result, Vector3 * v1, Vector3 * v2) {
    Vector3 _claw_result = Vector3Subtract((*v1), (*v2));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3SubtractValue(Vector3 * result, Vector3 * v, float sub) {
    Vector3 _claw_result = Vector3SubtractValue((*v), sub);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float3 * __claw_Vector3ToFloatV(float3 * result, Vector3 * v) {
    float3 _claw_result = Vector3ToFloatV((*v));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Transform(Vector3 * result, Vector3 * v, Matrix * mat) {
    Vector3 _claw_result = Vector3Transform((*v), (*mat));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_Vector3Unproject(Vector3 * result, Vector3 * source, Matrix * projection, Matrix * view) {
    Vector3 _claw_result = Vector3Unproject((*source), (*projection), (*view));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Vector3 * __claw_cE3AE40FE40Vector3Zero(Vector3 * result) {
    Vector3 _claw_result = Vector3Zero();
    *result = _claw_result;
    return result;
}

SHIM_EXPORT Wave * __claw_WaveCopy(Wave * result, Wave * wave) {
    Wave _claw_result = WaveCopy((*wave));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT float __claw_Wrap(float value, float min, float max) {
    return Wrap(value, min, max);
}

SHIM_EXPORT long double * __claw_acoshl(long double * result, long double * __x) {
    long double _claw_result = acoshl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_acosl(long double * result, long double * __x) {
    long double _claw_result = acosl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_asinhl(long double * result, long double * __x) {
    long double _claw_result = asinhl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_asinl(long double * result, long double * __x) {
    long double _claw_result = asinl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_atan2l(long double * result, long double * __y, long double * __x) {
    long double _claw_result = atan2l((*__y), (*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_atanhl(long double * result, long double * __x) {
    long double _claw_result = atanhl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_atanl(long double * result, long double * __x) {
    long double _claw_result = atanl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cbrtl(long double * result, long double * __x) {
    long double _claw_result = cbrtl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_ceill(long double * result, long double * __x) {
    long double _claw_result = ceill((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_copysignl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = copysignl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_coshl(long double * result, long double * __x) {
    long double _claw_result = coshl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cosl(long double * result, long double * __x) {
    long double _claw_result = cosl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_dreml(long double * result, long double * __x, long double * __y) {
    long double _claw_result = dreml((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40erfcl(long double * result, long double * arg0) {
    long double _claw_result = erfcl((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40erfl(long double * result, long double * arg0) {
    long double _claw_result = erfl((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_exp2l(long double * result, long double * __x) {
    long double _claw_result = exp2l((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_expl(long double * result, long double * __x) {
    long double _claw_result = expl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_expm1l(long double * result, long double * __x) {
    long double _claw_result = expm1l((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_fabsl(long double * result, long double * __x) {
    long double _claw_result = fabsl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_fdiml(long double * result, long double * __x, long double * __y) {
    long double _claw_result = fdiml((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_finitel(long double * __value) {
    return finitel((*__value));
}

SHIM_EXPORT long double * __claw_floorl(long double * result, long double * __x) {
    long double _claw_result = floorl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_fmal(long double * result, long double * __x, long double * __y, long double * __z) {
    long double _claw_result = fmal((*__x), (*__y), (*__z));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_fmaxl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = fmaxl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_fminl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = fminl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_fmodl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = fmodl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_frexpl(long double * result, long double * __x, int * __exponent) {
    long double _claw_result = frexpl((*__x), __exponent);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40gammal(long double * result, long double * arg0) {
    long double _claw_result = gammal((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_hypotl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = hypotl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT int __claw_ilogbl(long double * __x) {
    return ilogbl((*__x));
}

SHIM_EXPORT int __claw_isinfl(long double * __value) {
    return isinfl((*__value));
}

SHIM_EXPORT int __claw_isnanl(long double * __value) {
    return isnanl((*__value));
}

SHIM_EXPORT long double * __claw_cE3AE40FE40j0l(long double * result, long double * arg0) {
    long double _claw_result = j0l((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40j1l(long double * result, long double * arg0) {
    long double _claw_result = j1l((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40jnl(long double * result, int arg0, long double * arg1) {
    long double _claw_result = jnl(arg0, (*arg1));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_ldexpl(long double * result, long double * __x, int __exponent) {
    long double _claw_result = ldexpl((*__x), __exponent);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40lgammal(long double * result, long double * arg0) {
    long double _claw_result = lgammal((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_lgammal_r(long double * result, long double * arg0, int * __signgamp) {
    long double _claw_result = lgammal_r((*arg0), __signgamp);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long long __claw_llrintl(long double * __x) {
    return llrintl((*__x));
}

SHIM_EXPORT long long __claw_llroundl(long double * __x) {
    return llroundl((*__x));
}

SHIM_EXPORT long double * __claw_log10l(long double * result, long double * __x) {
    long double _claw_result = log10l((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_log1pl(long double * result, long double * __x) {
    long double _claw_result = log1pl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_log2l(long double * result, long double * __x) {
    long double _claw_result = log2l((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_logbl(long double * result, long double * __x) {
    long double _claw_result = logbl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_logl(long double * result, long double * __x) {
    long double _claw_result = logl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long __claw_lrintl(long double * __x) {
    return lrintl((*__x));
}

SHIM_EXPORT long __claw_lroundl(long double * __x) {
    return lroundl((*__x));
}

SHIM_EXPORT long double * __claw_modfl(long double * result, long double * __x, long double * __iptr) {
    long double _claw_result = modfl((*__x), __iptr);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_nanl(long double * result, char * __tagb) {
    long double _claw_result = nanl(__tagb);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_nearbyintl(long double * result, long double * __x) {
    long double _claw_result = nearbyintl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_nextafterl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = nextafterl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT double __claw_nexttoward(double __x, long double * __y) {
    return nexttoward(__x, (*__y));
}

SHIM_EXPORT float __claw_nexttowardf(float __x, long double * __y) {
    return nexttowardf(__x, (*__y));
}

SHIM_EXPORT long double * __claw_nexttowardl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = nexttowardl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_powl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = powl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT char * __claw_qecvt(long double * __value, int __ndigit, int * __decpt, int * __sign) {
    return qecvt((*__value), __ndigit, __decpt, __sign);
}

SHIM_EXPORT char * __claw_qfcvt(long double * __value, int __ndigit, int * __decpt, int * __sign) {
    return qfcvt((*__value), __ndigit, __decpt, __sign);
}

SHIM_EXPORT char * __claw_qgcvt(long double * __value, int __ndigit, char * __buf) {
    return qgcvt((*__value), __ndigit, __buf);
}

SHIM_EXPORT long double * __claw_remainderl(long double * result, long double * __x, long double * __y) {
    long double _claw_result = remainderl((*__x), (*__y));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_remquol(long double * result, long double * __x, long double * __y, int * __quo) {
    long double _claw_result = remquol((*__x), (*__y), __quo);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_rintl(long double * result, long double * __x) {
    long double _claw_result = rintl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_roundl(long double * result, long double * __x) {
    long double _claw_result = roundl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_scalbl(long double * result, long double * __x, long double * __n) {
    long double _claw_result = scalbl((*__x), (*__n));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_scalblnl(long double * result, long double * __x, long __n) {
    long double _claw_result = scalblnl((*__x), __n);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_scalbnl(long double * result, long double * __x, int __n) {
    long double _claw_result = scalbnl((*__x), __n);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_significandl(long double * result, long double * __x) {
    long double _claw_result = significandl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_sinhl(long double * result, long double * __x) {
    long double _claw_result = sinhl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_sinl(long double * result, long double * __x) {
    long double _claw_result = sinl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_sqrtl(long double * result, long double * __x) {
    long double _claw_result = sqrtl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_strtold(long double * result, char * __nptr, char * __endptr) {
    long double _claw_result = strtold(__nptr, (char **)__endptr);
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_tanhl(long double * result, long double * __x) {
    long double _claw_result = tanhl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_tanl(long double * result, long double * __x) {
    long double _claw_result = tanl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40tgammal(long double * result, long double * arg0) {
    long double _claw_result = tgammal((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_truncl(long double * result, long double * __x) {
    long double _claw_result = truncl((*__x));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40y0l(long double * result, long double * arg0) {
    long double _claw_result = y0l((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40y1l(long double * result, long double * arg0) {
    long double _claw_result = y1l((*arg0));
    *result = _claw_result;
    return result;
}

SHIM_EXPORT long double * __claw_cE3AE40FE40ynl(long double * result, int arg0, long double * arg1) {
    long double _claw_result = ynl(arg0, (*arg1));
    *result = _claw_result;
    return result;
}
