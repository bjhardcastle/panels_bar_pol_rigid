% makes a low contrast bright bar pattern with grayscale and row compression
bar_width = 8; % floored to nearest even value 
pattern.gs_val = 3; 	% pattern will use 2^pattern.gs_val intensity levels
background_brightness= 0:2^pattern.gs_val-1;  
bar_brightness = 0;
pat_dir = cd;

pattern.x_num = 160; 	% There are 160 pixel around the display (12 actual columns, 8 missing)
pattern.y_num = length(background_brightness); 		%  y1 bar is invisible, y2:end bar is visible
pattern.num_panels = 80; 	% This is the number of unique Panel IDs required.
pattern.row_compression = 1;

Pats = ones(4, 160, pattern.x_num, pattern.y_num); 	%initializes the array with ones
for bb = 1:length(background_brightness)
% make dark bar with starting position within 'invisible' mising LEDs at rear
Pats(:, :, 1, bb) = background_brightness(bb).*Pats(:, :, 1, bb);
Pats(:, 1:floor(0.5*bar_width), 1, bb) = bar_brightness;
Pats(:, end-floor(0.5*bar_width)+1:end, 1, bb) = bar_brightness;

for jj = 2:160 			%use ShiftMatrixPats to rotate stripe image
    Pats(:,:,jj,bb) = ShiftMatrix(Pats(:,:,jj-1,bb),1,'r','y');
end
end

pattern.Pats = Pats;

% For ben behaviour panels (new, blue panels, with full 20x8 arena simulated
% - same as 2p panel map for first 48 panels):
for i = 1:12
    for j = 1:4
        Panel_mat(j,i) = mod((i-1)*4,12) + ceil(i/3) + (j-1)*12;
    end
end
ct = max(Panel_mat(:));
for i = 13:20
    for j = 1:4
        ct = ct+1;
        Panel_mat(j,i) = ct;
    end
end
Panel_mat = circshift(Panel_mat,7,2);
mat = flipud(Panel_mat);
pattern.Panel_map = fliplr(mat);


% Convert
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% Save
str = fullfile(pat_dir, ['Pattern_20x4_dark_bar_width_' num2str(bar_width) '_brightness_' num2str(min(background_brightness)) '-' num2str(max(background_brightness)) '.mat']);
save(str, 'pattern');
