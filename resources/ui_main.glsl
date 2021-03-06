float RADIUS = 25.;
vec2 PAT_SIZE = vec2(45., 75.);

vec4 fancy_rect(vec2 center, vec2 size, bool selected) {
    vec4 c;
    vec4 color;

    if(selected) {
        float highlight_df = rounded_rect_df(center, size, RADIUS - 10.);
        color = vec4(1., 1., 0., 0.5 * (1. - smoothstep(0., 50., max(highlight_df, 0.))));
    } else {
        float shadow_df = rounded_rect_df(center + vec2(10., -10.), size, RADIUS - 10.);
        color = vec4(0., 0., 0., 0.5 * (1. - smoothstep(0., 20., max(shadow_df, 0.))));
    }

    float df = rounded_rect_df(center, size, RADIUS);
    c = vec4(vec3(0.1) * (center.y + size.y + RADIUS - gl_FragCoord.y) / (2. * (size.y + RADIUS)), clamp(1. - df, 0., 1.));
    color = composite(color, c);
    return color;
}

float sdCapsule( vec2 p, vec2 a, vec2 b, float r )
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

void glow(vec2 p) {
    vec2 LEN = vec2(300., 0.);
    float FRINGE = 75.;
    gl_FragColor = composite(gl_FragColor, vec4(0., 0.5, 1., 0.5 * max(0., 1. - sdCapsule(gl_FragCoord.xy, p - LEN, p + LEN, FRINGE) / FRINGE)));
}

void main(void) {
    vec2 uv = gl_FragCoord.xy / iResolution;

    if(iSelection) {
        gl_FragColor = vec4(0., 0., 0., 1.);
        for(int i=0; i < 8; i++) {
            ivec3 c;
            c = ivec3(1, i, 0);
            vec2 p = vec2(175. + (i + 2 * int(i >= 4)) * 175., 420.);
            gl_FragColor = composite(gl_FragColor, vec4(dataColor(c), rounded_rect_df(p, PAT_SIZE, RADIUS) <= 1.));
            p = vec2(175. + (i + 2 * int(i >= 4)) * 175., 180.);
            c.y += 8;
            gl_FragColor = composite(gl_FragColor, vec4(dataColor(c), rounded_rect_df(p, PAT_SIZE, RADIUS) <= 1.));
        }
        gl_FragColor = composite(gl_FragColor, vec4(dataColor(ivec3(3, 0, 0)), rounded_rect_df(vec2(975., 300.), PAT_SIZE, RADIUS) <= 1.));
    } else {
        float g = uv.y * 0.1 + 0.2;
        gl_FragColor = vec4(g, g, g, 1.);

        glow(vec2(475., iLeftDeckSelector == 0 ? 420. : 180.));
        glow(vec2(1475., iRightDeckSelector == 1 ? 420. : 180.));

        for(int i=0; i < 8; i++) {
            vec2 p;
            p = vec2(175. + (i + 2 * int(i >= 4)) * 175., 420.);
            gl_FragColor = composite(gl_FragColor, fancy_rect(p, PAT_SIZE, iSelected == i + 1));
            p = vec2(175. + (i + 2 * int(i >= 4)) * 175., 180.);
            gl_FragColor = composite(gl_FragColor, fancy_rect(p, PAT_SIZE, iSelected == i + 9));
        }
        gl_FragColor = composite(gl_FragColor, fancy_rect(vec2(962.5, 300.), vec2(130., 200.), iSelected == 17 || iSelected == 18));
        gl_FragColor = composite(gl_FragColor, fancy_rect(vec2(300., 650.), vec2(165., 65.), false));
        gl_FragColor = composite(gl_FragColor, fancy_rect(vec2(700., 650.), vec2(165., 65.), false));
    }
}
