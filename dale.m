clear all, close all

%name = inputdlg('Choose your image:');
%img = imread(name{1});

img = imread('Moedas1.jpg');
imshow(img);

img_gauss = imgaussfilt(img, 3);

figure, imshow(img_gauss(:,:,1));
binary = imbinarize(img_gauss(:,:,1),0.50);
figure, imshow(binary);

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

area = stats.Area;
diam = mean([stats.MinorAxisLength stats.MajorAxisLength], 2);

figure;
imshow(imgFinal);title('Image Treatment');


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
    
    if aux == 0 && opt == 0
        
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        
        %Draw object boundaries  
        bound = bwboundaries(imgFinal,'holes');
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
end

