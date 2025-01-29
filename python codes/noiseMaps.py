from perlin_noise import PerlinNoise
import numpy as np

# Initialize the noise function
noise = PerlinNoise(octaves=10, seed=42)  # Octaves control detail; seed ensures repeatability

import matplotlib.pyplot as plt

# Generate a grid of coordinates
grid_size = 100
noise_map = np.zeros((grid_size, grid_size))

scale = 200

# Fill the noise map with noise values
for i in range(grid_size):
    for j in range(grid_size):
        x_scaled = i / scale
        y_scaled = j / scale
        noise_value = noise([x_scaled, y_scaled])
        normalized_value = (noise_value + 1) / 2
        noise_map[i][j] = normalized_value

# Plot the noise map
plt.imshow(noise_map, cmap='gray',vmin = 0, vmax = 1)
plt.colorbar()
plt.title('Perlin Noise Map')
plt.show()