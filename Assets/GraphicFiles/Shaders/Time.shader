Shader "Time"
{
	Properties
	{
		_TextureChannel0 ("Texture", 2D) = "gray" {}
		_TextureChannel1 ("Texture", 2D) = "gray" {}
		_TextureChannel2 ("Texture", 2D) = "gray" {}
		_TextureChannel3 ("Texture", 2D) = "gray" {}


	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "DisableBatching" ="true" }
		LOD 100

		Pass
		{
		    ZWrite Off
		    Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
		    
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
                  #pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct vertexPoints
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                  UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct pixel
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

            UNITY_INSTANCING_BUFFER_START(CommonProps)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _FillColor)
            UNITY_DEFINE_INSTANCED_PROP(float, _AASmoothing)
            UNITY_DEFINE_INSTANCED_PROP(float, _rangeZero_Ten)
            UNITY_DEFINE_INSTANCED_PROP(float, _rangeSOne_One)
            UNITY_DEFINE_INSTANCED_PROP(float, _rangeZoro_OneH)
            UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_x)
            UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_y)
            UNITY_INSTANCING_BUFFER_END(CommonProps)		

			pixel vert (vertexPoints v)
			{
				pixel o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
            
            sampler2D _TextureChannel0;
            sampler2D _TextureChannel1;
            sampler2D _TextureChannel2;
            sampler2D _TextureChannel3;
  			
            #define PI 3.1415926535897931
            #define TIME _Time.y
  
            float2 mouseCoordinateFunc(float x, float y)
            {
            	return normalize(float2(x,y));
            }

            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////




float sdHorseshoe( in float2 p, in float2 c, in float r, in float le, float th )
{
    p.x = abs(p.x);
    float l = length(p);
    float2x2 matrix0 = {-c.x, c.y, c.y, c.x};
    p = mul(matrix0, p);

    p = float2((p.y>0.0 || p.x>0.0)?p.x:l*sign(-c.x),
             (p.x>0.0)?p.y:l );
    p = float2(p.x-le,abs(p.y-r)-th);
    return length(max(p,0.0)) + min(0.0,max(p.x,p.y));
}

float sdStar(in float2 p, in float r, in float rf)
{
    const float2 k1 = float2(0.809016994375, -0.587785252292);
    const float2 k2 = float2(-k1.x,k1.y);

    // repeat domain 5x
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    
    // draw triangle
    p.y -= r;
    float2 ba = rf*float2(-k1.y,k1.x) - float2(0.0 ,1.0);
	float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}



float sdLine( in float2 p, in float2 a, in float2 b )
{
	float2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

float3 lineUnity( in float3 buf, in float2 a, in float2 b, in float2 p, in float2 w, in float4 col )
{
   float f = sdLine( p, a, b );
   float g = fwidth(f)*w.y;
   return lerp( buf, col.xyz, col.w*(1.0-smoothstep(w.x-g, w.x+g, f)) );
}

float3 hash3( float n ) { return frac(sin(float3(n,n+1.0,n+2.0))*43758.5453123); }



            fixed4 frag (pixel i) : SV_Target
			{
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////

			    UNITY_SETUP_INSTANCE_ID(i);
			    
		    	float aaSmoothing = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _AASmoothing);
			    fixed4 fillColor = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _FillColor);
			   	float _rangeZero_Ten = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZero_Ten);
				float _rangeSOne_One = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeSOne_One);
			    float _rangeZoro_OneH = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZoro_OneH);
                float _mousePosition_x = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_x);
                float _mousePosition_y = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_y);

                float2 mouseCoordinate = mouseCoordinateFunc(_mousePosition_x, _mousePosition_y);
                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);

                
                float2 coordinate = i.uv;
                
                float2 coordinateBase = i.uv/(float2(2.0, 2.0));
                
                float2 coordinateScale = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////
				float4 color = 1.0;
				float4 colorRed = float4(1.0, 0.0, 0.0, 1.0);



