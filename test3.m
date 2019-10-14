%import image data
location = 'C:\Users\Archana\Desktop\Project 1\miscnew\*.tiff';
ds = imageDatastore(location)
imgs = readall(ds);

%converting colour images into b/w
for i = 1:14
    imgs{i} = imgs{i}(:,:,1);
end    

%image segmentation
for i = 1:38
    z{i} = segmentation(imgs{i});
end    

%build neural network (training)

%1. define size of neural net (NxMxN)
N = 25;
M = 16;
net = network(1,2);
net.numInputs = 1;
net.inputs{1}.size = 25;
%2. decide bias for hidden and op layer (depends on no of neurons in layer)
net.biasConnect = [1;1]; 
net.inputConnect = [1 ;0]; 
net.layers{1}.size = 16;
net.layers{2}.size = 25;
net.layerConnect = [ 0 0;1 0];
net.outputConnect = [0 1];
%3. initialize weight matrix randomly with values ranged from 0 to 1
initlvq('configure',net,'IW',1,1,settings);
initlvq('configure',net,'LW',2,1,settings);
net.initFcn = 'initlay';
net.layers{1}.initFcn='initwb';
net.layers{2}.initFcn='initwb';
net.inputWeights{1,1}.initFcn = 'midpoint';
net.layerWeights{2,1}.initFcn = 'midpoint';
net.inputWeights{1,1}.learn = 1;
net.layerWeights{2,1}.learn = 1;
net.inputWeights{1,1}.learnFcn = 'customlearngdm';
net.layerWeights{2,1}.learnFcn = 'customlearngdm';
net.layers{1}.transferFcn = 'logsig';
net.layers{2}.transferFcn = 'purelin';
%define bias vector 1, v1
v1 = [9;3;5;8;1;5;2;8;7;2;7;4;1;6;5;8];
v1_temp = mat2gray(v1);
v1_temp2 = fin_op_mulnet1{5};
v1_norm = v1_temp+v1_temp2';
net.b{1} = v1_norm;

%define bias vector 2, v2
v2 = [4;7;1;8;3;6;9;2;1;5;5;8;3;9;2;1;4;7;3;8;9;6;7;2;8];
v2_temp = mat2gray(v2);
v2_temp2 =fin_op_mulnet2{2}
v2_norm = v2_temp+v2_temp2';
net.b{2}= v2_norm;

net.trainFcn = 'traingda';
net.biases{1}.learn = 0;
net.biases{2}.learn = 0;
net.trainParam.epochs = 1000;
for i= 1:38
    net = configure(net,z{i},z{i});
end    

%initial network response without training
for i = 1:38
    initial_output = net(z{i});
end
%network training
net.performFcn = 'newfcn';
for i = 1:38
    net = train(net,z{i},z{i});
end
for i = 1:38
    final_output = net(z{i});
end

%Testing Encryption and Decryption
location = 'C:\Users\Archana\Desktop\Project 1\digitized test images\*.tiff';
ds1 = imageDatastore(location)
test_imgs = readall(ds1);
test_imgs{1} = test_imgs{1}(:,:,1);
test{1} = segmentation(test_imgs{1});
%Encrypted Image
IW = cell2mat(net.IW);
b1 = net.b{1};
fintest = cell2mat(test{1,1});
q1= fintest';
q = q1(1,:);
p = IW.*q;
cipher = (logsig(p +b1));

%Decrypted Image
deciphertemp = net(test{1})
decipher= cell2mat(deciphertemp);
row = [0 0 0 0 0;0 0 0 0 0;0 0 0 0 0;0 0 0 0 0;0 0 0 0 0];
final_matrix = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

for i=1:100
    column = decipher(:,i);
    tempx = reshape(column,5,5);
    reshaped = tempx';
    if i==0
       row=reshaped;
    else if mod(i,10) ~= 0
       row = horzcat(row, reshaped);
    else if i==10
       final_matrix = row;
       row = reshaped;
    else if mod(i,10)== 0
       final_matrix = vertcat(final_matrix, row);
       row=reshaped;
        end
        end
        end
    end
end

%multiplicative neuron 1 for hidden layer bias vector
row1v1= [9 3 5 8]; 
row2v1= [1 5 2 8]; 
row3v1= [7 2 7 4]; 
row4v1= [1 6 5 8];
rowfin = [row1v1 row2v1 row3v1 row4v1];
rowfin1 = mat2gray(rowfin)
rowfinal = mat2cell(rowfin1, 1);
M1 = perms(row1v1);
M2 = perms(row2v1);
M3 = perms(row3v1);
M4 = perms(row4v1);
Mfin = [M1 M2 M3 M4];
Mfin1 = mat2gray(Mfin);
rowDist = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
Mfinal = mat2cell(Mfin1,rowDist);
targetgen = [99 401 789 1101];
target = perms(targetgen);
temp = [target target target target];
temp1 = mat2gray(temp);
targetfinal = mat2cell(temp1,rowDist);

