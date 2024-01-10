Shader "TriangleTrapezoid"
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

float3 sdgTrapezoid( in float2 p, in float ra, float rb, float he, out float2 ocl )
{
    float sx = (p.x<0.0)?-1.0:1.0;
    float sy = (p.y<0.0)?-1.0:1.0;

    p.x = abs(p.x);

    float4 res;
    
    // bottom and top edges
    {
        float h = min(p.x,(p.y<0.0)?ra:rb);
        float2  c = float2(h,sy*he);
        float2  q = p - c;
        float d = dot(q,q);
        float s = abs(p.y) - he;
        res = float4(d,q,s);
        ocl = c;
    }
    
    // side edge
    {
        float2  k = float2(rb-ra,2.0*he);
        float2  w = p - float2(ra, -he);
        float h = clamp(dot(w,k)/dot(k,k),0.0,1.0);
        float2  c = float2(ra,-he) + h*k;
        float2  q = p - c;
        float d = dot(q,q);
        float s = w.x*k.y - w.y*k.x;
        if( d<res.x ) { ocl = c; res.xyz = float3(d,q); }
        if( s>res.w ) { res.w = s; }
    }
   
    // distance and sign
    float d = sqrt(res.x)*sign(res.w);
    res.y *= sx;
    ocl.x *= sx;
    
    return float3(d,res.yz/d);
}


#define AA 2
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


                float px = 1.0;
                float2 p = coordinate;


                // animation
                float ra = 0.2+0.15*sin(TIME*1.3+0.0);
                float rb = 0.2+0.15*sin(TIME*1.4+1.1);
                float he = 0.5+0.2*sin(1.3*TIME);
        
        
                // sdf(p) and gradient(sdf(p))
                float2 kk;
                float3  dg = sdgTrapezoid( p, ra, rb, he, kk );
                float d = dg.x;
                float2 g = dg.yz;
        
                // central differenes based gradient, for comparison
                //g = vec2(dFdx(d),dFdy(d))/(2.0/iResolution.y);
        
                // coloring
                float3 col = (d>0.0) ? float3(0.9,0.6,0.3) : float3(0.4,0.7,0.85);
                col *= 1.0 + float3(0.5*g,0.0);
              //col = vec3(0.5+0.5*g,1.0);
                col *= 1.0 - 0.5*exp(-16.0*abs(d));
                col *= 0.9 + 0.1*cos(150.0*d);
                col = lerp( col, float3(1.0, 1.0, 1.0), 1.0-smoothstep(0.005,0.005,abs(d)) );
 
        

				return float4(col.xyz, 1.0);


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

























