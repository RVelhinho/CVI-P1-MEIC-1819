clear all, close all

img=imread ('Moedas1.jpg');
centroids = 0;
num = 0;
N = 0;

% Construct a questdlg with three options
choice = questdlg('Choose your image', ...
    'Image', ...
    'Moedas 1','Moedas 2','Moedas 3','Moedas 3');
% Handle response
switch choice
    case 'Moedas 1'
        img = imread ('Moedas1.jpg');
        N = 20;
    case 'Moedas 2'
        img = imread ('Moedas2.jpg');
        N=20;
    case 'Moedas 3'
        img = imread ('Moedas3.jpg');
        N=4;
    
end

% -------- ENTREGA 1 -------- %
% 1 - Leitura de imagem
% imread
%figure,imshow(img)

% 2 - Conversao para niveis de cinzento
% rgb2gray
imgg = rgb2gray(img);
%figure,imshow(imgg)

% 3 - Binariza??o (calculo automatico do limiar)
% im2bw, graythresh

% level = graythresh(I) level is a normalized intensity value that lies in the range [0, 1].
% The graythresh function uses Otsu's method, which chooses the threshold to minimize the intraclass variance of the black and white pixels.
level = graythresh(imgg);

% BW = im2bw(I, level) The output image BW replaces all pixels in the input image with luminance greater than level 
% With the value 1 (white) and replaces all other pixels with the value 0 (black). 
% To compute the level argument, you can use the function graythresh. 
%figure,imshow(imglevel)
imgbw = im2bw(imgg, level);
%figure,imshow(imgbw)

% 4 - Melhoramento de imagem
% strel, bwmorph, imdilate, imrode, imclose, imopen

% SE = strel('disk',R,N) creates a disk-shaped structuring element, where R specifies the radius. 
% N specifies the number of line structuring elements used to approximate the disk shape. 
% N must be 0, 4, 6, or 8.
se = strel('disk',N);

% BW2 = bwmorph(BW,operation) applies a specific morphological operation to the binary image BW.
%bw2 = bwmorph(imgbw,'clean');
%figure,imshow(bw2)

% IM2 = imdilate(IM,SE) The argument SE is a structuring element object, or array of structuring element objects, 
% returned by the strel or offsetstrel function.
% If IM is logical, the structuring element must be flat and imdilate performs binary dilation. 
% Otherwise, imdilate performs grayscale dilation. 
%IM2 = imdilate(imgbw,se);
%figure,imshow(IM2)

% IM2 = imerode(IM,SE) he argument SE is a structuring element object or array of structuring element objects
% returned by the strel or offsetstrel functions.
%bw = imerode(imgbw,se);
%figure,imshow(bw)

% IM2 = imclose(IM,SE)The morphological close operation is a dilation followed by an erosion, 
% using the same structuring element for both operations.
IM2 = imclose(imgbw,se);
%figure,imshow(IM2)

morph = bwmorph(IM2,'clean');


% IM2 = imopen(IM,SE) The morphological open operation is an erosion followed by a dilation, 
% using the same structuring element for both operations.
%IM2 = imopen(imgbw,se);
%figure,imshow(IM2)

% 5 - Extraccao de componentes conexos
% bwlabel
%[L,num] = bwlabel(___) also returns num, the number of connected objects found in BW.
[L,num] = bwlabel (morph);

% 6 - Extraccao de propriedades
% regionprops
% stats = regionprops(BW,properties) returns measurements for the set of properties 
% specified by properties for each connected component (object) in the binary image, BW. 
% stats is struct array containing a struct for each object in the image. 

stats = regionprops('table',morph,'Centroid','MajorAxisLength','MinorAxisLength', 'area', 'perimeter');

centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
radii = diameters/2;

centroids = cat(1, stats.Centroid);

x=[centroids(:,1)]
y=[centroids(:,2)]

opt = 0;
aux = 0;

