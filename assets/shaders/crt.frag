#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;

// uInvert: 0 = ink-on-black (default), 1 = invert the achromatic channel only,
//          so black<->white flip but the yellow crown and any future accent
//          colour pass through untouched ("Embrace the Holy Light").
// uOff:    0 = screen fully on (default / normal look), 1 = fully off. Drives the
//          CRT power animation: the picture collapses to a bright line, then a
//          dot. Both uniforms default to 0, so an unset shader looks normal.
uniform float uInvert;
uniform float uOff;

out vec4 finalColor;

const vec2 resolution = vec2(1280.0, 720.0);

vec2 curve(vec2 uv)
{
    vec2 centered = uv * 2.0 - 1.0;
    vec2 offset = abs(centered.yx) / vec2(5.3, 4.2);
    centered += centered * offset * offset;
    return centered * 0.5 + 0.5;
}

// Sample the scene, optionally inverting only the grey (achromatic) part so the
// light theme flips paper and ink without touching coloured accents.
vec3 sampleScene(vec2 uv)
{
    vec3 c = texture(texture0, uv).rgb;
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float chroma = mx - mn;
    float keep = smoothstep(0.14, 0.30, chroma); // 1 for coloured pixels
    vec3 inverted = mix(vec3(1.0) - c, c, keep);
    return mix(c, inverted, uInvert);
}

void main()
{
    vec2 uv0 = curve(fragTexCoord);

    // CRT power collapse: as uOff goes 0->1 the height squeezes to a line first,
    // then the line narrows to a dot.
    float vScale = 1.0 - smoothstep(0.0, 0.55, uOff);
    float hScale = 1.0 - smoothstep(0.55, 1.0, uOff);
    vec2 rel = uv0 - 0.5;
    vec2 uv = vec2(rel.x / max(hScale, 0.0015),
                   rel.y / max(vScale, 0.0015)) + 0.5;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        finalColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec2 px = 1.0 / resolution;
    vec3 base = sampleScene(uv);
    vec3 bloom = vec3(0.0);

    bloom += sampleScene(uv + vec2( px.x * 1.5, 0.0));
    bloom += sampleScene(uv + vec2(-px.x * 1.5, 0.0));
    bloom += sampleScene(uv + vec2(0.0,  px.y * 1.5));
    bloom += sampleScene(uv + vec2(0.0, -px.y * 1.5));
    bloom += sampleScene(uv + vec2( px.x * 3.0,  px.y * 3.0));
    bloom += sampleScene(uv + vec2(-px.x * 3.0, -px.y * 3.0));
    bloom *= 0.09;

    float scanline = 0.84 + 0.16 * sin(uv.y * resolution.y * 3.14159);
    float grille = 0.92 + 0.08 * sin(uv.x * resolution.x * 2.094);
    float vignette = smoothstep(0.85, 0.24, distance(uv, vec2(0.5)));
    vignette = mix(1.0, vignette, 0.667); // ease the corner darkening by a third

    vec3 phosphor = vec3(0.88, 1.0, 0.92);
    vec3 color = (base + bloom) * phosphor * scanline * grille * vignette;

    // The collapsing picture overdrives the surviving scanline into a white bar.
    float lineGlow = 1.0 - vScale;
    float band = exp(-pow((uv0.y - 0.5) * 9.0, 2.0));
    color += vec3(0.9, 1.0, 0.95) * lineGlow * band * 1.4 * hScale;

    finalColor = vec4(color, 1.0) * fragColor;
}
