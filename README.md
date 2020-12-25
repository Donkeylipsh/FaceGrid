# FaceGrid
A Unity Shader that displays a Sci-fi grid with an animated ominous human face protruding from the surface

# Components
* Unity Prefab
* Unity C# Script
* Unity Material
* Unity HLSL Unlit Shader
* .OBJ 3D Model

# How to Use
After dropping the Prefab into your scene, you can control the Colors, and the count and thickness of Rows in Columns from the Shader
* To get a grid of squares, set the Columns = 2 * Rows
* The Thickness property needs to be very small, 0.00075 is a good value
* All other values in the Shader's Inspector can be ignored as they are assign by the script based on the object size
