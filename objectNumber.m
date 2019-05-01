clear all, close all

thr = 200;
minArea = 20;

img = imread('Moedas1.jpg');

figure, imshow(img);

se = strel('disk', 3);
bw1 = img < 200;
figure,imshow(bw1);

%bw2 = imclose(bw1, se);
%imshow(bw2);

%[lb num] = bwlabel(bw2);
%regionProps = regionprops(lb, 'area', 'FilledImage', 'Centroid');
%inds = find([regionProps.Area]>minArea);