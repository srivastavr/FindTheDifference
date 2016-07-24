clear all %% Clear all variables
close all %% Close all open figures
clc %% Clear command window

% % Capturing screenshot and saving it to sdcard of the android device
system('adb shell screencap -p /sdcard/screen.png');

% %  Pulling image to your working directory
system('adb pull /sdcard/screen.png');

% % Starts the stopwatch timer
tic

 
img = imread('screen.png');

figure
imshow (img);
1
% % Cropping the two images having differences
upper_crop = imcrop (img, [1 281 1080-1 1037-281]);
lower_crop = imcrop (img, [1 1050 1080-1 1806-1050]);

img_diff = lower_crop - upper_crop;

% % Extracting R G B components of the image
R=img_diff(:,:,1);
G=img_diff(:,:,2);
B=img_diff(:,:,3);

% % Converting the three-layered image to a binary image
bin_img = img_diff(:,:,1)>=15 | img_diff(:,:,2)>=15 | img_diff(:,:,3)>=15;

final_img = bin_img;

for r = 1:757;
    
    k = 0;
    for c = 1:1080;
        

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

figure

imshow(final_img);

region_img = regionprops (final_img);

num_region = size (region_img, 1);

for i = 1:num_region
    x = region_img(i).Centroid(1);
    
   
    y = region_img(i).Centroid(2) + 270;
    
  
    system(['adb shell input swipe ' num2str(x) ' ' num2str(y) ' ' num2str(x) ' ' num2str(y) '']);
   
 
    pause(2);
end

system('adb shell rm /sdcard/screen.png');

% % Stops the stopwatch timer
toc