while opt == 0
    % Construct a questdlg with three options
    choice = questdlg('Choose your option', ...
        'Image', ...
        'Visualization','More Options','Exit','Exit');
    % Handle response
    switch choice
        case 'Visualization'
            aux = 0;
        case 'More Options'
            aux = 2;
        case 'Exit'
            opt = 1;
            delete(gcf)
            close all
    end

    
    if aux == 2 && opt == 0
        
             % Construct a questdlg with three options
        choice = questdlg('Choose your option', ...
            'Image', ...
            'Histogram','Ordered Area/Perimeter','Back','Back');
        % Handle response
        switch choice
            case 'Histogram'
                aux = 3;
            case 'Ordered Area/Perimeter'
                aux = 1;
            case 'Back'
                delete(gcf)
        end
    end
    
    if aux == 3 && opt == 0
        
       [pixelCount, grayLevels] = imhist(imgg);
        subplot(1, 1, 1);
        bar(pixelCount);
        title('Histogram of original image', 'FontSize', 12);
        xlim([0 grayLevels(end)]); % Scale x axis manually.
        grid on;    
       
     %  subplot (1,2,1), plot(imgca,stat.Area, centroids(:,2))
        
        % Construct a questdlg with three options
            choice = questdlg('Close', ...
                'Image', ...
                'Close','Close');
            % Handle response
            switch choice
                case 'Close'
                    delete(gcf)
            end
     
    end
        
    
    if aux == 0 && opt == 0
        
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        subplot(2,2,1),imshow(img)
        hold on
        viscircles(centers,radii);
        plot(imgca,centroids(:,1), centroids(:,2), 'r.')
        hold off

        subplot(2,2,2),imshow(morph)
        hold on
        viscircles(centers,radii);
        hold off

        subplot(2,2,3),imshow(morph)
        hold on
        viscircles(centers,radii);
        hold off

        % Liga??o entre centroides
        subplot(2,2,4),imshow(img)
        hold on
        viscircles(centers,radii);
        plot(imgca,centroids(:,1), centroids(:,2), 'r.')
        %plot(xpoints',ypoints', 'color', [0 0 0], 'linewidth', 2);
        hold off

        % 7 - Classificacao de objectos

        % 8 - Visualizacao de imagem
        % imshow, imagesc

        % 9 - Gravacao de imagem
        % imwrite
        % imwrite(A,filename) writes image data A to the file specified by filename
        imwrite(morph, 'final.jpg')

        % 10 - Calculo do histograma
        % imhist, hist
        %subplot(2,2,4),imhist(imgg);

        % 11 - Colocar o texto na imagem/figura
        % text
        %text(x,y,str)
        %text(centroids(:,1),centroids(:,2), centroids,'Color','red','FontSize',10)
        subplot(2,2,1)
        title('Centroid [x,y]', 'FontSize', 14);
        txt1 = strcat('\leftarrow','[',int2str(centroids(:,1)), '; ', int2str(centroids(:,2)), ']');
        text(centroids(:,1),centroids(:,2), txt1,'Color','black','FontSize',8)
        text(50,700,strcat('Number of Coins ',' :',{' '} ,int2str(num)),'Color','white','FontSize',12)

        subplot(2,2,2)
        title('Area', 'FontSize', 14);
        txt2 = strcat('\downarrow', int2str(stats.Area));
        text(centroids(:,1),centroids(:,2)-(1.5*radii), txt2,'Color','white','FontSize',8)

        subplot(2,2,3)
        title('Perimeter', 'FontSize', 14);
        txt3 = strcat('\downarrow', num2str(stats.Perimeter));
        text(centroids(:,1),centroids(:,2)-(1.5*radii), txt3,'Color','white','FontSize',8)

        subplot(2,2,4)
        title('Connections', 'FontSize', 14);
        auxSelect = 0;
    
        while auxSelect == 0

            % Construct a questdlg with three options
            choice = questdlg('Select Coin?', ...
                'Image', ...
                'Select','Close','Close');
            % Handle response
            switch choice
                case 'Select'
                    auxSelect = 0;
                case 'Close'
                    auxSelect = 1;
                    delete(gcf)
                    close all
            end

            if auxSelect == 0

                subplot(2,2,4)
                p = ginput(1);
                xp = [p(:,1)];
                yp = [p(:,2)];
                for i = 1:num
                    output = (xp - centers(i,1))^2 + (yp - centers(i,2))^2 <= radii(i)^2;
                    if output == 1
                        moedax = centers(i,1);
                        moeday = centers(i,2);
                        break
                    else
                        res = 'O ponto que indicou n?o pertence a nenhuma moeda';
                        moedax = 0;    
                    end
                end

                if moedax ~= 0
                    point=[moedax,moeday];
                    xpoints = [];
                    for idx = 1:numel(x)
                        element = x(idx)
                        result = [point(1,1) element];
                        %disp(result);
                        xpoints = cat(1, xpoints, result);
                    end
                    disp(xpoints);

                    ypoints = [];
                    for idy = 1:numel(y)
                        element = y(idy)
                        result = [point(1,2) element];
                        %disp(result);
                        ypoints = cat(1, ypoints, result);
                    end
                    % disp(ypoints);

                    subplot(2,2,4),imshow(img)
                    hold on
                    text(50,50,'Connections','Color','white','FontSize',14)
                    viscircles(centers,radii);
                    plot(imgca,centroids(:,1), centroids(:,2), 'r.')
                    plot(xpoints',ypoints', 'color', [1 0 0], 'linewidth', 2);

                    coordx=[xpoints(:,2)]
                    coordy=[ypoints(:,2)]

                    newlength = [];
                    for i = 1:numel(coordx)
                            X = [point;coordx(i),coordy(i)];
                            d = pdist(X,'euclidean');
                            %disp('dist?ncia');
                            %disp(d);
                            newlength= cat(1,newlength, d);    
                    end
                    
                    C = cell(1, numel(newlength));
                    for i = 1:numel(newlength)
                      C{i} = newlength(i);
                    end

                    for i = 1:numel(newlength)
                    	text(coordx(i)+20,coordy(i),C(i),'Color','black','FontSize',8);
                    end
                    hold off

                    % 12 - Visualizacao de graficos
                    % plot, bar

                    % -------- 5) Distancia relativa entre os objectos -------- %
                else
                    res
                end
            end   
        end


    end

    if aux == 1 && opt == 0

        % Construct a questdlg with three options
            choice = questdlg('Area', ...
                'Image', ...
                'Ascend','Descend','Descend');
            % Handle response
            switch choice
                case 'Ascend'
                    stats = sortrows(stats,'Area','ascend');
                case 'Descend'
                    stats = sortrows(stats,'Area','descend');
            end

            centroids = cat(1, stats.Centroid);

            maxrad = max(diameters)/2;

            figure; subplot(2,num,1)
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        for i = 1:num

            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroids(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroids(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids(i,2)+maxrad+10);   %ymax

            % Index into the original image to create the new image
            MM = img(sp(2):sp(4), sp(1): sp(3),:);

            subplot(2,num,i), subimage(MM)
            axis off
            title(strcat('Area', ':' ,int2str(ceil(stats.Area(i)))), 'FontSize', 12);

        end
           

        for i = 1:num

            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroids(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroids(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids(i,2)+maxrad+10);   %ymax

            % Index into the original image to create the new image
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            
            title(strcat('Perimeter', ':' ,int2str(ceil(stats.Perimeter(i)))), 'FontSize', 12);
        end
        
        % Construct a questdlg with three options
            choice = questdlg('Close', ...
                'Image', ...
                'Close','Close');
            % Handle response
            switch choice
                case 'Close'
                    delete(gcf)
            end

    end
end