% -------------------------------------------------------------------------
%
%   CVI - First Lab Work
%   Group 20
%   Miguel Regouga, 83530 / Joao Pina, 85080
%   May 2019
%
% -------------------------------------------------------------------------


clear all, close all

% Image input

name = inputdlg('Example: Moedas1.jpg', 'Choose image');
img = imread(name{1});


% Image processing

img_gauss = imgaussfilt(img, 3);
binary = imbinarize(img_gauss(:,:,1),0.50);
se = strel('disk', 2);
i1 = imdilate(binary,se);


% Detect and treat collisions

D = -bwdist(~i1);
WS = watershed(D);
mask = imextendedmin(D,3);
D2 = imimposemin(D, mask);
WS2 = watershed(D2);
imgFinal = i1;
imgFinal(WS2 == 0) = 0;


% Detect different objects

[lb, num] = bwlabel(imgFinal);

stats = regionprops('table', lb, 'Area', 'Centroid', 'Perimeter', ...
    'MajorAxisLength','MinorAxisLength', 'BoundingBox');


coinPerimeters = [376.444, 436.188, 452.1, 481.716, 503.326, 528.724, 552.426];
coinDiameters = [120.7976, 139.7443, 144.9026, 154.2051, 160.98, 169.2232, 176.6122];
coinValues = [0.01, 0.02, 0.10, 0.05, 0.20, 1.00, 0.50];

error = 4;

stats.Circularity = stats.Perimeter .^ 2 ./ (4 * pi* stats.Area);
perimeters = stats.Perimeter.';
circularity = stats.Circularity.';

centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);

coinDiameters2 = diameters.';
radii = diameters/2;

centroids = cat(1, stats.Centroid);


% Money counting

sumMoney = 0;
valueIndex = 0;

index = 1;

for v = 1:length(coinDiameters2)
    if (circularity(v) < 1.01)
        for l = 1:length(coinDiameters)
            if (coinDiameters2(v) < coinDiameters(l) + error) && (coinDiameters2(v) > coinDiameters(l) - error)
                index = l;
            end
        end
        sumMoney = sumMoney + coinValues(index);
    end
end

x=[centroids(:,1)]
y=[centroids(:,2)]

opt = 0;
aux = 0;


% Calculating sharpness

bound = bwboundaries(imgFinal,'holes');
coinSharp = [];

for k = 1:num
    boundary = bound{k};
    delta_sq = diff(boundary).^2;
    perimeter = sum(sqrt(sum(delta_sq,2)));
    area = stats.Area(k);
    metric = 4*pi*area/perimeter^2;
    sharpness = 1 - metric;
    metric_string = sprintf('%2.2f',sharpness);
    coinSharp = [coinSharp sharpness];
end
stats.Sharpness = coinSharp.';


% Main loop

while opt == 0
    
% -------------------------------------------------------------------------
%   Main Menu (Visualization, More Options)
% -------------------------------------------------------------------------
    
    choice = questdlg('Choose your option:', ...
        'First Lab Work', ...
        'Visualization','More Options','Exit','Exit');
    
    switch choice
        case 'Visualization'
            aux = 0;
        case 'More Options'
            aux = 4;
        case 'Exit'
            opt = 1;
            delete(gcf)
            close all
    end
    
% -------------------------------------------------------------------------
%   Main Menu (Orders, Similarity)
% -------------------------------------------------------------------------
    
    if aux == 4 && opt == 0
        choice = questdlg('Choose your option:', ...
            'First Lab Work', ...
            'Orders','Similarity','Back','Back');
        % Handle response
        switch choice
            case 'Orders'
                aux = 2;
            case 'Similarity'
                aux = 5;
            case 'Back'
                delete(gcf)
        end
    end
    
% -------------------------------------------------------------------------
%   Orders Menu (Circularity/Sharpness, Area/Perimeter)
% -------------------------------------------------------------------------
    
    if aux == 2 && opt == 0
        
        % Construct a questdlg with three options
        choice = questdlg('Choose your option:', ...
            'First Lab Work', ...
            'Ordered Area/Perimeter', 'Ordered Circularity/Sharpness','Back','Back');
        % Handle response
        switch choice
            case 'Ordered Area/Perimeter'
                aux = 1;
            case 'Ordered Circularity/Sharpness'
                aux = 3;
            case 'Back'
                delete(gcf)
        end
    end
    
    