// get time

    float mils = -TIME;
	float secs = _Time.y * -2.0;
	float mins = 30.0;
	float hors = 12.0; 
    
    // enable this for subsecond resolution
    //secs += mils;

	float2 uv = coordinate;

	float r = length( uv );
	float a = atan2( uv.y, uv.x )+3.1415926;
    
	// background color
	float3 nightColor = float3( 0.2, 0.2, 0.2 ) + 0.1*uv.y;
	float3 dayColor   = float3( 0.5, 0.6, 0.7 ) + 0.2*uv.y;
	float3 col = lerp( nightColor, dayColor, smoothstep( 5.0, 7.0, hors ) - 
				                          smoothstep(19.0,21.0, hors ) );

    // inner watch body	
	col = lerp( col, float3(0.9-0.4*pow(r,4.0), 0.9-0.4*pow(r,4.0), 0.9-0.4*pow(r,4.0)), 1.0-smoothstep(0.94,0.95,r) );

    // 5 minute marks	
	float f = abs(2.0*frac(0.5+a*60.0/6.2831)-1.0);
	float g = 1.0-smoothstep( 0.0, 0.1, abs(2.0*frac(0.5+a*12.0/6.2831)-1.0) );
	float w = fwidth(f);
	f = 1.0 - smoothstep( 0.1*g+0.05-w, 0.1*g+0.05+w, f );
	f *= smoothstep( 0.85, 0.86, r+0.05*g ) - smoothstep( 0.94, 0.95, r );
	col = lerp( col, float3(0.0, 0.0, 0.0), f );

	// seconds hand
	float2 dir;
	dir = float2( sin(6.2831*secs/60.0), cos(6.2831*secs/60.0) );
    col = lineUnity( col, float2(0.0, 0.0), dir*0.9, uv+0.05, float2(0.005,4.0), float4(0.0,0.0,0.0,0.2) );
    col = lineUnity( col, float2(0.0, 0.0), dir*0.0, uv+0.05, float2(0.055,4.0), float4(0.0,0.0,0.0,0.2) ); 
    col = lineUnity( col, float2(0.0, 0.0), dir*0.9, uv,      float2(0.005,1.0), float4(0.5,0.0,0.0,1.0) );

	// minutes hand
	dir = float2( sin(6.2831*mins/60.0), cos(6.2831*mins/60.0) );
    col = lineUnity( col, float2(0.0, 0.0), dir*0.7, uv+0.05, float2(0.015,4.0), float4(0.0,0.0,0.0,0.2) );
    col = lineUnity( col, float2(0.0, 0.0), dir*0.7, uv,      float2(0.015,1.0), float4(0.0,0.0,0.0,1.0) );

    // hours hand
	dir = float2( sin(6.2831*hors/12.0), cos(6.2831*hors/12.0) );
    col = lineUnity( col, float2(0.0, 0.0), dir*0.4, uv+0.05, float2(0.015,4.0), float4(0.0,0.0,0.0,0.2) );
    col = lineUnity( col, float2(0.0, 0.0), dir*0.4, uv,      float2(0.015,1.0), float4(0.0,0.0,0.0,1.0) );

    // center mini circle	
	col = lerp( col, float3(0.5, 0.5, 0.5), 1.0-smoothstep(0.050,0.055,r) );
	col = lerp( col, float3(0.0, 0.5, 0.5), 1.0-smoothstep(0.005,0.01,abs(r-0.055)) );

    // border of watch
	col = lerp( col, float3(0.0, 0.0, 0.0), 1.0-smoothstep(0.01,0.02,abs(r-0.95)) );

    // dithering    
    col += (1.0/255.0)*hash3(uv.x+13.0*uv.y);


 // sdf
    float d = sdStar( uv + sin(TIME) * 0.5, 0.7, 0.6 + 0.4*sin(TIME) );
    
    // colorize
    float4 colFull = float4(0.0,0.0,0.0, 1.0) - sign(d)*float4(col, 1.0);
    // float4 colFull = float4(col, 1.0) + sign(d)*float4(col, 1.0);
	


	  // // animation
   //  float t =            3.14* (0.5+0.5*cos(TIME*0.5));
   //  float2  w2 = float2(0.750,0.25)*(0.5+0.5*cos(TIME*float2(0.7,1.1)+float2(0.0,3.0)));
    
   //  // distance
   //  float d = sdHorseshoe(uv-float2(0.0,-0.1),float2(cos(t),sin(t)), 0.5, w2.x, w2.y);
        
   //  // coloring
   //  float4 colFull = float4(col, 1.0) - sign(d)*float4(1.0,0.0,0.0, 1.0);

   //  if(colFull.w < 0.1)
   //  {
   //  	return float4(col,1.0);
   //  }


					


				// return float4(col, 1.0);	
    			return float4(colFull);
				// return float4(vPixel/GetWindowResolution(), 0.0, 1.0);


				//(colBase.x + colBase.y + colBase.z)/3.0
                // return float4(coordinateScale, 0.0, 1.0);
				// return float4(right.x, up2.y, 0.0, 1.0);
				// return float4(coordinate3.x, coordinate3.y, 0.0, 1.0);
				// return float4(ro.xy, 0.0, 1.0);

				// float radio = 0.5;
				// float lenghtRadio = length(offset);

    //             if (lenghtRadio < radio)
    //             {
    //             	return float4(1, 0.0, 0.0, 1.0);
    //             }
    //             else
    //             {
    //             	return 0.0;
    //             }


				
			}

			ENDHLSL
		}
	}
}

























