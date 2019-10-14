function f = segmentation(x)
R = x;
[rows columns numberOfColorBands] = size(R);

%preprocess image data
%1.segment into sub images

% The first way to divide an image up into blocks is by using mat2cell().
blockSizeR = 5; % Rows in block.
blockSizeC = 5; % Columns in block.

% Figure out the size of each block in rows. 
% Most will be blockSizeR but there may be a remainder amount of less than that.
wholeBlockRows = (rows / blockSizeR);
blockVectorR = [blockSizeR * ones(1, wholeBlockRows)];
% Figure out the size of each block in columns. 
wholeBlockCols = (columns / blockSizeC);
blockVectorC = [blockSizeC * ones(1, wholeBlockCols)];

% Create the cell array, ca.  
% Each cell (except for the remainder cells at the end of the image)
% in the array contains a blockSizeR by blockSizeC by 3 color array.
% This line is where the image is actually divided up into blocks.
% if numberOfColorBands > 2
%     ca = mat2cell(R, blockVectorR, blockVectorC, numberOfColorBands);
% else
    ca = mat2cell(R, blockVectorR, blockVectorC);



% Now display all the blocks.
plotIndex = 1;
numPlotsR = size(ca, 1);
numPlotsC = size(ca, 2);
% for r = 1 : numPlotsR
%   for c = 1 : numPlotsC
%     fprintf('plotindex = %d,   c=%d, r=%d\n', plotIndex, c, r);
%     % Specify the location for display of the image.
%     subplot(numPlotsR, numPlotsC, plotIndex);
%     % Extract the numerical array out of the cell
%     % just for tutorial purposes.
%     rgbBlock = ca{r,c};
%     imshow(rgbBlock); % Could call imshow(ca{r,c}) if you wanted to.
%     [rowsB columnsB numberOfColorBandsB] = size(rgbBlock);
%     % Make the caption the block number.
%     caption = sprintf('Block #%d of %d\n%d rows by %d columns', ...
%       plotIndex, numPlotsR*numPlotsC, rowsB, columnsB);
%     title(caption);
%     drawnow;
%     % Increment the subplot to the next location.
%     plotIndex = plotIndex + 1;
%   end
% end

%2.convert each sub image into input vector (and normalize it)

for r = 1 : numPlotsR
  for c = 1 : numPlotsC
      rgbBlock = ca{r,c}
      temp_img{r,c} = mat2gray(rgbBlock)
      imgVector{c,r}= reshape(temp_img{r,c}, 1, [])
  end
end
newimgVector = [imgVector{:}];
X1= newimgVector.';
X2= num2cell(reshape(X1,25,100),1);
f = X2;
end