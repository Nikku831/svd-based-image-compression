clc; clear; close all
% Read the input image
originalImage = imread('Albert_Einstein.jpg'); 

% Display the original image
figure;
imshow(originalImage);
title('Original Image');

% Convert the image to grayscale if it's a color image
if size(originalImage, 3) == 3
   originalImage = rgb2gray(originalImage);
end

% Perform Singular Value Decomposition (SVD)
A=double(originalImage);
% Compute A*A'
AAT = A * A';
% Compute eigenvalues and eigenvectors of A*A'
[U, D] = eig(AAT);
    
% Sort the columns of U and D in decreasing order of eigenvalues
[D, ind] = sort(diag(D), 'descend');
U = U(:, ind);
    
% Compute singular values as square root of eigenvalues
S = sqrt(D);
    
% Compute V from U, S, and A
V = zeros(size(A, 2));
for i = 1:size(A, 2)
    if S(i) ~= 0
        V(:, i) = A' * U(:, i) / S(i);
    end
end
S=diag(S);
% Additional logic to match the signs with MATLAB's built-in svd()
[~, ~, V_svd] = svd(A);
for i = 1:size(V, 2)
    if dot(V(:, i), V_svd(:, i)) < 0
        V(:, i) = -V(:, i);
        U(:, i) = -U(:, i);
    end
end

% Specify the compression ratio (choose a value between 0 and 1)
compressionRatio = 0.1;

% Calculate the number of singular values to keep
numSingularValues = round(compressionRatio * min(size(S)));

% Truncate the singular value matrices
U_truncated = U(:, 1:numSingularValues);
S_truncated = S(1:numSingularValues, 1:numSingularValues);
V_truncated = V(:, 1:numSingularValues);

% Reconstruct the compressed image
compressedImage = U_truncated * S_truncated * V_truncated';

% Display the compressed image
figure;
imshow(uint8(compressedImage));
title('Compressed Image');

% Calculate compression ratio
originalSize = numel(originalImage);
compressedSize = numel(U_truncated) + numel(S_truncated) + numel(V_truncated);
compressionRatio = compressedSize / originalSize;

disp(['Compression Ratio: ', num2str(compressionRatio)]);

% Save the compressed image
imwrite(uint8(compressedImage), 'compressed_image.jpg');