% -------------------------------------------------------------------------
%   Visualization
% -------------------------------------------------------------------------
    
    if aux == 0 && opt == 0
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        
        % Top-left (boundaries, number of objects, money sum)
        subplot(2,2,1),imshow(img);
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        subplot(2,2,1)
        title('Centroid [x,y]', 'FontSize', 14);
        txt1 = strcat('\leftarrow','[',int2str(centroids(:,1)), '; ', int2str(centroids(:,2)), ']');
        text(centroids(:,1),centroids(:,2), txt1,'Color','black','FontSize',8)
        plot(centroids(:,1),centroids(:,2), '.r');
        text(50,700,strcat('Number of Objects ',' :',{' '} ,int2str(num)),'Color','white','FontSize',12)
        text(50,660,strcat('Euro Value ',' :',{' '} ,num2str(sumMoney)),'Color','white','FontSize',12)
        
        
        % Top-right (area)
        subplot(2,2,2),imshow(imgFinal)
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        subplot(2,2,2)
        title('Area', 'FontSize', 14);
        txt2 = strcat('\downarrow', int2str(stats.Area));
        text(centroids(:,1),centroids(:,2)-(1.5*radii), txt2,'Color','white','FontSize',8)
        
        
        % Bottom-left (perimeter)
        subplot(2,2,3),imshow(imgFinal)
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        subplot(2,2,3)
        title('Perimeter', 'FontSize', 14);
        txt3 = strcat('\downarrow', num2str(stats.Perimeter));
        text(centroids(:,1),centroids(:,2)-(1.5*radii), txt3,'Color','white','FontSize',8)
        
        % Bottom-right (relative distances)
        subplot(2,2,4),imshow(img)
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        subplot(2,2,4)
        title('Relative distances', 'FontSize', 14);
        auxSelect = 0;
        
        
% -------------------------------------------------------------------------
%   Relative distances object selection menu
% -------------------------------------------------------------------------
        
        while auxSelect == 0
            
            choice = questdlg('Do you want to select an object to check the distances?', ...
                'First Lab Work', ...
                'Select','Close','Close');
            switch choice
                case 'Select'
                    auxSelect = 0;
                case 'Close'
                    auxSelect = 1;
            end
            
            if auxSelect == 0
                subplot(2,2,4)
                p = ginput(1);
                xp = [p(:,1)];
                yp = [p(:,2)];
                for i = 1:num
                    output = (xp - centers(i,1))^2 + (yp - centers(i,2))^2 <= radii(i)^2;
                    if output == 1
                        objectx = centers(i,1);
                        objecty = centers(i,2);
                        break
                    else
                        res = 'That point does not belong to any object';
                        objectx = 0;
                    end
                end
                
                if objectx ~= 0
                    point=[objectx,objecty];
                    xpoints = [];
                    for idx = 1:numel(x)
                        element = x(idx)
                        result = [point(1,1) element];
                        xpoints = cat(1, xpoints, result);
                    end
                    
                    ypoints = [];
                    for idy = 1:numel(y)
                        element = y(idy)
                        result = [point(1,2) element];
                        ypoints = cat(1, ypoints, result);
                    end
                    
                    subplot(2,2,4),imshow(img)
                    hold on
                    for k = 1:length(bound)
                        boundary = bound{k};
                        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
                    end
                    plot(imgca,centroids(:,1), centroids(:,2), 'r.')
                    plot(xpoints',ypoints', 'color', [1 0 0], 'linewidth', 2);
                    
                    coordx=[xpoints(:,2)]
                    coordy=[ypoints(:,2)]
                    
                    newlength = [];
                    for i = 1:numel(coordx)
                        X = [point;coordx(i),coordy(i)];
                        d = pdist(X,'euclidean');
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
                    
                else
                    res
                end
            end
        end
        
        
    end
    
