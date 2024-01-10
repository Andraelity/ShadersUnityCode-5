Shader "Balls"
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
			float ballsCloseness(float2 p)
			{
			  	float sumCloseness = 0.0;
			  
			  	float increment = 1.0 / 40.0;
				for (float i = 0.0; i < 39.0; i += 1.0)
			    {
				  	float2 aspectRatio = 1.0;
			  		float2 ballPos = float2(increment + i * increment, 0.5 + 0.5 * cos((i + 1.0) * TIME * 0.05));
			  		float distance2 = distance(p * aspectRatio, ballPos * aspectRatio);
			  		float nonZeroDistance = max(0.0001, distance2);
			  		float closeness = (1.0 / nonZeroDistance);
			     	sumCloseness += closeness / 400.0;
			    }
			  
			  	return sumCloseness;
			}
			
			float spike(float center, float width, float val)
			{
				float left = smoothstep(center, center - width / 2.0, val);
			  	float right = smoothstep(center - width / 2.0, center, val);
			  	return left * right;
			}


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
				float2 p = coordinateScale;
  
				float closeness = ballsCloseness(p);
				float spike1 = spike(0.39, 0.02, closeness);
				float spike2 = spike(0.4, 0.02, closeness);  
				float spike3 = spike(0.41, 0.02, closeness);
				float spike4 = spike(0.42, 0.02, closeness);
				float spike5 = spike(0.43, 0.02, closeness);
				float spike6 = spike(0.44, 0.02, closeness);
				float spike7 = spike(0.45, 0.02, closeness);
				
				float spikes = 2.0 * (spike1 * 0.8 + spike2 * 0.2 + spike3 * 0.9 + spike4 * 0.35 + spike5 * 0.9 + spike6 * 0.39 + spike7 * 0.5);
				  
				//  fragColor.r = 2.0 * (spike1 * 0.4 + spike2 * 0.5 + spike6 * 0.3 + spike7 * 0.8);
				//  fragColor.g = 2.0 * (spike2 * 0.5 + spike3 * 0.65 + spike4 * 0.3 + spike5 * 0.1 + spike6 * 0.8);
				//  fragColor.b = 2.0 * (spike1 * 0.8 + spike2 * 0.2 + spike3 * 0.9 + spike4 * 0.35 + spike5 * 0.9 + spike6 * 0.39 + spike7 * 0.5);
				
				float background = smoothstep(0.3, 0.5, closeness);
				 
				float iTime = TIME;

				float4 fragColor = 0.0;
				fragColor.r = sin(iTime) * background + spikes;
				fragColor.g = cos(iTime / 25.0) * background + spikes;
				fragColor.b = cos(iTime / 100.0) * background + spikes;
				fragColor.a = 1.0;
					


				return float4(fragColor);	
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

























