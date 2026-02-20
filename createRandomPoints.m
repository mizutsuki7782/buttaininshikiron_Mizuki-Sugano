function p = createRandomPoints(imgSize, numPoints)

    x = randi([1, imgSize(2)], numPoints, 1);
    y = randi([1, imgSize(1)], numPoints, 1);

    p = SURFPoints([x, y], 'Scale', 1.6);

end