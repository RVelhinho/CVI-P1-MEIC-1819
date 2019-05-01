clear all, close all

img = imread('Moedas1.jpg');
imshow(img);

g = rgb2gray(img);
imshow(g);

%imhist(g);

bw = g > 80;
%imshow(bw);

se = strel('disk',4);
afterOpening = imopen(bw, se);
%imshow(afterOpening);

afterClosing = imclose(afterOpening, se);
%imshow(afterClosing);

[L, num] = bwlabel(~afterClosing,4);