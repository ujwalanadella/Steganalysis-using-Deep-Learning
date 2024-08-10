cover_object = imread('/Users/nadellaujwala/Documents/Research Final/lena15.jpg');
% read the message image you want to hide in the cover image
message = zeros(64, 64);
message(9:16, 9:56) = 255;
message(17:56, 29:36) = 255;
% determine the size of cover image used for embedding
Mc = size(cover_object, 1);    % Height
Nc = size(cover_object, 2);    % Width
% determine the size of the message object to embed
Mm = size(message, 1);         % Height
Nm = size(message, 2);         % Width
% Initialize watermarked_image with the cover_object
watermarked_image = cover_object;
% Calculate the energy of each block in the cover image
blockSize = 64;  % Adjust the block size as needed
numBlocksM = fix(Mc / blockSize);
numBlocksN = fix(Nc / blockSize);
blockEnergies = zeros(numBlocksM, numBlocksN);
for i = 1:numBlocksM
    for j = 1:numBlocksN
        % Adjust block boundaries to handle different block sizes
        startRow = (i-1)*blockSize+1;
        endRow = min(i*blockSize, Mc);
        startCol = (j-1)*blockSize+1;
        endCol = min(j*blockSize, Nc);

        block = cover_object(startRow:endRow, startCol:endCol, 1);
        blockEnergies(i, j) = sum(block(:).^2);  % You may adjust the energy calculation method
    end
end
% Find the indices of the block with the highest energy
[~, maxEnergyIndex] = max(blockEnergies(:));
[maxEnergyRow, maxEnergyCol] = ind2sub(size(blockEnergies), maxEnergyIndex);
% Embed the message into the red channel of the block with the highest energy
for ii = 1:Mm
    for jj = 1:Nm
        % Adjust indices to handle different block sizes
        rowIndex = min(maxEnergyRow * blockSize + ii, Mc);
        colIndex = min(maxEnergyCol * blockSize + jj, Nc);
        watermarked_image(rowIndex, colIndex, 1) = bitset(watermarked_image(rowIndex, colIndex, 1), 1, message(ii, jj));
    end
end

% Display the images
% figure;
% subplot(1,2,1)
% imshow(cover_object);
% title('Original Image')
% subplot(1,2,2)
 imshow(watermarked_image);
% title('Watermarked Image')
imwrite(watermarked_image, '/Users/nadellaujwala/Documents/lsb1001.jpg', 'jpg');
% Calculate and display the Peak-SNR value
peaksnr = psnr(cover_object, uint8(watermarked_image));
fprintf('\nThe Peak-SNR value is %0.4f\n', peaksnr);
% Extraction process
% attack=imnoise(watermarked_image,"salt & pepper",0.05);
% attack = imnoise(watermarked_image,'gaussian',0.02);
% attack=imnoise(watermarked_image,"speckle",0.02);
% attack=imgaussfilt3(uint8(watermarked_image));
% attack = medfilt3(watermarked_image);
% attack = histeq(watermarked_image);
% watermarked_image=attack;
% determine the size of the watermarked image
Mw = size(watermarked_image, 1);  % Height
Nw = size(watermarked_image, 2);  % Width

% Calculate the energy of each block in the watermarked image
blockSize = 64;  % Adjust the block size as needed
numBlocksM = fix(Mw / blockSize);
numBlocksN = fix(Nw / blockSize);

blockEnergies = zeros(numBlocksM, numBlocksN);

for i = 1:numBlocksM
    for j = 1:numBlocksN
        % Adjust block boundaries to handle different block sizes
        startRow = (i-1)*blockSize+1;
        endRow = min(i*blockSize, Mw);
        startCol = (j-1)*blockSize+1;
        endCol = min(j*blockSize, Nw);

        block = watermarked_image(startRow:endRow, startCol:endCol, 1);
        blockEnergies(i, j) = sum(block(:).^2);  % You may adjust the energy calculation method
    end
end

% Find the indices of the block with the highest energy
[~, maxEnergyIndex] = max(blockEnergies(:));
[maxEnergyRow, maxEnergyCol] = ind2sub(size(blockEnergies), maxEnergyIndex);

% Extract the message from the red channel of the block with the highest energy
extracted_message = zeros(64, 64);

for ii = 1:64
    for jj = 1:64
        % Adjust indices to handle different block sizes
        rowIndex = min(maxEnergyRow * blockSize + ii, Mw);
        colIndex = min(maxEnergyCol * blockSize + jj, Nw);
        extracted_message(ii, jj) = bitget(watermarked_image(rowIndex, colIndex, 3), 1);
    end
end

% Display the extracted message
% figure;
% imshow(uint8(extracted_message*255 ));  % Convert to uint8 for correct display
% title('Extracted Watermark');

cc=corr2(uint8(message), uint8(extracted_message*255));
fprintf('\n The CC value is %0.4f', cc);
