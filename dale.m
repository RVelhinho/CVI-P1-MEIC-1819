clear all, close all

%name = inputdlg('Choose your image:');
%img = imread(name{1});

img = imread('Moedas1.jpg');
img_gauss = imgaussfilt(img, 3);

binary = imbinarize(img_gauss(:,:,1),0.50);

se = strel('disk', 2);
i1 = imdilate(binary,se);

%Treat objects touching each other
D = -bwdist(~i1);

WS = watershed(D);

mask = imextendedmin(D,3);

D2 = imimposemin(D, mask);
WS2 = watershed(D2);
imgFinal = i1;
imgFinal(WS2 == 0) = 0;

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


area = stats.Area;
diam = mean([stats.MinorAxisLength stats.MajorAxisLength], 2);

centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);

coinDiameters2 = diameters.';
radii = diameters/2;

centroids = cat(1, stats.Centroid);


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
        
        disp(coinValues(index)); 
        sumMoney = sumMoney + coinValues(index);
    end
    
  
  
end




x=[centroids(:,1)]
y=[centroids(:,2)]

opt = 0;
aux = 0;

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
            'Ordered Circularity/Sharpness','Ordered Area/Perimeter','Back','Back');
        % Handle response
        switch choice
            case 'Ordered Circularity/Sharpness'
                aux = 3;
            case 'Ordered Area/Perimeter'
                aux = 1;
            case 'Back'
                delete(gcf)
        end
    end
    
    if aux == 0 && opt == 0
        
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        
        %Draw object boundaries  
        
        subplot(2,2,1),imshow(img);
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        
        

        subplot(2,2,2),imshow(imgFinal)
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end

        subplot(2,2,3),imshow(imgFinal)
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end

        % Liga??o entre centroides
        subplot(2,2,4),imshow(img)
        hold on
        for k = 1:length(bound)
            boundary = bound{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end

        % 7 - Classificacao de objectos

        % 8 - Visualizacao de imagem
        % imshow, imagesc

        % 9 - Gravacao de imagem
        % imwrite
        % imwrite(A,filename) writes image data A to the file specified by filename
        imwrite(imgFinal, 'final.jpg')

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
        plot(centroids(:,1),centroids(:,2), '.r');
        text(50,700,strcat('Number of Objects ',' :',{' '} ,int2str(num)),'Color','white','FontSize',12)
        text(50,660,strcat('Euro Value ',' :',{' '} ,num2str(sumMoney)),'Color','white','FontSize',12)

        subplot(2,2,2)
        title('Area', 'FontSize', 14);
        txt2 = strcat('\downarrow', int2str(stats.Area));
        text(centroids(:,1),centroids(:,2)-(1.5*radii), txt2,'Color','white','FontSize',8)

        subplot(2,2,3)
        title('Perimeter', 'FontSize', 14);
        txt3 = strcat('\downarrow', num2str(stats.Perimeter));
        text(centroids(:,1),centroids(:,2)-(1.5*radii), txt3,'Color','white','FontSize',8)

        subplot(2,2,4)
        title('Relative distances', 'FontSize', 14);
        auxSelect = 0;
    
        while auxSelect == 0

            % Construct a questdlg with three options
            choice = questdlg('Do you want to select an object to check the distances?', ...
                'Image', ...
                'Select','Close','Close');
            % Handle response
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
    
% -------------------------------------------------------------------------
%   Circularity & Sharpness
% -------------------------------------------------------------------------
    
    if aux == 3 && opt == 0
        
        % Construct a questdlg with three options
            choice = questdlg('Ascending or descending?', ...
                'Image', ...
                'Ascend','Descend','Descend');
            % Handle response
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
        for i = 1:num

            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroids(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroids(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids(i,2)+maxrad+10);   %ymax
            
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
            
            
            
            disp(sp(1));
            disp(sp(2));
            disp(sp(3));
            disp(sp(4));

            % Index into the original image to create the new image
            MM = img(sp(2):sp(4), sp(1): sp(3),:);

            subplot(2,num,i), subimage(MM)
            axis off
            title(strcat('Circularity', ': ' , {' '}, num2str(stats.Circularity(i))), 'FontSize', 12);

        end
           

        for i = 1:num

            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids1(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroids1(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroids1(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids1(i,2)+maxrad+10);   %ymax
            
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

            % Index into the original image to create the new image
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            
            title(strcat('Sharpness', ': ' , {' '}, num2str(stats1.Sharpness(i))), 'FontSize', 12);
        end
      
        
       
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
    
    
    
% -------------------------------------------------------------------------
%   Area & Perimeter
% -------------------------------------------------------------------------
    if aux == 1 && opt == 0

        % Construct a questdlg with three options
            choice = questdlg('Ascending or descending?', ...
                'Image', ...
                'Ascend','Descend','Descend');
            % Handle response
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

            figure; subplot(2,num,1)
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        for i = 1:num

            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroids(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroids(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids(i,2)+maxrad+10);   %ymax
            
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
            
            
            
            disp(sp(1));
            disp(sp(2));
            disp(sp(3));
            disp(sp(4));

            % Index into the original image to create the new image
            MM = img(sp(2):sp(4), sp(1): sp(3),:);

            subplot(2,num,i), subimage(MM)
            axis off
            title(strcat('Area', ': ',{' '}, int2str(ceil(stats.Area(i)))), 'FontSize', 12);

        end
           

        for i = 1:num

            % Get the x and y corner coordinates as integers
            sp(1) = floor(centroids1(i,1)-maxrad-10); %xmin
            sp(2) = floor(centroids1(i,2)-maxrad-10); %ymin
            sp(3) = ceil(centroids1(i,1)+maxrad+10);   %xmax
            sp(4) = ceil(centroids1(i,2)+maxrad+10);   %ymax
            
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

            % Index into the original image to create the new image
            MM = img(sp(2):sp(4), sp(1): sp(3),:);
            subplot(2,num,num+i), subimage(MM)
            axis off
            
            title(strcat('Perimeter', ': ' , {' '}, int2str(ceil(stats1.Perimeter(i)))), 'FontSize', 12);
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


