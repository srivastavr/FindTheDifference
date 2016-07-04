%%Matlab  Code Find the Differences


%%% % Pre-requisites:
% % 1.Enable developer options in your android device
% % 2.Install adb drivers for your device
% % 3.Check if ADB device interface is the driver installed for your device
% in device manager
% % 4.To check if they are properly installed connect your device and run "adb devices" command from shell or command promt from the present working directory
% % 5.Your device adb hostname must be displayed
% % 6.Close the command prompt and tap play on your device. Run this script

% % Note:1. If the device is being shown as offline disconnect and reconnect
% your device
% % 2. To stop the game find 10 differences between the two pictures. If 3
% wrong differences are found simultaneously, a hint message pops up.


clear all %% Clear all variables
close all %% Close all open figures
clc %% Clear command window

% % Capturing screenshot and saving it to sdcard of the android device
system('adb shell screencap -p /sdcard/screen.png');

% %  Pulling image to your working directory
system('adb pull /sdcard/screen.png');

% % Starts the stopwatch timer
tic

% % Reading pulled image from working directory 
img = imread('screen.png');

% % Displaying the image pulled
figure
imshow (img);
1
% % Cropping the two images having differences
upper_crop = imcrop (img, [1 281 1080-1 1037-281]);
lower_crop = imcrop (img, [1 1050 1080-1 1806-1050]);

% % Subtracting the two images
img_diff = lower_crop - upper_crop;

% % Extracting R G B components of the image
R=img_diff(:,:,1);
G=img_diff(:,:,2);
B=img_diff(:,:,3);

% % Converting the three-layered image to a binary image
bin_img = img_diff(:,:,1)>=15 | img_diff(:,:,2)>=15 | img_diff(:,:,3)>=15;

final_img = bin_img;


% % In bin_img, the regions obtained are discrete. To make it solid,
% the whole matrix is traversed. On finding a white pixel (1), the next 30
% pixels(rows and columns) are made white (1)
for r = 1:757;
    
    % % On finding a white pixel, the next 39 columns are skipped from the
    % iteration process
    k = 0;
    for c = 1:1080;
        
    % % On finding a white pixel, the next 39 rows are skipped from the
    % iteration process
      l = 0;
      if bin_img(r,c) == 1 & k <= c
          if c + 39 <= 1080
            final_img(r,c : c + 39) = 1;
          else
            final_img(r,c : 1080) = 1;
          end
          k = c + 40;
      end
      if bin_img(r,c) == 1 & l <= r
          if r + 39 <= 757
            final_img(r : r + 39,c) = 1;
          else
            final_img(r : 757,c) = 1;
          end
          l = r + 40;
      end
    end
end


% %Now final_img contains solid regions representing the differences
figure

imshow(final_img);

% % Calculating the region properties of the solid regions in final_img
region_img = regionprops (final_img);

% % This returns the number of regions detected
num_region = size (region_img, 1);

% % Obtaining the centroid of each of the regions to be used for tapping 
for i = 1:num_region
    x = region_img(i).Centroid(1);
    
    % % 270 is added to match the coordinate of the cropped image with the
    % original image
    y = region_img(i).Centroid(2) + 270;
    
    % % Generating command to be given for tapping
    system(['adb shell input swipe ' num2str(x) ' ' num2str(y) ' ' num2str(x) ' ' num2str(y) '']);
   
    % % Introducing a time delay of 2 seconds between each tap
    pause(2);
end

% % Removing the scrrenshot saved in sdcard to save space 
system('adb shell rm /sdcard/screen.png');

% % Stops the stopwatch timer
toc
