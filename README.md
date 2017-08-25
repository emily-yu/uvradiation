# UVRadiation

### Inspiration
Over half of the US is vitamin D deficient, which can result in potentially serious effects including skin cancer as well as weakened bones. We built UVDetective to minimize the possibility of negative consequences arising.

### What it does
UVDetective takes your location coordinates and takes the UV index, and uses OpenCV to analyze a picture of yourself to find your approximate skin tone. It then calculates the user's personal rate of vitamin D production as well as the optimal vitamin D intake for the user. Using the ambient light sensor, accelerometer, and signal strength, we were able to approximately determine how much UV exposure the user would receive.

### How we built it
We used Firebase and Python as a backend, and used Swift to build the front end.

### Challenges we ran into
It was difficult to determine the amount of UV exposure the user would receive based on the sensors that are available for Apple Devices.

### Accomplishments that we're proud of
Finding a way to determine the amount of UV exposure the user would receive based on the sensors that are available for Apple Devices.

### What we learned
Too much Vitamin D is bad for you.

### What's next for UVDetective
Improve the accuracy of vitamin D algorithm.