% -------------------------------------------------------------------------
%   Circularity & Sharpness
% -------------------------------------------------------------------------
    
    if aux == 3 && opt == 0
        choice = questdlg('Ascending or descending?', ...
            'First Lab Work', ...
            'Ascend','Descend','Descend');
        switch choice
            case 'Ascend'
                stats1 = stats;
                stats = sortrows(stats, 'Circularity','ascend');
                stats1 = sortrows(stats1, 'Sharpness', 'ascend');
            case 'Descend'
                stats1 = stats;
                stats = sortrows(stats,'Circularity','descend');
                stats1 = sortrows(stats1, 'Sharpness', 'descend');
        end
        
        centroids = cat(1, stats.Centroid);
        centroids1 = cat(1, stats1.Centroid);
        
        maxrad = max(diameters)/2;
        
        figure; subplot(2,num,1)
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        
        
        % Circularity
        
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids(i,1)-maxrad-10);   %xmin
            sp(2) = floor(centroids(i,2)-maxrad-10);   %ymin
            sp(3) = ceil(centroids(i,1)+maxrad+10);    %xmax
            sp(4) = ceil(centroids(i,2)+maxrad+10);    %ymax
            
            [rows, columns, colors] = size(img);
            
            % Handeling corners
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            
            subplot(2,num,i), subimage(MM)
            axis off
            
            title({'Circularity:'; strcat(num2str(stats.Circularity(i)))});
        end
        
        
        % Sharpness
        
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids1(i,1)-maxrad-10);  %xmin
            sp(2) = floor(centroids1(i,2)-maxrad-10);  %ymin
            sp(3) = ceil(centroids1(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids1(i,2)+maxrad+10);   %ymax
            
            % Handeling corners
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            
            title({'Sharpness:'; strcat(num2str(stats.Sharpness(i)))});
        end
        
        choice = questdlg('Close', ...
            'First Lab Work', ...
            'Close','Close');
        switch choice
            case 'Close'
                delete(gcf)
        end
        
    end
    
    
    
% -------------------------------------------------------------------------
%   Area & Perimeter
% -------------------------------------------------------------------------
    if aux == 1 && opt == 0
        
        choice = questdlg('Ascending or descending?', ...
            'First Lab Work', ...
            'Ascend','Descend','Descend');
        switch choice
            case 'Ascend'
                stats1 = stats;
                stats = sortrows(stats,'Area','ascend');
                stats1 = sortrows(stats1, 'Perimeter', 'ascend');
            case 'Descend'
                stats1 = stats;
                stats = sortrows(stats,'Area','descend');
                stats1 = sortrows(stats1, 'Perimeter', 'descend');
        end
        
        centroids = cat(1, stats.Centroid);
        centroids1 = cat(1, stats1.Centroid);
        
        maxrad = max(diameters)/2;
        
        figure; subplot(2,num,1);
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids(i,1)-maxrad-10);   %xmin
            sp(2) = floor(centroids(i,2)-maxrad-10);   %ymin
            sp(3) = ceil(centroids(i,1)+maxrad+10);    %xmax
            sp(4) = ceil(centroids(i,2)+maxrad+10);    %ymax
            
            [rows, columns, colors] = size(img);
            
            % Handeling corners
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            
            subplot(2,num,i), subimage(MM)
            
            axis off
            title({'Area:'; strcat(num2str(stats.Area(i)))});
        end
        
        
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids1(i,1)-maxrad-10);  %xmin
            sp(2) = floor(centroids1(i,2)-maxrad-10);  %ymin
            sp(3) = ceil(centroids1(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids1(i,2)+maxrad+10);   %ymax
            
            % Handeling corners
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            title({'Perimeter:'; strcat(num2str(stats.Perimeter(i)))});
        end
        
        choice = questdlg('Close', ...
            'First Lab Work', ...
            'Close','Close');
        switch choice
            case 'Close'
                delete(gcf)
        end
        
    end
    
% -------------------------------------------------------------------------
%   Similarity main menu
% -------------------------------------------------------------------------
    
    if aux == 5 && opt == 0
        figure, imshow(img);
        p = ginput(1);
        xp = [p(:,1)];
        yp = [p(:,2)];
        for i = 1:num
            output = (xp - centers(i,1))^2 + (yp - centers(i,2))^2 <= radii(i)^2;
            if output == 1
                objectx = centers(i,1);
                objecty = centers(i,2);
                break
            else
                res = 'That point does not belong to any object';
                objectx = 0;
            end
        end
        
        if objectx ~= 0
            point=[objectx,objecty];
            xpoints = [];
            for idx = 1:numel(x)
                element = x(idx)
                result = [point(1,1) element];
                xpoints = cat(1, xpoints, result);
            end
            
            ypoints = [];
            for idy = 1:numel(y)
                element = y(idy)
                result = [point(1,2) element];
                ypoints = cat(1, ypoints, result);
            end
            
        else
            res;
        end
        
        centroidArray = stats.Centroid.';
        similarityIndex = 1;
        
        for p = 1:num
            if point(1) == centroidArray(1, p) && point(2) == centroidArray(2, p)
                similarityIndex = p;
            end
        end
        
        areaSimilarity = stats.Area.';
        perimeterSimilarity = stats.Perimeter.';
        circularitySimilarity = stats.Circularity.';
        sharpnessSimilarity = stats.Sharpness.';
        
        tempArea = [];
        tempPerimeter = [];
        tempCircularity = [];
        tempSharpness = [];
        for j = 1:num
            tempArea = [tempArea abs(areaSimilarity(similarityIndex) - areaSimilarity(j))];
            tempPerimeter = [tempPerimeter abs(perimeterSimilarity(similarityIndex) - perimeterSimilarity(j))];
            tempCircularity = [tempCircularity abs(circularitySimilarity(similarityIndex) - circularitySimilarity(j))];
            tempSharpness = [tempSharpness abs(sharpnessSimilarity(similarityIndex) - sharpnessSimilarity(j))];
        end
        
        
        stats.areaSimilarity = tempArea.';
        stats.perimeterSimilarity = tempPerimeter.';
        stats.circularitySimilarity = tempCircularity.';
        stats.sharpnessSimilarity = tempSharpness.';
        
        statsArea = sortrows(stats,'areaSimilarity','ascend');
        statsPerimeter = sortrows(stats,'perimeterSimilarity','ascend');
        statsCircularity = sortrows(stats,'circularitySimilarity','ascend');
        statsSharpness = sortrows(stats,'sharpnessSimilarity','ascend');
        
        
        centroidsArea = cat(1, statsArea.Centroid);
        centroidsPerimeter = cat(1, statsPerimeter.Centroid);
        centroidsCircularity = cat(1, statsCircularity.Centroid);
        centroidsSharpness = cat(1, statsSharpness.Centroid);
        
        maxrad = max(diameters)/2;
        
        choice = questdlg('Choose your option', ...
            'First Lab Work', ...
            'Similar Area/Perimeter','Similar Circularity/Sharpness','Back','Back');
        switch choice
            case 'Similar Area/Perimeter'
                aux = 7;
            case 'Similar Circularity/Sharpness'
                aux = 8;
            case 'Back'
                delete(gcf)
        end
    end
    
    % -------------------------------------------------------------------------
    %   Similarity area and perimeter
    % -------------------------------------------------------------------------
    
    if aux == 7 && opt == 0
        figure; subplot(2,num,1);
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroidsArea(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroidsArea(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroidsArea(i,1)+maxrad+10);  %xmax
            sp(4) = ceil(centroidsArea(i,2)+maxrad+10);  %ymax
            
            [rows, columns, colors] = size(img);
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            
            subplot(2,num,i), subimage(MM)
            axis off
            title({'Area Difference:'; num2str(statsArea.areaSimilarity(i))});
        end
        
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroidsPerimeter(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroidsPerimeter(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroidsPerimeter(i,1)+maxrad+10);  %xmax
            sp(4) = ceil(centroidsPerimeter(i,2)+maxrad+10);  %ymax
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            title({'Perimeter Difference:'; num2str(statsArea.perimeterSimilarity(i))});
        end
        
        choice = questdlg('Close', ...
            'First Lab Work', ...
            'Close','Close');
        switch choice
            case 'Close'
                delete(gcf)
                close all
        end
        
    end
    
% -------------------------------------------------------------------------
%   Similarity (circularity and sharpness)
% -------------------------------------------------------------------------
    
    if aux == 8 && opt == 0
        figure; subplot(2,num,1);
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroidsCircularity(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroidsCircularity(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroidsCircularity(i,1)+maxrad+10);  %xmax
            sp(4) = ceil(centroidsCircularity(i,2)+maxrad+10);  %ymax
            
            [rows, columns, colors] = size(img);
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            
            subplot(2,num,i), subimage(MM)
            axis off
            title({'Circularity Difference'; num2str(statsArea.circularitySimilarity(i))});
            
        end
        
        for i = 1:num
            
            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroidsSharpness(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroidsSharpness(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroidsSharpness(i,1)+maxrad+10);  %xmax
            sp(4) = ceil(centroidsSharpness(i,2)+maxrad+10);  %ymax
            
            if sp(1) < 0
                sp(1) = 1;
            end
            
            if sp(2) < 0
                sp(2) = 1;
            end
            
            if sp(3) > columns
                sp(3) = columns;
            end
            
            if sp(4) > rows
                sp(4) = rows;
            end
            
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            
            title({'Sharpness Difference'; num2str(statsArea.sharpnessSimilarity(i))});
        end
        
        choice = questdlg('Close', ...
            'First Lab Work', ...
            'Close','Close');
        switch choice
            case 'Close'
                delete(gcf)
                close all
        end
    end
    
end


