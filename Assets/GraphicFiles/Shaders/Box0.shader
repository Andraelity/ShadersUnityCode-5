Shader "Box0"
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
				float4 colorGreen = float4(0.0, 1.0, 0.0, 1.0);
				float4 colorBlue = float4(0.0, 0.0, 1.0, 1.0);
				float4 colorCian = float4(0.0, 1.0, 1.0, 1.0);

				// float2 coordinateBox = float2(abs(cos(TIME)* 0.5), abs(sin(TIME)*0.5));

				// float2 absoluteCoordinate = abs(coordinate);
				// float value0 = min(coordinateBox.x, absoluteCoordinate.x);
				// float value1 = min(coordinateBox.y, absoluteCoordinate.y);

				// color = (value0 != coordinateBox.x && value1 != coordinateBox.y) ? colorRed : 1.0;  

				//RayTracer

				// float2 coordinateBaseScale = coordinateScale;
				float2 coordinateBaseScale = coordinate;
				coordinateBaseScale = coordinateBaseScale * 3.0;



				float3 coordinateCircleCenter = float3(1.0, 1.0, 0.0 );
				float radio = 0.5;
				float3 value = float3(coordinateBaseScale.xy,0.0);
				float lenghtRadio = length(coordinateCircleCenter - value);
                color = (lenghtRadio < radio)? float4(1, 0.0, 0.0, 1.0) : 1.0;
                

                // float3 coordinateBoxCenter = float3(1.5, 1.5, 8.0);
                float3 coordinateBoxCenter = float3(0.5, 0.5, 0.5);

                // coordinateBoxCenter += float3(cos(TIME)*0.5,sin(TIME)*0.5, 0.0 );
                
                float varMatrix = PI/4;

                float3x3 matRot = {cos(varMatrix), 0 , sin(varMatrix), 0, 1, 0, -sin(varMatrix), 0, cos(varMatrix)};

                float3 dimPerfectCube = coordinateBoxCenter + float3(0.5, 0.5, 0.5);
                float3 cubeCorner = float3(0.5, 0.5, 0.5);
                // float3 cubeCorner = float3(0.71, 0.0, 0.5);
                // cubeCorner = mul(matRot, cubeCorner);
                float3 cubeCenter = float3(0.0, 0.5, 0.0);
                // cubeCenter = mul(matRot, cubeCenter);
         		float lengthCubeCorner = length(cubeCorner);
         		float lengthCubeLower = length(cubeCenter);
         		float lengthCubeRatio = lengthCubeCorner - lengthCubeLower;
                float3 edgeInsideCube = cubeCorner * 0.95;


                float3 screenSpace = float3(coordinateBaseScale,0.0);
                float3 rayCast = screenSpace;

               	float ratioChange = 0.001;
               	float MAX = 15.0; 
               	for(float i = 0; i < MAX; i += ratioChange)
               	{

               		float3 coordinateValue = coordinateBoxCenter - rayCast;
               		coordinateValue = abs(coordinateValue);

               		float valueX = min(cubeCorner.x, coordinateValue.x);
               		float valueY = min(cubeCorner.y, coordinateValue.y);
               		float valueZ = min(cubeCorner.z, coordinateValue.z);

               		if(valueX != cubeCorner.x && valueY != cubeCorner.y && valueZ != cubeCorner.z)
               		{

	               		float valueEdgeX = max(edgeInsideCube.x, coordinateValue.x);
	               		float valueEdgeY = max(edgeInsideCube.y, coordinateValue.y);
	               		float valueEdgeZ = max(edgeInsideCube.z, coordinateValue.z);
               			if(valueEdgeX != cubeCorner.x && valueEdgeY != cubeCorner.y && valueEdgeZ != cubeCorner.z)
               			{

               				float ratioShadow = (length(coordinateValue) - lengthCubeLower)/lengthCubeRatio;  
               				color = colorGreen * ratioShadow;
               			}

               		}

               		rayCast.z += ratioChange;

               	}
				

               	float2 centerSquare = float2(_rangeZoro_OneH, _rangeZoro_OneH);
               	float2 pointRightUp = float2(_rangeSOne_One, _rangeZero_Ten);
               	// float2  = float2(1.0, 1.0);
               	float2 PointCornerUp = centerSquare + pointRightUp;
               	float2 PointCornerDown = centerSquare - pointRightUp;


               	float hypothenuseLength = length(pointRightUp);
               	float2 sideUp = float2(centerSquare.x, PointCornerUp.y); 
               	float2 sideRight = float2(PointCornerUp.x, centerSquare.y);
               	float2 sideDown = float2(centerSquare.x, PointCornerDown.y); 
               	float2 sideLeft = float2(PointCornerDown.x, centerSquare.y); 
               	float sideSquare = float(PointCornerUp.x); 
               	float sideUpSquare = float(PointCornerUp.y); 


               	float2 currentEvaluationPoint = float2(coordinateBaseScale);

               	float lengthCurrentPoint = length(currentEvaluationPoint - centerSquare);

               	float lengthToHypothenuse = length(currentEvaluationPoint - PointCornerUp);

               	float lengthToSideUp = length(currentEvaluationPoint - sideUp);
               	float lengthToSide = length(currentEvaluationPoint - sideRight);


               	float2 circleCorner0 = centerSquare + (pointRightUp * 0.8);
               	float2 circleCorner2 = centerSquare + (pointRightUp * -0.8);


               	float lengthVector = length(pointRightUp * 0.95);
               	float lenghtPointCorner0 = length(currentEvaluationPoint - circleCorner0);
               	float lenghtPointCorner2 = length(currentEvaluationPoint - circleCorner2);

               	float circleRadius = float2(0.2 * pointRightUp).x / float2(0.2 * pointRightUp).y; 

               	


               	if(currentEvaluationPoint.x < sideRight.x && currentEvaluationPoint.y < sideUp.y && currentEvaluationPoint.x > sideLeft.x && currentEvaluationPoint.y > sideDown.y )
               	{
               		// color = colorGreen;

               		// if(lengthCurrentPoint < hypothenuseLength * 0.9)
               		// {
               		//  color = colorGreen;
               		// } 

               		// if(lenghtPointCorner0 < circleRadius)
               		// {
               		// 	color = colorGreen;
               		// }

               		// if(lenghtPointCorner2 < circleRadius)
               		// {
               		// 	color = colorGreen;
               		// }


               		// color = colorGreen;


               		// lengthToHypothenuse * 
               		// color =colorGreen;
               		// if(lengthCurrentPoint < 1.0)
               		// {
               		// 	color = colorGreen;
               		// }

               		// if(lengthToSideUp < 0.5)
               		// {
               		// 	color = colorGreen;
               		// }

               		// if(lengthToSide < 0.5)
               		// {
               		// 	color = colorGreen;
               		// }
               	}


           		// if(lengthCurrentPoint < 1.0)
           		// {
           		// 	color = colorBlue;
           		// }


    //            	float lengthSideUp = length(currentEvaluationPoint - sideUp);
				// if( lengthSideUp < 0.1)
    //            	{

    //            		color = colorRed;
    //            	}


    //            	float lengthSide = length(currentEvaluationPoint - sideRight);
				// if( lengthSide < 0.1)
    //            	{

    //            		color = colorRed;
    //            	}

               	
               	
				// if( lengthCurrentPoint < 0.1)
    //            	{

    //            		color = colorRed;
    //            	}

    //            	if(lengthToHypothenuse < 0.1)
    //        		{

    //        			color = colorRed;
    //        			// if()
    //        			// {
           				
    //        			// }
    //        			// 1 - lengthToHypothenuse/hypothenuseLength;
    //        		}

           		// float2 valueMin = min(currentEvaluationPoint, PointCornerUp);
           		// if(valueMin.x < PointCornerUp.x && valueMin.y < PointCornerUp.y && lengthToHypothenuse > 0.5 && valueMin.x > centerSquare.x && valueMin.y > centerSquare.y)
           		// {
           		// 	color = colorCian;
           		// }

               	// float2 minUp = min(currentEvaluationPoint, PointCornerUp);
               	// if(minUp < sideUp.y)
               	// centerSquare + pointRightUp


















                return color;
                

				
			}

			ENDHLSL
		}
	}
}

























