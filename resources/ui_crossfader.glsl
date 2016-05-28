#version 130

uniform vec2 iResolution;
uniform float iPosition;
uniform bool iSelection;
uniform sampler2D iPreview;

float inBox(vec2 coord, vec2 bottomLeft, vec2 topRight) {
    vec2 a = step(bottomLeft, coord) - step(topRight, coord);
    return a.x * a.y;
}

float smoothBox(vec2 coord, vec2 bottomLeft, vec2 topRight, float width) {
    vec2 a = smoothstep(bottomLeft, bottomLeft + vec2(width), coord) - smoothstep(topRight - vec2(width), topRight, coord);
    return min(a.x, a.y);
}

vec3 dataColor(ivec3 data) {
    return vec3(data) / vec3(255.);
}

vec4 composite(vec4 under, vec4 over) {
    vec3 a_under = under.rgb * under.a;
    vec3 a_over = over.rgb * over.a;
    return vec4(a_over + a_under * (1. - over.a), over.a + under.a * (1 - over.a));
}

float rounded_rect_df(vec2 center, vec2 size, float radius) {
    return length(max(abs(gl_FragCoord.xy - center) - size, 0.0)) - radius;
}

void main(void) {
    vec2 uv = gl_FragCoord.xy / iResolution;
    float g = uv.y * 0.5 + 0.1;
    float w = 4.;

    vec2 slider_origin = vec2(iResolution.x / 2. - 50., 100.);
    vec2 slider_gain = vec2(100., 0.);
    vec2 slider_pos = slider_origin + slider_gain * iPosition;
    vec2 slider_size = vec2(10.);
    vec2 preview_origin = vec2(iResolution.x / 2. - 50., iResolution.y - 120.);
    vec2 preview_size = vec2(100., 100.);

    if(iSelection) {
        gl_FragColor.a = 1.;
        gl_FragColor.rgb = dataColor(ivec3(3, 0, 0));
        gl_FragColor.rgb = mix(gl_FragColor.rgb, dataColor(ivec3(4, 0, 0)), inBox(gl_FragCoord.xy, slider_pos - slider_size, slider_pos + slider_size));
    } else {
        gl_FragColor = vec4(0.);
        float df = max(rounded_rect_df(vec2(75., 150.), vec2(45., 120.), 25.), 0.);
        gl_FragColor = composite(gl_FragColor, vec4(0.3, 0.3, 0.3, smoothstep(0., 1., df) - smoothstep(2., 5., df)));
        gl_FragColor = composite(gl_FragColor, vec4(0., 0.3, 0., smoothBox(gl_FragCoord.xy, slider_origin - vec2(w), slider_origin + slider_gain + vec2(w), w)));
        gl_FragColor = composite(gl_FragColor, vec4(0., 0.8, 0., smoothBox(gl_FragCoord.xy, slider_pos - slider_size, slider_pos + slider_size, w)));

        ivec2 grid_cell = ivec2(5. * (gl_FragCoord.xy - preview_origin) / preview_size);
        vec3 grid = vec3(0.2) + vec3(0.1) * ((grid_cell.x + grid_cell.y) % 2);
        gl_FragColor = composite(gl_FragColor, vec4(grid, inBox(gl_FragCoord.xy, preview_origin, preview_origin + preview_size)));

        vec4 p = texture2D(iPreview, (gl_FragCoord.xy - preview_origin) / preview_size);
        p.a *= inBox(gl_FragCoord.xy, preview_origin, preview_origin + preview_size);
        gl_FragColor = composite(gl_FragColor, p);

    }

    //if(inBox(gl_FragCoord.xy, vec2(w), iResolution - vec2(w)) == 0.) {
    //    gl_FragColor = vec4(0.9, 0.9, 0.9, 1.);
    //} else if(length(gl_FragCoord.xy - slider) < 10) {
    //    gl_FragColor = vec4(0., 0., 0.5, 1.);
    //}
}