mulnet1 = network(1,1);
mulnet1.biasConnect = [1];
mulnet1.inputConnect = [1];
mulnet1.layerConnect = [0];
mulnet1.outputConnect = [1];
mulnet1.layers{1}.netInputFcn = 'netprod';
mulnet1.inputs{1}.size = 1;
mulnet1.layers{1}.size = 1;
mulnet1.layers{1}.transferFcn = 'logsig';
mulnet1.initFcn = 'initlay';
mulnet1.inputWeights{1}.learnFcn = 'learngdm';
mulnet1.biases{1}.learnFcn = 'learngdm';
mulnet1 = configure(mulnet1,Mfinal',targetfinal');
mulnet1.trainFcn = 'traingd';
mulnet1.performFcn = 'mse';
mulnet1.trainParam.epochs = 1000;
init_op_mulnet1 = mulnet1(Mfinal');
mulnet1 = train(mulnet1,Mfinal',targetfinal');
fin_op_mulnet1 = mulnet1(Mfinal');

%multiplicative neuron 2 for output layer bias vector
v2 = [4;7;1;8;3;6;9;2;1;5;5;8;3;9;2;1;4;7;3;8;9;6;7;2;8];

row1v2= [4 7 1 8 3]; 
row2v2= [6 9 2 1 5]; 
row3v2= [5 8 3 9 2]; 
row4v2= [1 4 7 3 8];
row5v2= [9 6 7 2 8];
rowfinv2 = [row1v2 row2v2 row3v2 row4v2 row5v2];
rowfin1v2 = mat2gray(rowfinv2)
rowfinalv2 = mat2cell(rowfin1v2, 1);
M1v2 = perms(row1v2);
M2v2 = perms(row2v2);
M3v2 = perms(row3v2);
M4v2 = perms(row4v2);
M5v2 = perms(row5v2);
Mfinv2 = [M1v2 M2v2 M3v2 M4v2 M5v2];
Mfin1v2 = mat2gray(Mfinv2);
rowDistv2 = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
Mfinalv2 = mat2cell(Mfin1v2,rowDistv2);
targetgenv2 = [99 401 789 1101 184];
targetv2 = perms(targetgenv2);
tempv2 = [targetv2 targetv2 targetv2 targetv2 targetv2];
temp1v2 = mat2gray(tempv2);
targetfinalv2 = mat2cell(temp1v2,rowDistv2);

mulnet2 = network(1,1);
mulnet2.biasConnect = [1];
mulnet2.inputConnect = [1];
mulnet2.layerConnect = [0];
mulnet2.outputConnect = [1];
mulnet2.layers{1}.netInputFcn = 'netprod';
mulnet2.inputs{1}.size = 1;
mulnet2.layers{1}.size = 1;
mulnet2.layers{1}.transferFcn = 'logsig';
mulnet2.initFcn = 'initlay';
mulnet2.inputWeights{1}.learnFcn = 'learngdm';
mulnet2.biases{1}.learnFcn = 'learngdm';
mulnet2 = configure(mulnet2,Mfinalv2',targetfinalv2');
mulnet2.trainFcn = 'traingd';
mulnet2.performFcn = 'mse';
mulnet2.trainParam.epochs = 1000;
init_op_mulnet2 = mulnet2(Mfinalv2');
mulnet2 = train(mulnet2,Mfinalv2',targetfinalv2');
fin_op_mulnet2 = mulnet2(Mfinalv2');


% PSNR, NPCR, UACI, Key sensitivity analysis, Entropy (log function of original image), histogram analysis, correlation coeffficient plotting (ioriginal image 2 cons rows, encrypted image 2 cons rows), MSE, cropping attack, noise attack (insert nnoise)
%NPCR and UACI

ciphera = reshape(cipher, 8,50);
cipher1 = padarray(cipher,[17 13],'replicate','symmetric')
cipher1(:,51) = []; 
test_imgs{1} = double(test_imgs{1})
NPCR_and_UACI(test_imgs{1},cipher1);
peaksnr1 = psnr(test_imgs{1},final_matrix);
peaksnr2 = psnr(test_imgs{1},cipher1);

imhist(test_imgs{1});
imhist(cipher1);
imhist(final_matrix);
