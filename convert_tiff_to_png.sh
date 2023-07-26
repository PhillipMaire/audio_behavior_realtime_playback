for file in *.tif *.tiff; do
    magick "$file" "${file%.tiff}.png"
    echo "Converted $file to ${file%.tiff}.png"
done
