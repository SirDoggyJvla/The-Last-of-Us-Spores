from PIL import Image

size = r"big"
color = r"yellow"

particle_image_path = r"C:\Users\simon\Zomboid\Workshop\The Last of Us Spores\images\particles_" + color + "_" + size + ".png"
export_particle_grid = r"C:\Users\simon\Zomboid\Workshop\The Last of Us Spores\Contents\mods\The Last of Us Spores\common\media\ui\SporeOverlay\{0}".format(color)

export_file_name = "SporeOverlay_particles_" + color + "_" + size + "_{0}.png"
export_file_name_fliped = "SporeOverlay_particles_" + color + "_" + size + "_fliped_{0}.png"

# Load the particle image
particle_image = Image.open(particle_image_path)

# Get the dimensions of the image
width, height = particle_image.size

# Calculate the size of each grid cell
cell_width = width // 3
cell_height = height // 3

# Loop through each cell in the 3x3 grid
i = 0
for row in range(3):
    for col in range(3):
        i += 1
        # Create a new blank image with the same size as the original
        new_image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        
        # Paste the current cell into the new image
        cell = particle_image.crop((col * cell_width, row * cell_height, (col + 1) * cell_width, (row + 1) * cell_height))
        new_image.paste(cell, (col * cell_width, row * cell_height))
        
        # Save the new image
        new_image.save(export_particle_grid + "\\" + export_file_name.format(i))
        
        if size != "big":
            # Create a flipped version of the new image
            flipped_image = new_image.transpose(Image.ROTATE_180)
            
            # Save the flipped image
            flipped_image.save(export_particle_grid + "\\" + export_file_name_fliped.format(i))