#define SIZE         0.1
#define SAMPLES      20.0

precision mediump float;                                                   
                                                                           
uniform sampler2D uImage;                                                  
uniform sampler2D uPalette;

varying vec2 vTexCoord;                                                    
                                                                           
uniform float uCenter;                                                     
uniform float uWidth;                                                      
uniform int uSigned;                                                       
uniform int uSigmoid;                                                      
uniform int uInverted;                                                     
uniform int uEnhance;                                                     
uniform float uSlope;                                                      
uniform float uIntercept;                                                  
uniform int uDepth;                                                        
uniform int uColorTable;


vec4 original(vec2 pos) {
    vec4 vInt = vec4(uIntercept, uIntercept, uIntercept, 0);                
    vec4 vSlo = vec4(uSlope, uSlope, uSlope, 1);                                    
                                                                            
    if (uDepth > 8) {                                                       
        vec2 tophalf = vec2(pos.x, pos.y / 2.0);                   
                                                                               
        vec4 high = texture2D(uImage, tophalf + vec2(0, 0.5));                 
        vec4 low = texture2D(uImage, tophalf);                                 
                                                                               
        vec4 raw = high + low / 256.0;
                                                                               
        if (uSigned > 0) {                                                     
           raw = raw - vec4(0.5, 0.5, 0.5, 0.0);                               
        }                                                                      
                                                                               
        return raw * vSlo + vInt;           
    } else {                                                                 
        vec4 color = texture2D(uImage, pos);                             
                                                                               
        vec4 raw = color / 256.0;                                     
                                                                               
        return raw * vSlo + vInt;
    }
}


vec4 windowed(vec2 pos) {
    vec4 vCen = vec4(uCenter, uCenter, uCenter, 1);                         
    vec4 vWid = vec4(uWidth, uWidth, uWidth, 1);                            
    vec4 vOne = vec4(1, 1, 1, 1);                                           
       
    vec4 raw = original(pos);
    vec4 windowed;

    if (uDepth > 8) {
        float center = uCenter;
                                                                               
        if (uSigned > 0) {                                                     
            center = center + (128.0 / 65536.0) * uSlope;
        }                                                                      
                                                                               
        float min = center - uWidth / 2.0;                                     
        vec4 vMin = vec4(min, min, min, 0);
                     
        vec4 rescaled = raw - vMin;                              
                                                                               
        if (uSigmoid > 0) {                                                    
            windowed = vOne / (vOne + exp(vec4(-4.0, -4.0, -4.0, 1) *           
                (rescaled - vCen) / vWid));                                     
        } else {                                                               
             windowed = rescaled / vWid;                                         
        }                                                                      
                                                                               
        if (uInverted > 0) {                                                   
  	        windowed = vOne - windowed;                                         
        }

    } else {
        float min = uCenter - uWidth / 2.0;      
        vec4 vMin = vec4(min, min, min, 0);    
                                                                               
        windowed = (raw - vMin) / vWid;
                                                                               
        if (uInverted > 0) {                                                   
	        windowed = vOne - windowed;                                         
        }
    }

    if (uColorTable > 0) {
        return texture2D(uPalette, vec2(((windowed.r * 255.0) + 0.5) / 256.0, 0.5));
    } else {
        return windowed;
    }
}


vec4 equalize(vec2 pos) {
    
    vec4 intensity = original(pos);
    
    float count = 0.0;
    float total = 0.0;
    
    for (float i = -SIZE; i <= SIZE; i += SIZE * 2.0 / SAMPLES)
    {
        for (float j = -SIZE; j <= SIZE; j += SIZE * 2.0 / SAMPLES)
        {
            vec4 sample = original(pos + vec2(i, j));
            
            if (i + pos.x > 0.0 && i + pos.x < 1.0 &&
                j + pos.y > 0.0 && j + pos.y < 1.0) {
                if (intensity.x > sample.x) {
                    count++;
                }
                
                total++;
            }
        }
    }
    
    float gray = count / total;
    
    return vec4(gray, gray, gray, 1.0);
}


void main() {                                                              

    if (uEnhance > 0) {
        gl_FragColor = equalize(vTexCoord);
    } else {
        gl_FragColor = windowed(vTexCoord);
    }
}