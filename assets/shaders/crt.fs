#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;

out vec4 finalColor;

const vec2 resolution = vec2(1280.0, 720.0);

vec2 curve(vec2 uv)
{
    vec2 centered = uv * 2.0 - 1.0;
    vec2 offset = abs(centered.yx) / vec2(5.3, 4.2);
    centered += centered * offset * offset;
    return centered * 0.5 + 0.5;
}

void main()
{
    vec2 uv = curve(fragTexCoord);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        finalColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec2 px = 1.0 / resolution;
    vec3 base = texture(texture0, uv).rgb;
    vec3 bloom = vec3(0.0);

    bloom += texture(texture0, uv + vec2( px.x * 1.5, 0.0)).rgb;
    bloom += texture(texture0, uv + vec2(-px.x * 1.5, 0.0)).rgb;
    bloom += texture(texture0, uv + vec2(0.0,  px.y * 1.5)).rgb;
    bloom += texture(texture0, uv + vec2(0.0, -px.y * 1.5)).rgb;
    bloom += texture(texture0, uv + vec2( px.x * 3.0,  px.y * 3.0)).rgb;
    bloom += texture(texture0, uv + vec2(-px.x * 3.0, -px.y * 3.0)).rgb;
    bloom *= 0.09;

    float scanline = 0.84 + 0.16 * sin(uv.y * resolution.y * 3.14159);
    float grille = 0.92 + 0.08 * sin(uv.x * resolution.x * 2.094);
    float vignette = smoothstep(0.85, 0.24, distance(uv, vec2(0.5)));

    vec3 phosphor = vec3(0.88, 1.0, 0.92);
    vec3 color = (base + bloom) * phosphor * scanline * grille * vignette;

    finalColor = vec4(color, 1.0) * fragColor;
}
