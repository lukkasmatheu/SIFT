
%{
Lucas Matheus dos Santos
Projeto de disciplina
Este algoritmo tem como objetivo encontrar imagens em um banco de fotos que
possuam um objeto em comum, para isso foi utilizado o algoritmo SIFT para
obtenção de recursos das imagens utilizadas.
%}
close all; clear all; clc;
principal = imread('principal2.jpg');
% o algoritmo SIFT encontra pontos de interrese na imagem correspondente e
% recupera as caracteristicas dos objetos da imagem.
pontosImagensPrincipal = detectSIFTFeatures(rgb2gray(principal));
%mostrando a imagem.
figure,imshow(principal),title('Objeto a ser Buscado')
% tamanho pre-definido de retangulo usado para delinear objeto na imagem
% posteriomente .
busPoligon = [1, 1;...                           
        size(rgb2gray(principal), 2), 1;...                
        size(rgb2gray(principal), 2), size(rgb2gray(principal), 1);...
        1, size(rgb2gray(principal), 1);...                 
        1, 1]; 
% Extraindo as propriedades dos recursos gerados pelo SIFT
[featurePrincipal, pontosPrincipal] = extractFeatures(rgb2gray(principal), pontosImagensPrincipal);

%recupera o arquivo de imagens de entrada para comparação com a imagem
%principal
filesImg = dir(strcat('./SIFT/ImagensEntrada/*.jpg'));

%index para contar a quantidade de imagens que possuem o objeto
index = 1;
%Percorre todas as imagens jpg da pasta de imagens de entrada 
for file = filesImg'
    % le imagem por imagem dentro da pasta de entrada
    imgAux = imread(strcat(file.folder,"/",file.name));
    % recupera as caracteristicas dos objetos da imagem
    pontosImagemAuxiliar = detectSIFTFeatures(rgb2gray(imgAux));
    figure(),imshow(imgAux),title('Imagem do arquivo')
    %Extraindo as propriedades dos recursos gerados pelo SIFT
    [featureAuxiliar, pontoAuxiliar] = extractFeatures(rgb2gray(imgAux), pontosImagemAuxiliar);
    % encontra os pontos correspondentes em ambas as imagens
    pontosIguais = matchFeatures(featurePrincipal, featureAuxiliar,'MaxRatio',0.62);
    [lin col] = size(pontosIguais);
    % verifica se a quantidade de pontos correspondentes na imagem for
    % menos que um certo limite então pode ser eliminada pois não possui o
    % objeto buscado
    if lin > 50
        %Recupera as cordenadas referentes a invariancia do objetos 
        cordenadasPrincipais = pontosPrincipal(pontosIguais(:, 1), :); 
        cordenadasAuxiliar = pontoAuxiliar(pontosIguais(:, 2), :);
        % mostra os pontos correspondentes entre as duas imagens
        figure;showMatchedFeatures(principal, imgAux, cordenadasPrincipais,cordenadasAuxiliar, 'montage');
        title('Pontos correspondentes encontrados');
        % busca eliminar pontos que não sejam do objeto
        [tform,  inlierBoxPoints, inlierScenePoints] = estimateGeometricTransform(cordenadasPrincipais, cordenadasAuxiliar, 'affine', 'Confidence', 50.9, 'MaxNumTrials', 5000);
        % gera cordenadas do retangulo baseada no form gerado pela estima
        % geometrica e pelo tamanho de box predefinido anteriormente
        busBoxPoligon = transformPointsForward(tform, busPoligon);
         figure;showMatchedFeatures(principal, imgAux, inlierBoxPoints,inlierScenePoints, 'montage');
        title('Pontos correspondentes encontrados');
        % Mostra a figura com o objeto delineado por um retangulo
        figure;
        imshow(imgAux);
        hold on;
        line(busBoxPoligon(:, 1), busBoxPoligon(:, 2), 'Color', 'y');
        
        % gera um retangulo para a imagem de saida que é salva na pasta de
        % saida
        Poly = [busBoxPoligon(1,1) busBoxPoligon(1,2) busBoxPoligon(2,1) busBoxPoligon(2,2) ...
        busBoxPoligon(3,1) busBoxPoligon(3,2) busBoxPoligon(4,1) busBoxPoligon(4,2)...
        busBoxPoligon(5,1) busBoxPoligon(5,2)];
        title('Detected Box');
        %insere o retangulo demarcando o objeto na imagem de saida
        croppedImage = insertShape(imgAux, 'Polygon', Poly, 'Color', 'red','LineWidth',15);
        %Escreve as imagens que possuem o objeto na pasta de saida
        imwrite(croppedImage,strcat('./SIFT/Saida/imgSaida',string(index),'.jpg'))
        %incrementa o contador de imagem usado para nomear as imagens de
        %saida
        index = index + 1;
    end
    
end

